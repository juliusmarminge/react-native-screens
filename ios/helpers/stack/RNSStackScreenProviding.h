#pragma once

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RNSHeaderConfigComponentView;
@class RNSHeaderCoordinator;

typedef NS_ENUM(int, RNSStackScreenActivityMode) {
  RNSStackScreenActivityModeDetached = 0,
  RNSStackScreenActivityModeAttached = 1,
};

/**
 * @brief A React view backing a screen of a stack.
 *
 * The stack machinery (operation coordinator, navigation controller) reaches its screens only through this protocol,
 * so any component view whose controller can be pushed onto the stack's navigation controller may be its item.
 */
@protocol RNSStackScreenProviding <NSObject>

/** @brief View controller pushed onto the stack's navigation controller. */
- (nonnull UIViewController *)controller;

/** @brief Whether the screen is expected to be on the stack. */
- (RNSStackScreenActivityMode)activityMode;

- (nullable NSString *)screenKey;

- (nullable RNSHeaderConfigComponentView *)headerConfig;

- (nullable RNSHeaderCoordinator *)headerCoordinator;

@end

NS_ASSUME_NONNULL_END
