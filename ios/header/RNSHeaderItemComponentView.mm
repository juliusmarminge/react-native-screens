#import "RNSHeaderItemComponentView.h"
#import "RNSConversions-Stack.h"
#import "RNSConversions.h"
#import "RNSDefines.h"
#import "RNSHeaderIconMapper.h"
#import "RNSHeaderItemEventEmitter.h"
#import "RNSHeaderItemShadowStateProxy.h"
#import "RNSHeaderMenuCoordinator.h"
#import "RNSHeaderMenuData.h"
#import "RNSHeaderMenuMapper.h"

#import <React/RCTConversions.h>
#import <React/RCTLog.h>
#import <react/renderer/components/rnscreens/Props.h>
#import <react/renderer/components/rnscreens/RCTComponentViewHelpers.h>
#import <react/renderer/components/rnscreens/RNSHeaderItemComponentDescriptor.h>

namespace react = facebook::react;

@implementation RNSHeaderItemComponentView {
  BOOL _didSetHeaderItemPlacement;

  std::shared_ptr<const react::RNSHeaderItemShadowNode::ConcreteState> _state;
  RNSHeaderItemShadowStateProxy *_Nonnull _shadowStateProxy;
  RNSHeaderItemEventEmitter *_Nonnull _headerItemEventEmitter;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const react::RNSHeaderItemIOSProps>();
    _props = defaultProps;
    [self resetProps];
    _shadowStateProxy = [[RNSHeaderItemShadowStateProxy alloc] initWithHeaderItemView:self];
    _headerItemEventEmitter = [RNSHeaderItemEventEmitter new];

    // For custom items (header subviews), we rely on `intrinsicContentSize`
    // which passes correct view size from layoutMetrics to iOS
    // `intrinsicContentSize` is queried only when opted out of default constraints
    self.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return self;
}

- (void)resetProps
{
  _itemId = nil;
  _identifier = nil;
  [self setTitleProp:nil];
  [self setIconProp:nil];
  [self setMenuProp:nil];
  _placement = RNSHeaderItemPlacementTrailing;
  _didSetHeaderItemPlacement = NO;
  _respondsToOnPress = NO;
  _hidesSharedBackground = NO;
}

- (void)setTitleProp:(NSString *)titleProp
{
  _titleProp = titleProp;
  _title = titleProp;
}

- (void)setIconProp:(RNSHeaderIconData *)iconProp
{
  _iconProp = iconProp;
  _icon = iconProp;
}

- (void)setMenuProp:(RNSHeaderMenuData *)menuProp
{
  _menuProp = menuProp;
  _menu = menuProp;
}

- (void)emitOnPress
{
  [_headerItemEventEmitter emitOnPress];
}

- (void)updateMenuElementWithId:(NSString *)elementId
                    withElement:(id<RNSHeaderMenuElement>)newElement
                     parentMenu:(nullable RNSHeaderMenuData *)parentMenu
{
  if (parentMenu == nil) {
    _menu = (RNSHeaderMenuData *)newElement;
  } else {
    _menu = [RNSHeaderMenuCoordinator menu:_menu replacingChildWithId:elementId withElement:newElement];
  }
  [_invalidationDelegate headerItemMenuDidUpdateFromCommandWithId:_itemId];
}

#pragma mark - RNSHeaderItemDataProviding

- (RNSHeaderItemAxisBehavior)axisBehavior
{
  const auto &props = *std::static_pointer_cast<const react::RNSHeaderItemIOSProps>(_props);
  switch (props.axisBehavior) {
    case react::RNSHeaderItemIOSAxisBehavior::Automatic:
      return RNSHeaderItemAxisBehaviorAutomatic;
    case react::RNSHeaderItemIOSAxisBehavior::HorizontalOnly:
      return RNSHeaderItemAxisBehaviorHorizontalOnly;
    case react::RNSHeaderItemIOSAxisBehavior::VerticalPreferred:
      return RNSHeaderItemAxisBehaviorVerticalPreferred;
  }
}

- (nullable UIView *)customView
{
  return self.subviews.count > 0 ? self : nil;
}

#pragma mark - RNSViewFrameChangeDelegate

- (void)viewFrameDidChange:(nonnull UINavigationBar *)navigationBar
{
  if (_state == nullptr || self.superview == nil) {
    return;
  }

  CGRect frameInNavBar = [self convertRect:self.bounds toView:navigationBar];
  [_shadowStateProxy updateShadowStateWithFrame:frameInNavBar];
}

#pragma mark - RCTComponentViewProtocol

- (void)mountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  [super mountChildComponentView:childComponentView index:index];

  // An existing item may have transitioned from label-only to custom view,
  // and needs to be rebuilt.
  [_invalidationDelegate headerItemDidInvalidateWithId:_itemId];
}

- (void)unmountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  [super unmountChildComponentView:childComponentView index:index];

  // An existing item may have transitioned from custom view to label-only,
  // and needs to be rebuilt.
  [_invalidationDelegate headerItemDidInvalidateWithId:_itemId];
}

- (void)updateState:(const react::State::Shared &)state oldState:(const react::State::Shared &)oldState
{
  _state = std::static_pointer_cast<const react::RNSHeaderItemShadowNode::ConcreteState>(state);
}

- (react::RNSHeaderItemShadowNode::ConcreteState::Shared)state
{
  return _state;
}

// (adapted from #3489)
// UIKit controls our position in the navigation bar for all placements.
// Do NOT call super — it would set the full frame (including the shadow node's
// origin correction) and fight with UIKit's positioning.
RNS_IGNORE_SUPER_CALL_BEGIN
- (void)updateLayoutMetrics:(const react::LayoutMetrics &)layoutMetrics
           oldLayoutMetrics:(const react::LayoutMetrics &)oldLayoutMetrics
{
  CGRect frame = RCTCGRectFromRect(layoutMetrics.frame);
  if (!std::isfinite(frame.size.width) || !std::isfinite(frame.size.height)) {
    return;
  }

  BOOL sizeHasChanged = _layoutMetrics.frame.size != layoutMetrics.frame.size;
  if (sizeHasChanged) {
    // Store layout metrics for `intrinsicContentSize`
    _layoutMetrics = layoutMetrics;
    [self invalidateIntrinsicContentSize];
    // Update view bounds. Irrespective of intrinsic content size, this seems to be required
    // for largeTitle to be laid out correctly within its host _UINavigationBarLargeTitleView
    // and for UINavigationBar height to acknowledge the subview
    self.bounds = CGRect(CGPointZero, frame.size);
  }
}
RNS_IGNORE_SUPER_CALL_END

- (CGSize)intrinsicContentSize
{
  // UIKit queries this value for views that opted out of `translateAutoresizingMaskIntoContraints` - all custom header
  // items. Native views use this property to communicate their size when UIKit is not able to guess correctly. We
  // leverage this to return the size from the most recent `layoutMetrics`.
  return RCTCGSizeFromSize(_layoutMetrics.frame.size);
}

- (void)updateProps:(const react::Props::Shared &)props oldProps:(const react::Props::Shared &)oldProps
{
  const auto &newItemProps = *std::static_pointer_cast<const react::RNSHeaderItemIOSProps>(props);
  const auto &oldItemProps = *std::static_pointer_cast<const react::RNSHeaderItemIOSProps>(_props);

  BOOL needsUpdate = oldItemProps.axisBehavior != newItemProps.axisBehavior;
  BOOL menuDidChange = NO;

  if (oldItemProps.itemId != newItemProps.itemId) {
    _itemId = RCTNSStringFromStringNilIfEmpty(newItemProps.itemId);
  }

  if (oldItemProps.identifier != newItemProps.identifier) {
    _identifier = RCTNSStringFromStringNilIfEmpty(newItemProps.identifier);
    needsUpdate = YES;
  }

  if (oldItemProps.placement != newItemProps.placement) {
    if (_didSetHeaderItemPlacement) {
      RCTLogWarn(@"[RNScreens] Changing header item placement at runtime is not supported");
    } else {
      _placement =
          rnscreens::conversion::convert<RNSHeaderItemPlacement>(newItemProps.placement);
    }
  }
  _didSetHeaderItemPlacement = YES;

  if (oldItemProps.title != newItemProps.title) {
    [self setTitleProp:RCTNSStringFromStringNilIfEmpty(newItemProps.title)];
    needsUpdate = YES;
  }

  if (oldItemProps.icon != newItemProps.icon) {
    [self setIconProp:[RNSHeaderIconMapper
                          iconFromDictionary:rnscreens::conversion::RNSConvertFollyDynamicToId(newItemProps.icon)]];
    needsUpdate = YES;
  }

  if (oldItemProps.menu != newItemProps.menu) {
    [self setMenuProp:[RNSHeaderMenuMapper
                          menuFromDictionary:rnscreens::conversion::RNSConvertFollyDynamicToId(newItemProps.menu)]];
    menuDidChange = YES;
  }

  if (oldItemProps.respondsToOnPress != newItemProps.respondsToOnPress) {
    _respondsToOnPress = newItemProps.respondsToOnPress;
    needsUpdate = YES;
  }

  if (oldItemProps.hidesSharedBackground != newItemProps.hidesSharedBackground) {
    _hidesSharedBackground = newItemProps.hidesSharedBackground;
    needsUpdate = YES;
  }

  [super updateProps:props oldProps:oldProps];

  if (needsUpdate) {
    // rebuilds the item; needs to rebuilds the menu, but keeps its state
    [_invalidationDelegate headerItemDidInvalidateWithId:_itemId];
  }

  if (menuDidChange) {
    // there are 3 distinct cases for rebuilding the menu
    // 1. only menu changed -- no item rebuilding, menu state reset
    // 2. some different prop changed -- item rebuilds, but menu should keep its state
    // 3. both menu and some other prop changed -- both item and menu rebuilds + menu state should be reset
    // If we don't have separate if-s, we won't cover all cases,
    // but unfortunately we're rebuilding the menu twice for 3. case.
    [_invalidationDelegate headerItemMenuDidChangeWithId:_itemId];
  }
}

- (void)updateEventEmitter:(const facebook::react::EventEmitter::Shared &)eventEmitter
{
  [super updateEventEmitter:eventEmitter];
  [_headerItemEventEmitter
      updateEventEmitter:std::static_pointer_cast<const react::RNSHeaderItemIOSEventEmitter>(eventEmitter)];
}

+ (react::ComponentDescriptorProvider)componentDescriptorProvider
{
  return react::concreteComponentDescriptorProvider<react::RNSHeaderItemComponentDescriptor>();
}

+ (BOOL)shouldBeRecycled
{
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

Class<RCTComponentViewProtocol> RNSHeaderItemComponentViewCls(void)
{
  return RNSHeaderItemComponentView.class;
}
