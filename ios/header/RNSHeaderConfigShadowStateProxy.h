#pragma once

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RNSHeaderConfigComponentView;

/**
 * @class RNSHeaderShadowStateProxy
 * @brief Tracks frame changes for stack header shadow state updates.
 */
@interface RNSHeaderConfigShadowStateProxy : NSObject

- (instancetype)initWithHeaderConfigView:(RNSHeaderConfigComponentView *)headerConfigView;

/**
 * Updates header config's frame in ShadowTree if new frame is different than previously sent frame.
 */
- (void)updateShadowStateWithFrame:(CGRect)frame;

/**
 * Resets internal properties.
 */
- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
