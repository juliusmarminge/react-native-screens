#pragma once

#import <Foundation/Foundation.h>

#import "RNSHeaderIconData.h"
#import "RNSHeaderMenuData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Typed options parsed from command dictionary for menu item updates.
 * `has*` flags distinguish "no change" (key absent) from "reset" (key present, null value).
 */
@interface RNSMenuItemUpdateOptions : NSObject

@property (nonatomic, readonly) BOOL hasTitle;
@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, readonly) BOOL hasIcon;
@property (nonatomic, strong, readonly, nullable) RNSHeaderIconData *icon;
@property (nonatomic, readonly) BOOL hasToggleState;
@property (nonatomic, readonly) BOOL toggleState;

+ (instancetype)fromDictionary:(NSDictionary *)dict;

+ (RNSHeaderMenuItemData *)applyOptions:(RNSMenuItemUpdateOptions *)options toMenuItem:(RNSHeaderMenuItemData *)old;

@end

/**
 * Typed options parsed from command dictionary for submenu updates.
 * `has*` flags distinguish "no change" (key absent) from "reset" (key present, null value).
 */
@interface RNSMenuUpdateOptions : NSObject

@property (nonatomic, readonly) BOOL hasTitle;
@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, readonly) BOOL hasIcon;
@property (nonatomic, strong, readonly, nullable) RNSHeaderIconData *icon;

+ (instancetype)fromDictionary:(NSDictionary *)dict;

+ (RNSHeaderMenuData *)applyOptions:(RNSMenuUpdateOptions *)options toMenu:(RNSHeaderMenuData *)old;

@end

NS_ASSUME_NONNULL_END
