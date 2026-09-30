#pragma once

#import <Foundation/Foundation.h>

#import "RNSHeaderMenuData.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNSHeaderMenuMapper : NSObject

+ (nullable RNSHeaderMenuData *)menuFromDictionary:(nullable id)dictionary;

+ (UIMenuElementState)menuItemStateFromString:(nullable NSString *)string;

@end

NS_ASSUME_NONNULL_END
