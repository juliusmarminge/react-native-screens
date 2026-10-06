#pragma once

#import <UIKit/UIKit.h>

#import "RNSHeaderIconData.h"
#import "RNSHeaderItemAxisBehavior.h"
#import "RNSHeaderItemPlacement.h"
#import "RNSHeaderMenuData.h"
#import "RNSHeaderItemVisibilityPriority.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RNSHeaderItemDataProviding <NSObject>

@property (nonatomic, readonly) RNSHeaderItemPlacement placement;
@property (nonatomic, readonly, nullable) NSString *itemId;
@property (nonatomic, readonly, nullable) NSString *identifier;
@property (nonatomic, readonly, nullable) NSString *title;
@property (nonatomic, readonly, nullable) RNSHeaderIconData *icon;
@property (nonatomic, readonly, nullable) RNSHeaderMenuData *menu;
@property (nonatomic, readonly, nullable) UIView *customView;
@property (nonatomic, readonly) BOOL respondsToOnPress;
@property (nonatomic, readonly) BOOL hidesSharedBackground;
@property (nonatomic, readonly) BOOL searchBarPlacement;
@property (nonatomic, readonly) RNSHeaderItemAxisBehavior axisBehavior;
@property (nonatomic, readonly) RNSHeaderItemVisibilityPriority visibilityPriority;

@end

NS_ASSUME_NONNULL_END
