#pragma once

#import <UIKit/UIKit.h>

#import "RNSHeaderIconData.h"
#import "RNSHeaderItemPlacement.h"
#import "RNSHeaderMenuData.h"

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

@end

NS_ASSUME_NONNULL_END
