#import "RNSSplitColumnFrameObserver.h"
#import "RNSSplitColumnFrameObserverDelegate.h"

static void *RNSSplitColumnViewFrameContext = &RNSSplitColumnViewFrameContext;

@implementation RNSSplitColumnFrameObserver {
  UINavigationController *__weak _navigationController;
  id<RNSSplitColumnFrameObserverDelegate> __weak _delegate;
  UIView *__weak _observedView;
}

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
                                    delegate:(id<RNSSplitColumnFrameObserverDelegate>)delegate
{
  if (self = [super init]) {
    _navigationController = navigationController;
    _delegate = delegate;
  }

  return self;
}

#pragma mark - Observing view frame changes

- (void)registerForViewFrameChanges
{
  [self unregisterForViewFrameChanges];

  UIView *view = _navigationController.viewIfLoaded;
  if (view == nil) {
    return;
  }

  [view addObserver:self
         forKeyPath:@"frame"
            options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
            context:RNSSplitColumnViewFrameContext];
  _observedView = view;
}

- (void)unregisterForViewFrameChanges
{
  [_observedView removeObserver:self forKeyPath:@"frame" context:RNSSplitColumnViewFrameContext];
  _observedView = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context
{
  if (context != RNSSplitColumnViewFrameContext) {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    return;
  }

  id oldValue = change[NSKeyValueChangeOldKey];
  id newValue = change[NSKeyValueChangeNewKey];
  if (![oldValue isKindOfClass:[NSValue class]] || ![newValue isKindOfClass:[NSValue class]]) {
    return;
  }

  CGRect oldFrame = [oldValue CGRectValue];
  CGRect newFrame = [newValue CGRectValue];

  if (!CGPointEqualToPoint(oldFrame.origin, newFrame.origin)) {
    UINavigationController *navigationController = _navigationController;
    if (navigationController != nil) {
      [_delegate frameObserver:self didChangeFrameOriginOfNavigationController:navigationController];
    }
  }
}

- (void)dealloc
{
  [self unregisterForViewFrameChanges];
}

@end
