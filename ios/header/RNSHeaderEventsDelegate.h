#pragma once

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RNSHeaderEventsDelegate <NSObject>

- (void)didPressMenuItem:(NSString *)menuItemId;

- (void)didChangeSelectionForMenu:(NSString *)menuId selectedMenuItemIds:(NSArray<NSString *> *)selectedIds;

- (void)didPressHeaderItem:(NSString *)itemId;

@end

NS_ASSUME_NONNULL_END
