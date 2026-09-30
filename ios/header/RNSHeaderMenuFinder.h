#pragma once

#import <Foundation/Foundation.h>

#import "RNSHeaderItemComponentView.h"
#import "RNSHeaderMenuData.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const RNSTitleMenuTrackerItemId = @"__titleMenu__";

@interface RNSHeaderMenuElementSearchResult : NSObject

@property (nonatomic, strong, readonly) id<RNSHeaderMenuElement> element;
@property (nonatomic, strong, readonly, nullable) RNSHeaderMenuData *parentMenu;

- (instancetype)initWithElement:(id<RNSHeaderMenuElement>)element parentMenu:(nullable RNSHeaderMenuData *)parentMenu;

@end

typedef NS_ENUM(NSInteger, RNSMenuElementPosition) {
  RNSMenuElementPositionItem,
  RNSMenuElementPositionTitle,
  RNSMenuElementPositionOverflow,
};

@interface RNSMenuElementLocator : NSObject

@property (nonatomic, strong, readonly) RNSHeaderMenuElementSearchResult *searchResult;
@property (nonatomic, readonly) RNSMenuElementPosition position;
@property (nonatomic, weak, readonly, nullable) id<RNSHeaderItemDataProviding> headerItem;

/**
 * Root menu tree that contains the found element. Used for singleSelectionRoot lookups.
 */
@property (nonatomic, strong, readonly, nullable) RNSHeaderMenuData *rootMenu;

/**
 * Tracker key for the toggle state tracker registry.
 */
@property (nonatomic, copy, readonly, nullable) NSString *trackerItemId;

- (instancetype)initWithSearchResult:(RNSHeaderMenuElementSearchResult *)searchResult
                            position:(RNSMenuElementPosition)position
                          headerItem:(nullable id<RNSHeaderItemDataProviding>)headerItem
                            rootMenu:(nullable RNSHeaderMenuData *)rootMenu
                       trackerItemId:(nullable NSString *)trackerItemId;

@end

@interface RNSHeaderMenuFinder : NSObject

/**
 * Searches all header items' menus and the title menu for a menu element with the given ID.
 */
+ (nullable RNSMenuElementLocator *)findMenuElementWithId:(NSString *)elementId
                                            inHeaderItems:(NSArray<id<RNSHeaderItemDataProviding>> *)items
                                                titleMenu:(nullable RNSHeaderMenuData *)titleMenu;

/**
 * Recursively searches a single menu tree for an element with the given ID.
 */
+ (nullable RNSHeaderMenuElementSearchResult *)findElementWithId:(NSString *)elementId inMenu:(RNSHeaderMenuData *)menu;
/**
 * Finds the single selection root menu that contains the element with the given ID.
 */
+ (nullable RNSHeaderMenuData *)singleSelectionRootForElementWithId:(NSString *)elementId
                                                             inMenu:(RNSHeaderMenuData *)menu;

@end

NS_ASSUME_NONNULL_END
