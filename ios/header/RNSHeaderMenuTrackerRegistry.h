#pragma once

#import <Foundation/Foundation.h>

@class RNSHeaderMenuToggleStateTracker;

NS_ASSUME_NONNULL_BEGIN

@interface RNSHeaderMenuTrackerRegistry : NSObject

- (RNSHeaderMenuToggleStateTracker *)trackerForItemId:(NSString *)itemId;

- (void)resetTrackerForItemId:(NSString *)itemId;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
