#pragma once

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RNSSplitColumnController;

/**
 * @protocol RNSSplitColumnControllerDelegate
 * @brief Receives layout notifications of a Split column from its controller.
 */
@protocol RNSSplitColumnControllerDelegate <NSObject>

/**
 * @brief Called when the origin of the column's navigation controller view changed, e.g. after the Split
 * repositioned its columns.
 */
- (void)splitColumnControllerFrameOriginDidChange:(RNSSplitColumnController *)columnController;

@end

NS_ASSUME_NONNULL_END
