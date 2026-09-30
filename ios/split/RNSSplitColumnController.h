#pragma once

#import <UIKit/UIKit.h>
#import "RNSStackScreenProviding.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RNSSplitColumnControllerDelegate;

/**
 * @class RNSSplitColumnController
 * @brief Native owner of a Split column: the navigation controller installed in the UISplitViewController column,
 * the stack of screens shown in it and the observation of its frame.
 *
 * It has no React counterpart. The host creates one controller per column, installs its `navigationController` and
 * hands the screens of the column over. The column drives its stack the way `RNSStackHostComponentView` drives a
 * standalone stack: it keeps the screens in React order and turns their mounts, unmounts and activity mode changes
 * into operations of `RNSStackOperationCoordinator`.
 */
@interface RNSSplitColumnController : NSObject

@property (nonatomic, weak, nullable) id<RNSSplitColumnControllerDelegate> delegate;

@property (nonatomic, strong, readonly, nonnull) UINavigationController *navigationController;

/** @brief Registers a screen mounted at `index` among the screens of the column; an attached one is pushed. */
- (void)insertScreen:(UIView<RNSStackScreenProviding> *)screen atIndex:(NSInteger)index;

/** @brief Unregisters an unmounted screen; one still on the stack is popped. */
- (void)removeScreen:(UIView<RNSStackScreenProviding> *)screen;

- (void)screenDidChangeActivityMode:(UIView<RNSStackScreenProviding> *)screen;

/**
 * @brief Applies the pending push and pop operations to the navigation controller.
 */
- (void)flushPendingUpdates;

@end

NS_ASSUME_NONNULL_END
