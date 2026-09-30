#import "RNSSplitScreenController.h"

#import <React/RCTAssert.h>
#import "RNSHeaderCoordinator.h"
#import "RNSSplitHostComponentView.h"
#import "RNSSplitHostController.h"
#import "RNSSplitScreenComponentView.h"

@implementation RNSSplitScreenController {
  RNSSplitScreenComponentView *_splitScreenComponentView;
}

- (instancetype)initWithSplitScreenComponentView:(RNSSplitScreenComponentView *)splitScreenComponentView
{
  if (self = [super init]) {
    _splitScreenComponentView = splitScreenComponentView;
    _headerCoordinator = [[RNSHeaderCoordinator alloc] initWithScreenController:self];
  }

  return self;
}

/**
 * @brief Searching for the SplitHost controller
 *
 * It checks whether the parent controller is our host controller.
 * If we're outside the structure, e. g. for inspector represented as a modal,
 * we're searching for that controller using a reference that Screen keeps for Host component view.
 *
 * @return If found - a RNSSplitHostController instance, otherwise nil.
 */
- (nullable RNSSplitHostController *)findSplitHostController
{
  if ([self.splitViewController isKindOfClass:RNSSplitHostController.class]) {
    return (RNSSplitHostController *)self.splitViewController;
  }

  RNSSplitHostComponentView *splitHost = _splitScreenComponentView.splitHost;
  if (splitHost != nil) {
    return splitHost.splitHostController;
  }

  return nil;
}

- (BOOL)isInSplitHostSubtree
{
  return [self.splitViewController isKindOfClass:RNSSplitHostController.class];
}

#pragma mark - Signals

#pragma mark - Layout

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  // For modals, which are presented outside the SplitHost subtree (and RN hierarchy),
  // we're attaching our touch handler and we don't need to apply any offset corrections,
  // because it's positioned relatively to our RNSSplitScreenComponentView
  if (![self isInSplitHostSubtree]) {
    // A screen leaving its column has no navigation controller anymore; its frame is meaningless then.
    if (self.navigationController == nil) {
      return;
    }
    [_delegate splitScreenController:self didChangeColumnFrame:self.view.frame];
    return;
  }

  UIView *ancestorView = [self findSplitHostController].view;
  RCTAssert(ancestorView != nil, @"[RNScreens] Expected to find RNSSplitHost component for RNSSplitScreen component");

  [self reportColumnFrameInContextOfView:ancestorView];
}

- (void)columnPositioningDidChangeInSplitViewController:(UISplitViewController *)splitViewController
{
  [self reportColumnFrameInContextOfView:splitViewController.view];
}

- (void)reportColumnFrameInContextOfView:(UIView *)ancestorView
{
  // The column frame is the navigation controller's view frame, not the screen's: UIKit animates the screen view
  // during push and pop transitions, the column stays put.
  UIView *columnView = self.navigationController.view ?: self.view;
  CGRect frame = [columnView convertRect:columnView.bounds toView:ancestorView];
  [_delegate splitScreenController:self didChangeColumnFrame:frame];
}

#pragma mark - Events

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  // Without a header config the column keeps the system navigation bar, so the coordinator is not consulted.
  if (_splitScreenComponentView.headerConfig != nil) {
    [_headerCoordinator updateNavigationBarVisibilityAnimated:animated];
#if !TARGET_OS_TV
    [_headerCoordinator updateBackButtonMenuEnabled];
#endif // !TARGET_OS_TV
  }
  [_delegate splitScreenControllerWillAppear:self];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [_delegate splitScreenControllerDidAppear:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [_delegate splitScreenControllerWillDisappear:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [_delegate splitScreenControllerDidDisappear:self];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
  [super didMoveToParentViewController:parent];

  if (parent != nil) {
    return;
  }

#if !TARGET_OS_TV
  [_headerCoordinator clearAppliedBackButtonConfig];
#endif // !TARGET_OS_TV

  // A screen React still expects on the stack left it natively (e.g. the back button); a detached one was popped on
  // React's request.
  BOOL isNativeDismiss = _splitScreenComponentView.activityMode == RNSStackScreenActivityModeAttached;
  [_delegate splitScreenController:self didDismissNatively:isNativeDismiss];
}

@end
