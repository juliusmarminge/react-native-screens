#pragma once

#import <UIKit/UIKit.h>

#import "RNSHeaderEventsDelegate.h"
#import "RNSHeaderMenuData.h"
#import "RNSHeaderMenuToggleStateTracker.h"
#import "RNSImageLoading.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNSHeaderMenuCoordinator : NSObject

/**
 * Applies menu specification to the item. Sets up event delegate to receive
 * menu updates when user selects options or clicks actions. Since menu needs
 * to be rebuilt after user changes selection or after async icon load,
 * the `menuInvalidatedCallback` is triggered and the caller is expected
 * to reapply the menu there.
 */
+ (void)applyMenu:(RNSHeaderMenuData *)data
             toBarButtonItem:(UIBarButtonItem *)item
    withHeaderEventsDelegate:(id<RNSHeaderEventsDelegate>)delegate
                stateTracker:(RNSHeaderMenuToggleStateTracker *)tracker
             withImageLoader:(id<RNSImageLoading>)imageLoader
     menuInvalidatedCallback:(nullable void (^)(void))onMenuInvalidated;

/**
 * Collects IDs of all toggle items in a single selection hierarchy rooted at the given menu.
 */
+ (NSArray<NSString *> *)getAllToggleItemsIdsInSingleSelectionHierarchy:(RNSHeaderMenuData *)menu;

/**
 * Collects IDs of toggle items that are direct children of the given menu.
 */
+ (NSArray<NSString *> *)getToggleItemsIdsInMenu:(RNSHeaderMenuData *)menu;

/**
 * Builds a UIMenu from the given menu data. Used for `UINavigationItem.titleMenuProvider`.
 */
+ (UIMenu *)buildUIMenuFromData:(RNSHeaderMenuData *)data
       withHeaderEventsDelegate:(id<RNSHeaderEventsDelegate>)delegate
                   stateTracker:(RNSHeaderMenuToggleStateTracker *)tracker
                withImageLoader:(id<RNSImageLoading>)imageLoader
        menuInvalidatedCallback:(nullable void (^)(void))onMenuInvalidated;

/**
 * Constructs a new menu tree with the child matching `elementId` replaced by `newElement`.
 * Returns the original menu unchanged if no matching child is found in the subtree.
 */
+ (RNSHeaderMenuData *)menu:(RNSHeaderMenuData *)menu
       replacingChildWithId:(NSString *)elementId
                withElement:(id<RNSHeaderMenuElement>)newElement;

@end

NS_ASSUME_NONNULL_END
