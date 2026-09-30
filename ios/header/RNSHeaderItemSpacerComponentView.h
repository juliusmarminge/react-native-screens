#pragma once

#import "RNSHeaderItemInvalidationDelegate.h"
#import "RNSHeaderItemSpacerDataProviding.h"
#import "RNSReactBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNSHeaderItemSpacerComponentView : RNSReactBaseView <RNSHeaderItemSpacerDataProviding>

@property (nonatomic, readonly) RNSHeaderItemSpacerPlacement placement;
@property (nonatomic, readonly) BOOL isFlexible;
@property (nonatomic, readonly) CGFloat width;

@property (nonatomic, weak, nullable) id<RNSHeaderItemInvalidationDelegate> invalidationDelegate;

@end

NS_ASSUME_NONNULL_END
