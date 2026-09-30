#pragma once

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RNSHeaderItemInvalidationDelegate <NSObject>

- (void)headerItemDidInvalidateWithId:(NSString *)itemId;

- (void)headerItemMenuDidChangeWithId:(NSString *)itemId;

- (void)headerItemMenuDidUpdateFromCommandWithId:(NSString *)itemId;

- (void)headerItemSpacerDidInvalidate;

@end

NS_ASSUME_NONNULL_END
