#pragma once

#import <UIKit/UIKit.h>
#import "RNSContainerItem.h"

NS_ASSUME_NONNULL_BEGIN

@class RNSStackScreenComponentView;
@class RNSStackController;
@class RNSHeaderCoordinator;

@interface RNSStackScreenController : UIViewController <RNSContainerItem>

@property (nonatomic, strong, readonly, nonnull) RNSHeaderCoordinator *headerCoordinator;

- (instancetype)initWithComponentView:(RNSStackScreenComponentView *)componentView;

@end

NS_ASSUME_NONNULL_END
