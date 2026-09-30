#import "RNSHeaderMenuTrackerRegistry.h"
#import "RNSHeaderMenuToggleStateTracker.h"

@implementation RNSHeaderMenuTrackerRegistry {
  NSMutableDictionary<NSString *, RNSHeaderMenuToggleStateTracker *> *_trackers;
}

- (instancetype)init
{
  if (self = [super init]) {
    _trackers = [NSMutableDictionary new];
  }
  return self;
}

- (RNSHeaderMenuToggleStateTracker *)trackerForItemId:(NSString *)itemId
{
  RNSHeaderMenuToggleStateTracker *tracker = _trackers[itemId];
  if (tracker == nil) {
    tracker = [RNSHeaderMenuToggleStateTracker new];
    _trackers[itemId] = tracker;
  }
  return tracker;
}

- (void)resetTrackerForItemId:(NSString *)itemId
{
  _trackers[itemId] = [RNSHeaderMenuToggleStateTracker new];
}

- (void)clear
{
  [_trackers removeAllObjects];
}

@end
