#pragma once

#import "RNSHeaderItemDataProviding.h"
#import "RNSHeaderItemInvalidationDelegate.h"
#import "RNSReactBaseView.h"
#import "RNSViewFrameChangeDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNSHeaderItemComponentView : RNSReactBaseView <RNSHeaderItemDataProviding, RNSViewFrameChangeDelegate>

@property (nonatomic, readonly) RNSHeaderItemPlacement placement;
@property (nonatomic, readonly, nullable) NSString *itemId;
@property (nonatomic, readonly, nullable) NSString *identifier;
@property (nonatomic, readonly, nullable) NSString *title;
@property (nonatomic, readonly, nullable) RNSHeaderIconData *icon;
@property (nonatomic, readonly, nullable) RNSHeaderMenuData *menu;
@property (nonatomic, readonly, nullable) UIView *customView;
@property (nonatomic, readonly) BOOL respondsToOnPress;
@property (nonatomic, readonly) BOOL hidesSharedBackground;

@property (nonatomic, nullable) NSString *titleProp;
@property (nonatomic, nullable) RNSHeaderIconData *iconProp;
@property (nonatomic, nullable) RNSHeaderMenuData *menuProp;

@property (nonatomic, weak, nullable) id<RNSHeaderItemInvalidationDelegate> invalidationDelegate;

- (void)emitOnPress;

/**
 * Replaces a menu element in the item's menu tree with a new element constructed from command options.
 * If parentMenu is nil, the element is the root menu and is replaced directly.
 */
- (void)updateMenuElementWithId:(NSString *)elementId
                    withElement:(id<RNSHeaderMenuElement>)newElement
                     parentMenu:(nullable RNSHeaderMenuData *)parentMenu;

@end

NS_ASSUME_NONNULL_END

#pragma mark - Hidden from Swift

#if defined(__cplusplus)

#import <react/renderer/components/rnscreens/RNSHeaderItemComponentDescriptor.h>

@interface RNSHeaderItemComponentView ()

- (facebook::react::RNSHeaderItemShadowNode::ConcreteState::Shared)state;

@end

#endif // defined(__cplusplus)
