#pragma once

#import <UIKit/UIKit.h>
#import "RNSHeaderConfigDataProviding.h"
#import "RNSHeaderEventsDelegate.h"
#import "RNSHeaderMenuData.h"
#import "RNSImageLoading.h"
#import "RNSViewFrameChangeDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNSHeaderCoordinator : NSObject

- (instancetype)initWithScreenController:(UIViewController *)controller;

@property (nonatomic, weak, nullable) id<RNSHeaderConfigDataProviding> configDataProvider;
@property (nonatomic, weak, nullable) id<RNSViewFrameChangeDelegate> frameChangeDelegate;
@property (nonatomic, weak, nullable) id<RNSHeaderEventsDelegate> eventsDelegate;
@property (nonatomic, weak, nullable) id<RNSImageLoading> imageLoader;

- (void)rebuild;

- (void)applyConfigProperties;

- (void)rebuildItemWithId:(nullable NSString *)itemId;

- (void)reapplyMenuForItemWithId:(nullable NSString *)itemId;

- (void)resetTrackerForItemWithId:(nullable NSString *)itemId;

- (void)reapplyTitleMenu;

- (void)resetTitleMenuTracker;

- (void)setToggleState:(BOOL)state
      forMenuElementId:(NSString *)elementId
         trackerItemId:(NSString *)trackerItemId
              rootMenu:(RNSHeaderMenuData *)rootMenu
            parentMenu:(nullable RNSHeaderMenuData *)parentMenu;

- (void)clearHeaderConfiguration;

- (void)updateNavigationBarVisibilityAnimated:(BOOL)animated;

#if !TARGET_OS_TV
- (void)updateBackButtonMenuEnabled;

- (void)clearAppliedBackButtonConfig;
#endif // !TARGET_OS_TV

@end

NS_ASSUME_NONNULL_END
