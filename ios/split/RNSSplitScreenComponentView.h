#pragma once

#import "RNSEnums.h"
#import "RNSReactBaseView.h"
#import "RNSSafeAreaProviding.h"
#import "RNSStackScreenProviding.h"

NS_ASSUME_NONNULL_BEGIN

@class RNSSplitHostComponentView;
@class RNSSplitScreenController;
@class RNSHeaderConfigComponentView;

/**
 * @class RNSSplitScreenComponentView
 * @brief Native view component representing one column in a UISplitViewController layout.
 *
 * Responsible for a lifecycle management, layout, and event emission for a single screen; used as a child
 * of RNSSplitHostComponentView.
 */
@interface RNSSplitScreenComponentView : RNSReactBaseView <RNSSafeAreaProviding, RNSStackScreenProviding>

@property (nonatomic, strong, readonly, nonnull) RNSSplitScreenController *controller;
@property (nonatomic, weak, readwrite, nullable) RNSSplitHostComponentView *splitHost;
@property (nonatomic, weak, readonly, nullable) RNSHeaderConfigComponentView *headerConfig;

@end

#pragma mark - Props

/**
 * @category Props
 * @brief Definitions for React Native props.
 */
@interface RNSSplitScreenComponentView ()

/**
 * @brief Determines the purpose for the column (classic Column or one of specific types, like Inspector)
 */
@property (nonatomic, readonly) RNSSplitScreenColumnType columnType;
/** Index of the column the screen belongs to; `-1` makes the screen a column of its own. */
@property (nonatomic, readonly) NSInteger column;
@property (nonatomic, readonly) RNSStackScreenActivityMode activityMode;
@property (nonatomic, strong, readonly, nullable) NSString *screenKey;

@end

NS_ASSUME_NONNULL_END
