#pragma once

#import <Foundation/Foundation.h>

#import "RNSHeaderIconData.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNSHeaderIconMapper : NSObject

+ (nullable RNSHeaderIconData *)iconFromDictionary:(nullable id)dictionary;

@end

NS_ASSUME_NONNULL_END
