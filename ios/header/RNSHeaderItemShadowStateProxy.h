#pragma once

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RNSHeaderItemComponentView;

/**
 * @class RNSHeaderItemShadowStateProxy
 * @brief Tracks frame changes for stack header item shadow state updates.
 */
@interface RNSHeaderItemShadowStateProxy : NSObject

- (instancetype)initWithHeaderItemView:(RNSHeaderItemComponentView *)headerItemView;

/**
 * Updates header item's frame in ShadowTree if new frame is different than previously sent frame.
 */
- (void)updateShadowStateWithFrame:(CGRect)frame;

/**
 * Resets internal properties.
 */
- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
