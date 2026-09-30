#pragma once

#import "RNSHeaderConfigDataProviding.h"
#import "RNSHeaderCoordinator.h"
#import "RNSHeaderEventsDelegate.h"
#import "RNSHeaderItemInvalidationDelegate.h"
#import "RNSImageLoading.h"
#import "RNSReactBaseView.h"
#import "RNSViewFrameChangeDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNSHeaderConfigComponentView : RNSReactBaseView <RNSViewFrameChangeDelegate,
                                                            RNSHeaderConfigDataProviding,
                                                            RNSHeaderItemInvalidationDelegate,
                                                            RNSHeaderEventsDelegate,
                                                            RNSImageLoading>

@property (nonatomic, readonly, nullable) NSString *title;
@property (nonatomic, readonly, nullable) NSString *subtitle;
@property (nonatomic, readonly) BOOL hidden;
@property (nonatomic, readonly, nullable) NSString *largeTitle;
@property (nonatomic, readonly, nullable) NSString *largeSubtitle;
@property (nonatomic, readonly) BOOL largeTitleEnabled;
@property (nonatomic, readonly, nullable) NSString *prompt;
@property (nonatomic, readonly, nullable) NSString *backButtonTitle;
@property (nonatomic, readonly) UINavigationItemBackButtonDisplayMode backButtonDisplayMode;
@property (nonatomic, readonly) BOOL backButtonMenuEnabled;
@property (nonatomic, readonly, nullable) RNSHeaderMenuData *titleMenu;
@property (nonatomic, readonly, nullable) UINavigationBarAppearance *standardAppearance;
@property (nonatomic, readonly, nullable) UINavigationBarAppearance *scrollEdgeAppearance;
@property (nonatomic, readonly) NSArray<id> *children;

@property (nonatomic, weak, nullable) RNSHeaderCoordinator *headerCoordinator;

- (void)resetProps;

@end

NS_ASSUME_NONNULL_END

#pragma mark - Hidden from Swift

#if defined(__cplusplus)

#import <react/renderer/components/rnscreens/RNSHeaderConfigComponentDescriptor.h>

@interface RNSHeaderConfigComponentView ()

- (facebook::react::RNSHeaderConfigShadowNode::ConcreteState::Shared)state;

@end

#endif // defined(__cplusplus)
