#import "RNSStackNavigationController.h"
#import <React/RCTAssert.h>
#import <React/RCTSurfaceTouchHandler.h>
#import "RCTSurfaceTouchHandler+RNSUtility.h"
#import "RNSContainer.h"
#import "RNSDefines.h"
#import "RNSContainerItem.h"
#import "RNSLog.h"
#import "RNSParentContainerItemRegistry.h"
#import "RNSStackNavigationBar.h"
#import "RNSStackOperation.h"
#import "RNSStackScreenComponentEventEmitter.h"
#import "RNSStackScreenComponentView.h"
#import "RNSViewFrameChangeDelegate.h"

@interface RNSStackNavigationController ()
- (BOOL)shouldPreventNativePopToController:(UIViewController *)controller;
@end

#if !TARGET_OS_TV
@interface RNSStackPopGestureDelegate : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic, weak) RNSStackNavigationController *navigationController;
@property (nonatomic, weak) id<UIGestureRecognizerDelegate> originalDelegate;
@end

@implementation RNSStackPopGestureDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  RNSStackNavigationController *navigation = self.navigationController;
  if (navigation.viewControllers.count < 2)
    return NO;
  UIViewController *destination = navigation.viewControllers[navigation.viewControllers.count - 2];
  if ([navigation shouldPreventNativePopToController:destination])
    return NO;
  if ([self.originalDelegate respondsToSelector:_cmd]) {
    return [self.originalDelegate gestureRecognizerShouldBegin:gestureRecognizer];
  }
  return YES;
}

- (BOOL)respondsToSelector:(SEL)selector
{
  return [super respondsToSelector:selector] || [self.originalDelegate respondsToSelector:selector];
}

- (id)forwardingTargetForSelector:(SEL)selector
{
  return self.originalDelegate;
}
@end
#endif

@implementation RNSStackNavigationController {
  NSMutableArray<RNSPushOperation *> *_Nonnull _pendingPushOperations;
  NSMutableArray<RNSPopOperation *> *_Nonnull _pendingPopOperations;
  RNSParentContainerItemRegistry *_Nonnull _parentContainerRegistry;
  UIViewController *_emptyStackController;
  BOOL _performingReactUpdate;
#if !TARGET_OS_TV
  RNSStackPopGestureDelegate *_edgePopDelegate;
#if RNS_IPHONE_OS_VERSION_AVAILABLE(26_0)
  RNSStackPopGestureDelegate *_contentPopDelegate;
#endif
#endif
}

- (instancetype)init
{
#if !TARGET_OS_TV
  self = [super initWithNavigationBarClass:RNSStackNavigationBar.class toolbarClass:nil];
#else // !TARGET_OS_TV
  self = [super init];
#endif // !TARGET_OS_TV
  if (self != nil) {
    _navigationBarCoordinator = [RNSStackNavigationBarCoordinator new];
    [_navigationBarCoordinator initializeNavigationBarOfNavigationController:self];
    [self initState];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
#if !TARGET_OS_TV
  _edgePopDelegate = [RNSStackPopGestureDelegate new];
  _edgePopDelegate.navigationController = self;
  _edgePopDelegate.originalDelegate = self.interactivePopGestureRecognizer.delegate;
  self.interactivePopGestureRecognizer.delegate = _edgePopDelegate;
  [self.interactivePopGestureRecognizer addTarget:self action:@selector(cancelReactTouchesForPopGesture:)];
#if RNS_IPHONE_OS_VERSION_AVAILABLE(26_0)
  if (@available(iOS 26.0, *)) {
    _contentPopDelegate = [RNSStackPopGestureDelegate new];
    _contentPopDelegate.navigationController = self;
    _contentPopDelegate.originalDelegate = self.interactiveContentPopGestureRecognizer.delegate;
    self.interactiveContentPopGestureRecognizer.delegate = _contentPopDelegate;
    [self.interactiveContentPopGestureRecognizer addTarget:self action:@selector(cancelReactTouchesForPopGesture:)];
  }
#endif
#endif
}

#if !TARGET_OS_TV
- (void)cancelReactTouchesForPopGesture:(UIGestureRecognizer *)gestureRecognizer
{
  if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
    return;

  // A recognized back swipe consumes the active press, including when the pop
  // later cancels. Find the nearest RN handler in roots, sheets, or split columns.
  for (UIView *view = gestureRecognizer.view; view != nil; view = view.superview) {
    for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
      if ([recognizer isKindOfClass:RCTSurfaceTouchHandler.class]) {
        [(RCTSurfaceTouchHandler *)recognizer rnscreens_cancelTouches];
        return;
      }
    }
  }
}
#endif

// A parent column can be popped while its nested stack owns the guarded route.
- (RNSStackScreenComponentView *)preventedScreenInController:(UIViewController *)controller
{
  if ([controller.view isKindOfClass:RNSStackScreenComponentView.class]) {
    RNSStackScreenComponentView *screen = (RNSStackScreenComponentView *)controller.view;
    if (screen.activityMode == RNSStackScreenActivityModeAttached && screen.preventNativeDismiss)
      return screen;
  }
  if ([controller conformsToProtocol:@protocol(RNSContainerItem)]) {
    id<RNSContainer> nested = [(id<RNSContainerItem>)controller resolveNestedContainer];
    if ([nested isKindOfClass:UINavigationController.class]) {
      return [self preventedScreenInController:((UINavigationController *)nested).topViewController];
    }
  }
  return nil;
}

- (BOOL)shouldPreventNativePopToController:(UIViewController *)controller
{
  if (_performingReactUpdate)
    return NO;
  NSUInteger destinationIndex = [self.viewControllers indexOfObject:controller];
  if (destinationIndex == NSNotFound)
    return NO;
  for (NSUInteger index = self.viewControllers.count; index > destinationIndex + 1; index--) {
    RNSStackScreenComponentView *screen = [self preventedScreenInController:self.viewControllers[index - 1]];
    if (screen != nil) {
      [screen.reactEventEmitter emitOnNativeDismissPrevented];
      return YES;
    }
  }
  return NO;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
  if (self.viewControllers.count > 1 &&
      [self shouldPreventNativePopToController:self.viewControllers[self.viewControllers.count - 2]])
    return nil;
  return [super popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)controller animated:(BOOL)animated
{
  if ([self shouldPreventNativePopToController:controller])
    return nil;
  return [super popToViewController:controller animated:animated];
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
  if ([self shouldPreventNativePopToController:self.viewControllers.firstObject])
    return nil;
  return [super popToRootViewControllerAnimated:animated];
}

- (void)initState
{
  _pendingPushOperations = [NSMutableArray array];
  _pendingPopOperations = [NSMutableArray array];
  _parentContainerRegistry = [RNSParentContainerItemRegistry new];
}

- (void)setAllowsEmptyStack:(BOOL)allowsEmptyStack
{
  _allowsEmptyStack = allowsEmptyStack;
  if (allowsEmptyStack) {
    if (_emptyStackController == nil) {
      _emptyStackController = [UIViewController new];
    }
    if (self.viewControllers.count == 0) {
      [self setViewControllers:@[ _emptyStackController ] animated:NO];
    }
  } else if (self.topViewController == _emptyStackController) {
    [self setViewControllers:@[] animated:NO];
  }
}

- (BOOL)isStackEmpty
{
  return self.viewControllers.count == 0 || self.topViewController == _emptyStackController;
}

#pragma mark-- Layout

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  [_navigationBarFrameChangeDelegate viewFrameDidChange:self.navigationBar];
}

#pragma mark - RNSContainer

- (nullable UIScrollView *)resolveCurrentContentScrollView
{
  // We assume `topViewController` corresponds to the currently presented screen.
  UIViewController *topController = self.topViewController;
  if (![topController conformsToProtocol:@protocol(RNSContainerItem)]) {
    return nil;
  }
  return [(id<RNSContainerItem>)topController findContentScrollView];
}

- (void)attachToParentContainerItem
{
  [_parentContainerRegistry attachContainer:self];
}

- (void)detachFromParentContainerItem
{
  [_parentContainerRegistry detachContainer:self];
}

#pragma mark - View controller containment

- (void)didMoveToParentViewController:(UIViewController *)parent
{
  [super didMoveToParentViewController:parent];

  if (parent != nil) {
    [self attachToParentContainerItem];
  } else {
    [self detachFromParentContainerItem];
  }
}

- (BOOL)hasPendingOperations
{
  return _pendingPushOperations.count > 0 || _pendingPopOperations.count > 0;
}

- (void)enqueuePushOperation:(nonnull UIView<RNSStackScreenProviding> *)stackScreen
{
  RNSPushOperation *operation = [[RNSPushOperation alloc] initWithScreen:stackScreen];
  [_pendingPushOperations addObject:operation];
}

- (void)enqueuePopOperation:(nonnull UIView<RNSStackScreenProviding> *)stackScreen
{
  RNSPopOperation *operation = [[RNSPopOperation alloc] initWithScreen:stackScreen];
  [_pendingPopOperations addObject:operation];
}

- (void)performContainerUpdateIfNeeded
{
  // NOTE: We consider UINavigationController.viewControllers to be part of
  // the internal state of our stack implementation and expect it to be
  // *synchronously* updated by UIKit while we perform our pop and push operations
  //
  // The assertions below work under this assumption

  if (![self hasPendingOperations]) {
    return;
  }

  _performingReactUpdate = YES;
  for ([[maybe_unused]] RNSPopOperation *op in _pendingPopOperations) {
    RCTAssert(
        self.allowsEmptyStack ? !self.isStackEmpty : [self.viewControllers count] > 1,
        @"[RNScreens] Attempt to pop last screen from the stack");
    RCTAssert(self.topViewController == op.stackScreen.controller, @"[RNScreens] Attempt to pop non-top screen");
    if (self.allowsEmptyStack && self.viewControllers.count == 1) {
      // UIKit cannot show an empty nested navigation controller when the split is collapsed.
      [self setViewControllers:@[ _emptyStackController ] animated:NO];
    } else {
      // Intermediate pops must finish synchronously before starting the final transition.
      [self popViewControllerAnimated:op == _pendingPopOperations.lastObject];
    }
  }

  for (RNSPushOperation *op in _pendingPushOperations) {
    if (self.allowsEmptyStack && self.isStackEmpty) {
      // The first screen is the root, so the placeholder must not appear in its back stack.
      [self setViewControllers:@[ op.stackScreen.controller ] animated:NO];
    } else {
      [self pushViewController:op.stackScreen.controller animated:op == _pendingPushOperations.lastObject];
    }
  }

  RCTAssert(
      self.allowsEmptyStack || [self.viewControllers count] > 0,
      @"[RNScreens] Stack should never be empty after updates");

  _performingReactUpdate = NO;
  [self dumpStackModel];

  [_pendingPopOperations removeAllObjects];
  [_pendingPushOperations removeAllObjects];
}

#pragma mark - Debug

- (void)dumpStackModel
{
#ifdef RNS_DEBUG_LOGGING
  RNSLog(@"[RNScreens] StackContainer [%ld] MODEL BEGIN", self.view.tag);
  for (UIViewController *viewController in self.viewControllers) {
    if (viewController == _emptyStackController) {
      continue;
    }
    RNSLog(@"[RNScreens] %@", [(id<RNSStackScreenProviding>)viewController.view screenKey]);
  }
#endif // RNS_DEBUG_LOGGING
}

@end
