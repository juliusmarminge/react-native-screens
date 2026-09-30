#pragma once

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RNSSplitColumnFrameObserverDelegate;

/**
 * @class RNSSplitColumnFrameObserver
 * @brief Class responsible for observing frame origin changes of a column navigation controller's view.
 */
@interface RNSSplitColumnFrameObserver : NSObject

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
                                    delegate:(nullable id<RNSSplitColumnFrameObserverDelegate>)delegate;

/**
 * Registers KVO for the frame of navigation controller's view.
 * It must be called after the navigation controller's view is loaded.
 */
- (void)registerForViewFrameChanges;
/**
 * Removes the KVO registration set up by `registerForViewFrameChanges`.
 */
- (void)unregisterForViewFrameChanges;

@end

NS_ASSUME_NONNULL_END
