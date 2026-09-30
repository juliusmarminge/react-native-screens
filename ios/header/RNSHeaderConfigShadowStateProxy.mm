#import "RNSHeaderConfigShadowStateProxy.h"
#import "RNSHeaderConfigComponentView.h"

#import <React/RCTConversions.h>
#import <react/renderer/components/rnscreens/RNSHeaderConfigComponentDescriptor.h>

namespace react = facebook::react;

@implementation RNSHeaderConfigShadowStateProxy {
  RNSHeaderConfigComponentView *__weak _headerConfigView;
  CGRect _previousFrame;
}

- (instancetype)initWithHeaderConfigView:(RNSHeaderConfigComponentView *)headerConfigView
{
  if (self = [super init]) {
    _headerConfigView = headerConfigView;
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
  if (_headerConfigView.state == nullptr) {
    return;
  }
  auto newState = react::RNSHeaderConfigState(RCTSizeFromCGSize(frame.size), RCTPointFromCGPoint(frame.origin));
  _headerConfigView.state->updateState(std::move(newState));
  _previousFrame = frame;
}

- (void)invalidate
{
  [self initState];
}

@end
