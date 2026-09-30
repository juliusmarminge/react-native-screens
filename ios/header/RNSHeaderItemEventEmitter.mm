#import "RNSHeaderItemEventEmitter.h"
#import <React/RCTLog.h>

@implementation RNSHeaderItemEventEmitter {
  std::shared_ptr<const react::RNSHeaderItemIOSEventEmitter> _reactEventEmitter;
}

- (BOOL)emitOnPress
{
  if (_reactEventEmitter != nullptr) {
    _reactEventEmitter->onHeaderItemPress({});
    return YES;
  } else {
    RCTLogWarn(@"[RNScreens] Skipped OnHeaderItemPress event emission due to nullish emitter");
    return NO;
  }
}

- (void)updateEventEmitter:(const std::shared_ptr<const react::RNSHeaderItemIOSEventEmitter> &)emitter
{
  _reactEventEmitter = emitter;
}

@end
