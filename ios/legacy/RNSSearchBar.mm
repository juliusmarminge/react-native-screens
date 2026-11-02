#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import <atomic>

#import "RNSDefines.h"
#import "RNSSearchBar.h"

#import <React/RCTComponent.h>

#import <React/RCTConversions.h>
#import <React/RCTFabricComponentsPlugins.h>
#import <react/renderer/components/rnscreens/ComponentDescriptors.h>
#import <react/renderer/components/rnscreens/EventEmitters.h>
#import <react/renderer/components/rnscreens/Props.h>
#import "RNSConvert.h"

namespace react = facebook::react;

#if !TARGET_OS_TV
// UIKit's search text field observes its text storage's edits on the main queue, filtered by the
// storage's address, and never removes that observer; the search bar also replaces its field when the
// search placement changes. Once a storage is freed, React Native can create one at the same address on
// the JS thread to measure text, and that edit then waits for the main thread while it holds the text
// measurement lock; a main thread that measures text at that moment deadlocks. An observer filtered by a
// freed object can never fire for it, so that registration is removed as its storage is freed. Only
// UIKit's own registration is touched: its block function is learned while the first search controller
// is created, and every other observer keeps its lifetime.
@interface RNSSearchFieldObserverRemover : NSObject
@end

@implementation RNSSearchFieldObserverRemover {
  // Weak, so the storage this remover is attached to adds no reference to UIKit's observer.
  __weak id _observer;
}

- (instancetype)initWithObserver:(id)observer
{
  if (self = [super init]) {
    _observer = observer;
  }
  return self;
}

- (void)dealloc
{
  id observer = _observer;
  if (observer != nil) {
    [NSNotificationCenter.defaultCenter removeObserver:observer];
  }
}

@end

static id (*RNSAddObserverWithBlock)(id, SEL, NSNotificationName, id, NSOperationQueue *, void (^)(NSNotification *));
static BOOL RNSLearningSearchFieldObserver = NO;
static std::atomic<void *> RNSSearchFieldObserverInvoke{nullptr};

static void *RNSBlockInvoke(id block)
{
  // The Clang block ABI places the invoke function after isa, flags and reserved.
  struct RNSBlockLayout {
    void *isa;
    int flags;
    int reserved;
    void *invoke;
  };
  return ((__bridge struct RNSBlockLayout *)block)->invoke;
}

static BOOL RNSIsUIKitFunction(void *function)
{
  Dl_info functionImage;
  Dl_info uikitImage;
  return dladdr(function, &functionImage) != 0 && dladdr((__bridge void *)UISearchTextField.class, &uikitImage) != 0 &&
      functionImage.dli_fbase == uikitImage.dli_fbase;
}

static id RNSAddObserverRemovedWithSearchField(
    NSNotificationCenter *center,
    SEL selector,
    NSNotificationName name,
    id object,
    NSOperationQueue *queue,
    void (^block)(NSNotification *))
{
  id observer = RNSAddObserverWithBlock(center, selector, name, object, queue, block);
  if (center != NSNotificationCenter.defaultCenter || queue != NSOperationQueue.mainQueue || block == nil ||
      ![name isEqualToString:NSTextStorageDidProcessEditingNotification] ||
      ![object isKindOfClass:NSTextStorage.class]) {
    return observer;
  }
  void *invoke = RNSBlockInvoke(block);
  // Only the main thread creates search controllers, and only it reads the learning flag.
  if (NSThread.isMainThread && RNSLearningSearchFieldObserver && RNSSearchFieldObserverInvoke.load() == nullptr &&
      RNSIsUIKitFunction(invoke)) {
    RNSSearchFieldObserverInvoke.store(invoke);
  }
  if (invoke == RNSSearchFieldObserverInvoke.load()) {
    auto *remover = [[RNSSearchFieldObserverRemover alloc] initWithObserver:observer];
    objc_setAssociatedObject(object, (__bridge const void *)remover, remover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return observer;
}

#endif // !TARGET_OS_TV

@implementation RNSSearchBar {
  UISearchController *_controller;
  UIColor *_textColor;
  BOOL _focusRequested;
  BOOL _programmaticDismissal;
  BOOL _cancelReported;
  BOOL _dismissalIsNavigation;
  NSString *_lastSearchText;

  // We use those booleans to log a warning if user attempts to restore
  // default behavior after setting explicit value for the prop.
  BOOL _isObscureBackgroundSet;
  BOOL _isHideNavigationBarSet;
}

@synthesize controller = _controller;

#if !TARGET_OS_TV
+ (void)initialize
{
  if (self != RNSSearchBar.class) {
    return;
  }
  Method method =
      class_getInstanceMethod(NSNotificationCenter.class, @selector(addObserverForName:object:queue:usingBlock:));
  // Store the original first: other threads call the replacement as soon as it is installed.
  RNSAddObserverWithBlock = (decltype(RNSAddObserverWithBlock))method_getImplementation(method);
  method_setImplementation(method, (IMP)RNSAddObserverRemovedWithSearchField);
}
#endif // !TARGET_OS_TV

- (instancetype)init
{
  if (self = [super init]) {
    static const auto defaultProps = std::make_shared<const react::RNSSearchBarProps>();
    _props = defaultProps;
    [self initCommonProps];
  }
  return self;
}

- (void)initCommonProps
{
#if !TARGET_OS_TV
  // The controller's search field registers UIKit's observer while it is created.
  RNSLearningSearchFieldObserver = RNSSearchFieldObserverInvoke.load() == nullptr;
  _controller = [[UISearchController alloc] initWithSearchResultsController:nil];
  RNSLearningSearchFieldObserver = NO;
#else
  // on TVOS UISearchController must contain searchResultsController.
  _controller = [[UISearchController alloc] initWithSearchResultsController:[UIViewController new]];
#endif

  _controller.searchBar.delegate = self;
  _controller.delegate = self;
  _controller.searchResultsUpdater = self;
  _lastSearchText = @"";

  _isObscureBackgroundSet = NO;
  _isHideNavigationBarSet = NO;

  _hideWhenScrolling = YES;
  _placement = RNSSearchBarPlacementAutomatic;

  _allowToolbarIntegration = YES;
}

- (void)emitOnFocusEvent
{
  if (_eventEmitter != nullptr) {
    std::dynamic_pointer_cast<const react::RNSSearchBarEventEmitter>(_eventEmitter)
        ->onSearchFocus(react::RNSSearchBarEventEmitter::OnSearchFocus{});
  }
}

- (void)emitOnBlurEvent
{
  if (_eventEmitter != nullptr) {
    std::dynamic_pointer_cast<const react::RNSSearchBarEventEmitter>(_eventEmitter)
        ->onSearchBlur(react::RNSSearchBarEventEmitter::OnSearchBlur{});
  }
}

- (void)emitOnSearchButtonPressEventWithText:(NSString *)text
{
  if (_eventEmitter != nullptr) {
    std::dynamic_pointer_cast<const react::RNSSearchBarEventEmitter>(_eventEmitter)
        ->onSearchButtonPress(
            react::RNSSearchBarEventEmitter::OnSearchButtonPress{.text = RCTStringFromNSString(text)});
  }
}

- (void)emitOnCancelButtonPressEvent
{
  if (_eventEmitter != nullptr) {
    std::dynamic_pointer_cast<const react::RNSSearchBarEventEmitter>(_eventEmitter)
        ->onCancelButtonPress(react::RNSSearchBarEventEmitter::OnCancelButtonPress{});
  }
}

- (void)emitOnChangeTextEventWithText:(NSString *)text
{
  if (_eventEmitter != nullptr) {
    std::dynamic_pointer_cast<const react::RNSSearchBarEventEmitter>(_eventEmitter)
        ->onChangeText(react::RNSSearchBarEventEmitter::OnChangeText{.text = RCTStringFromNSString(text)});
  }
}

- (void)setObscureBackground:(RNSOptionalBoolean)obscureBackground
{
  switch (obscureBackground) {
    case RNSOptionalBooleanTrue:
      [_controller setObscuresBackgroundDuringPresentation:YES];
      _isObscureBackgroundSet = YES;
      break;

    case RNSOptionalBooleanFalse:
      [_controller setObscuresBackgroundDuringPresentation:NO];
      _isObscureBackgroundSet = YES;
      break;

    default:
      if (_isObscureBackgroundSet) {
        RCTLogWarn(@"[RNScreens] Dynamically restoring obscureBackground to default native behavior is unsupported.");
      }
      break;
  }
}

- (void)setHideNavigationBar:(RNSOptionalBoolean)hideNavigationBar
{
  switch (hideNavigationBar) {
    case RNSOptionalBooleanTrue:
      [_controller setHidesNavigationBarDuringPresentation:YES];
      _isHideNavigationBarSet = YES;
      break;

    case RNSOptionalBooleanFalse:
      [_controller setHidesNavigationBarDuringPresentation:NO];
      _isHideNavigationBarSet = YES;
      break;

    default:
      if (_isHideNavigationBarSet) {
        RCTLogWarn(@"[RNScreens] Dynamically restoring hideNavigationBar to default native behavior is unsupported.");
      }
      break;
  }
}

- (void)setHideWhenScrolling:(BOOL)hideWhenScrolling
{
  _hideWhenScrolling = hideWhenScrolling;
}

- (void)setAutoCapitalize:(UITextAutocapitalizationType)autoCapitalize
{
  [_controller.searchBar setAutocapitalizationType:autoCapitalize];
}

- (void)setPlaceholder:(NSString *)placeholder
{
  [_controller.searchBar setPlaceholder:placeholder];
}

- (void)setBarTintColor:(UIColor *)barTintColor
{
#if !TARGET_OS_TV
  [_controller.searchBar.searchTextField setBackgroundColor:barTintColor];
#endif
}

- (void)setTintColor:(UIColor *)tintColor
{
  [_controller.searchBar setTintColor:tintColor];
}

- (void)setTextColor:(UIColor *)textColor
{
#if !TARGET_OS_TV
  _textColor = textColor;
  [_controller.searchBar.searchTextField setTextColor:_textColor];
#endif
}

- (void)setCancelButtonText:(NSString *)text
{
  [_controller.searchBar setValue:text forKey:@"cancelButtonText"];
}

- (void)setCancelButtonHidden:(BOOL)cancelButtonHidden
{
  _cancelButtonHidden = cancelButtonHidden;
#if !TARGET_OS_TV
  // Configure this before focus: changing the cancel control during activation
  // rebuilds UIKit's integrated search field and can dismiss its keyboard.
  [_controller.searchBar setShowsCancelButton:NO animated:NO];
  _controller.automaticallyShowsCancelButton = !cancelButtonHidden;
#endif
}

- (void)hideCancelButton
{
#if !TARGET_OS_TV
  if (!_controller.automaticallyShowsCancelButton) {
    [_controller.searchBar setShowsCancelButton:NO animated:YES];
  } else {
    // On iOS 13+ UISearchController automatically shows/hides cancel button
    // https://developer.apple.com/documentation/uikit/uisearchcontroller/3152926-automaticallyshowscancelbutton?language=objc
  }
#endif
}

- (void)showCancelButton
{
#if !TARGET_OS_TV
  if (!_cancelButtonHidden && !_controller.automaticallyShowsCancelButton) {
    [_controller.searchBar setShowsCancelButton:YES animated:YES];
  } else {
    // On iOS 13+ UISearchController automatically shows/hides cancel button
    // https://developer.apple.com/documentation/uikit/uisearchcontroller/3152926-automaticallyshowscancelbutton?language=objc
  }
#endif
}

#if RNS_IPHONE_OS_VERSION_AVAILABLE(16_0) && !TARGET_OS_TV
- (UINavigationItemSearchBarPlacement)placementAsUINavigationItemSearchBarPlacement API_AVAILABLE(ios(16.0))
    API_UNAVAILABLE(tvos, watchos)
{
  switch (_placement) {
    case RNSSearchBarPlacementStacked:
      return UINavigationItemSearchBarPlacementStacked;
    case RNSSearchBarPlacementAutomatic:
      return UINavigationItemSearchBarPlacementAutomatic;
    case RNSSearchBarPlacementInline:
      return UINavigationItemSearchBarPlacementInline;
#if RNS_IPHONE_OS_VERSION_AVAILABLE(26_0)
    case RNSSearchBarPlacementIntegrated:
      if (@available(iOS 26, *)) {
        return UINavigationItemSearchBarPlacementIntegrated;
      } else {
        return UINavigationItemSearchBarPlacementInline;
      }
    case RNSSearchBarPlacementIntegratedButton:
      if (@available(iOS 26, *)) {
        return UINavigationItemSearchBarPlacementIntegratedButton;
      } else {
        return UINavigationItemSearchBarPlacementInline;
      }
    case RNSSearchBarPlacementIntegratedCentered:
      if (@available(iOS 26, *)) {
        return UINavigationItemSearchBarPlacementIntegratedCentered;
      } else {
        return UINavigationItemSearchBarPlacementInline;
      }
#else // Check for iOS >= 26
    case RNSSearchBarPlacementIntegrated:
    case RNSSearchBarPlacementIntegratedButton:
    case RNSSearchBarPlacementIntegratedCentered:
      return UINavigationItemSearchBarPlacementInline;
#endif // Check for iOS >= 26
    default:
      RCTLogError(@"[RNScreens] unsupported search bar placement");
      return UINavigationItemSearchBarPlacementStacked;
  }
}
#endif // Check for iOS >= 16 && !TARGET_OS_TV

#pragma mark delegate methods

- (BOOL)searchHostIsNavigating
{
  UIViewController *host = _controller.presentingViewController;
  UINavigationController *navigation = host.navigationController;
  id<UIViewControllerTransitionCoordinator> transition = navigation.transitionCoordinator;
  // The search controller's own presentation is not a navigation away from its host.
  BOOL changingScreens = transition != nil &&
      [transition viewControllerForKey:UITransitionContextFromViewControllerKey] != _controller &&
      [transition viewControllerForKey:UITransitionContextToViewControllerKey] != _controller;
  return host.isBeingDismissed || host.isMovingFromParentViewController ||
      (navigation != nil && (navigation.topViewController != host || changingScreens));
}

- (void)willPresentSearchController:(UISearchController *)searchController
{
  _programmaticDismissal = NO;
  _cancelReported = NO;
  _dismissalIsNavigation = NO;
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
  _dismissalIsNavigation = [self searchHostIsNavigating];
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
#if !TARGET_OS_TV
  // Integrated search can replace its field when collapsing, while its header stays mounted.
  UIView *header =
      [self.navigationItemDelegate isKindOfClass:UIView.class] ? (UIView *)self.navigationItemDelegate : nil;
  if (!_programmaticDismissal && !_cancelReported && !_dismissalIsNavigation && ![self searchHostIsNavigating] &&
      (searchController.searchBar.window != nil || header.window != nil) &&
      searchController.searchBar.text.length == 0) {
    [self searchBarCancelButtonClicked:searchController.searchBar];
  }
#endif
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
  // UIKit also updates results for programmatic restoration and during navigation.
  if (_programmaticDismissal || _dismissalIsNavigation || [self searchHostIsNavigating]) {
    return;
  }
  NSString *text = searchController.searchBar.text ?: @"";
  if (![_lastSearchText isEqualToString:text]) {
    _lastSearchText = [text copy];
    [self emitOnChangeTextEventWithText:text];
  }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
#if !TARGET_OS_TV
  // for some reason, the color does not change when set at the beginning,
  // so we apply it again here
  if (_textColor != nil) {
    [_controller.searchBar.searchTextField setTextColor:_textColor];
  }
#endif

  [self showCancelButton];
  [self becomeFirstResponder];
  [self emitOnFocusEvent];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  [self emitOnBlurEvent];
  [self hideCancelButton];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
  [self updateSearchResultsForSearchController:_controller];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [self emitOnSearchButtonPressEventWithText:_controller.searchBar.text];
}

#if !TARGET_OS_TV
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
  if (_cancelReported) {
    return;
  }
  _cancelReported = YES;
  _focusRequested = NO;
  BOOL textChanged = ![_lastSearchText isEqualToString:@""];
  [self setText:@""];
  [self resignFirstResponder];
  [self hideCancelButton];

  [self emitOnCancelButtonPressEvent];
  if (textChanged) {
    [self emitOnChangeTextEventWithText:_controller.searchBar.text];
  }
}
#endif // !TARGET_OS_TV

- (void)blur
{
  _focusRequested = NO;
  [_controller.searchBar resignFirstResponder];
}

- (void)focus
{
  _focusRequested = YES;
  // Fabric can attach search and request focus in the same mounting transaction.
  __weak RNSSearchBar *weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    RNSSearchBar *strongSelf = weakSelf;
    if (strongSelf == nil || !strongSelf->_focusRequested) {
      return;
    }
    strongSelf->_focusRequested = NO;
#if !TARGET_OS_TV
    // Integrated search replaces its field during layout. The configuration view
    // is not mounted, so lay out its header's window before focusing that field.
    id<RNSSearchBarNavigationItemDelegate> header = strongSelf.navigationItemDelegate;
    if ([header isKindOfClass:UIView.class]) {
      [((UIView *)header).window layoutIfNeeded];
    }
    [strongSelf->_controller.searchBar.searchTextField becomeFirstResponder];
#else
    [strongSelf->_controller.searchBar becomeFirstResponder];
#endif
  });
}

- (void)clearText
{
  [self setText:@""];
}

- (void)toggleCancelButton:(BOOL)flag
{
#if !TARGET_OS_TV
  [_controller.searchBar setShowsCancelButton:flag && !_cancelButtonHidden animated:YES];
#endif
}

- (void)setText:(NSString *)text
{
  _lastSearchText = [text copy] ?: @"";
  [_controller.searchBar setText:text];
}

- (void)setActive:(BOOL)active
{
  if (!active) {
    _focusRequested = NO;
    _programmaticDismissal = YES;
  } else {
    _programmaticDismissal = NO;
  }
  // Search can remain expanded after the keyboard is dismissed or its host reappears.
  // Becoming first responder belongs to the separate focus command.
  _controller.active = active;
}

- (void)cancelSearch
{
#if !TARGET_OS_TV
  [self searchBarCancelButtonClicked:_controller.searchBar];
  _controller.active = NO;
#endif
}

#pragma mark-- Fabric specific

- (void)updateProps:(react::Props::Shared const &)props oldProps:(react::Props::Shared const &)oldProps
{
  const auto &oldScreenProps = *std::static_pointer_cast<const react::RNSSearchBarProps>(_props);
  const auto &newScreenProps = *std::static_pointer_cast<const react::RNSSearchBarProps>(props);

  if (oldScreenProps.hideWhenScrolling != newScreenProps.hideWhenScrolling) {
    [self setHideWhenScrolling:newScreenProps.hideWhenScrolling];
  }

  if (oldScreenProps.cancelButtonHidden != newScreenProps.cancelButtonHidden) {
    self.cancelButtonHidden = newScreenProps.cancelButtonHidden;
  }

  if (oldScreenProps.cancelButtonText != newScreenProps.cancelButtonText) {
    [self setCancelButtonText:RCTNSStringFromStringNilIfEmpty(newScreenProps.cancelButtonText)];
  }

  if (oldScreenProps.obscureBackground != newScreenProps.obscureBackground) {
    [self
        setObscureBackground:[RNSConvert
                                 RNSOptionalBooleanFromRNSSearchBarObscureBackground:newScreenProps.obscureBackground]];
  }

  if (oldScreenProps.hideNavigationBar != newScreenProps.hideNavigationBar) {
    [self
        setHideNavigationBar:[RNSConvert
                                 RNSOptionalBooleanFromRNSSearchBarHideNavigationBar:newScreenProps.hideNavigationBar]];
  }

  if (oldScreenProps.placeholder != newScreenProps.placeholder) {
    [self setPlaceholder:RCTNSStringFromStringNilIfEmpty(newScreenProps.placeholder)];
  }

#if !TARGET_OS_VISION
  if (oldScreenProps.autoCapitalize != newScreenProps.autoCapitalize) {
    [self setAutoCapitalize:[RNSConvert UITextAutocapitalizationTypeFromCppEquivalent:newScreenProps.autoCapitalize]];
  }
#endif

  if (oldScreenProps.tintColor != newScreenProps.tintColor) {
    [self setTintColor:RCTUIColorFromSharedColor(newScreenProps.tintColor)];
  }

  if (oldScreenProps.barTintColor != newScreenProps.barTintColor) {
    [self setBarTintColor:RCTUIColorFromSharedColor(newScreenProps.barTintColor)];
  }

  if (oldScreenProps.textColor != newScreenProps.textColor) {
    [self setTextColor:RCTUIColorFromSharedColor(newScreenProps.textColor)];
  }

  if (oldScreenProps.placement != newScreenProps.placement) {
    self.placement = [RNSConvert RNSScreenSearchBarPlacementFromCppEquivalent:newScreenProps.placement];
  }

  if (oldScreenProps.allowToolbarIntegration != newScreenProps.allowToolbarIntegration) {
    self.allowToolbarIntegration = newScreenProps.allowToolbarIntegration;
  }

  BOOL navigationItemDidChange = oldScreenProps.hideWhenScrolling != newScreenProps.hideWhenScrolling ||
      oldScreenProps.placement != newScreenProps.placement ||
      oldScreenProps.allowToolbarIntegration != newScreenProps.allowToolbarIntegration;

  [super updateProps:props oldProps:oldProps];

  if (navigationItemDidChange) {
    [self.navigationItemDelegate searchBarDidUpdateNavigationItem:self];
  }
}

+ (react::ComponentDescriptorProvider)componentDescriptorProvider
{
  return react::concreteComponentDescriptorProvider<react::RNSSearchBarComponentDescriptor>();
}

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
  RCTRNSSearchBarHandleCommand(self, commandName, args);
}

+ (BOOL)shouldBeRecycled
{
  // Recycling RNSSearchBar causes multiple bugs on iOS 26+, resulting in search bar
  // not appearing at all.
  // Details: https://github.com/software-mansion/react-native-screens/pull/3168
  return NO;
}

#pragma mark - Dynamic frameworks support

// Needed because of this: https://github.com/facebook/react-native/pull/37274
#ifdef RCT_DYNAMIC_FRAMEWORKS
+ (void)load
{
  [super load];
}
#endif // RCT_DYNAMIC_FRAMEWORKS

@end

Class<RCTComponentViewProtocol> RNSSearchBarCls(void)
{
  return RNSSearchBar.class;
}

@implementation RNSSearchBarManager

RCT_EXPORT_MODULE()

@end
