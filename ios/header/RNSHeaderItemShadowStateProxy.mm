#import "RNSHeaderItemShadowStateProxy.h"
#import "RNSHeaderItemComponentView.h"

#import <React/RCTConversions.h>
#import <react/renderer/components/rnscreens/RNSHeaderItemComponentDescriptor.h>

namespace react = facebook::react;

@implementation RNSHeaderItemShadowStateProxy {
  RNSHeaderItemComponentView *__weak _headerItemView;
  CGRect _previousFrame;
}

- (instancetype)initWithHeaderItemView:(RNSHeaderItemComponentView *)headerItemView
{
  if (self = [super init]) {
    _headerItemView = headerItemView;
    [self initState];
  }
  return self;
}

- (void)initState
{
  _previousFrame = CGRectNull;
}

- (void)updateShadowStateWithFrame:(CGRect)frame
{
  if (CGRectEqualToRect(frame, _previousFrame)) {
    return;
  }
  if (_headerItemView.state == nullptr) {
    return;
  }
  auto newState = react::RNSHeaderItemState(RCTSizeFromCGSize(frame.size), RCTPointFromCGPoint(frame.origin));
  _headerItemView.state->updateState(std::move(newState));
  _previousFrame = frame;
}

- (void)invalidate
{
  [self initState];
}

@end
