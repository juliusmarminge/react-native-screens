#import "RNSHeaderMenuFinder.h"

#pragma mark - RNSHeaderMenuElementSearchResult

@implementation RNSHeaderMenuElementSearchResult

- (instancetype)initWithElement:(id<RNSHeaderMenuElement>)element parentMenu:(nullable RNSHeaderMenuData *)parentMenu
{
  if (self = [super init]) {
    _element = element;
    _parentMenu = parentMenu;
  }
  return self;
}

@end

#pragma mark - RNSMenuElementLocator

@implementation RNSMenuElementLocator

- (instancetype)initWithSearchResult:(RNSHeaderMenuElementSearchResult *)searchResult
                            position:(RNSMenuElementPosition)position
                          headerItem:(nullable id<RNSHeaderItemDataProviding>)headerItem
                            rootMenu:(nullable RNSHeaderMenuData *)rootMenu
                       trackerItemId:(nullable NSString *)trackerItemId
{
  if (self = [super init]) {
    _searchResult = searchResult;
    _position = position;
    _headerItem = headerItem;
    _rootMenu = rootMenu;
    _trackerItemId = [trackerItemId copy];
  }
  return self;
}

@end

#pragma mark - RNSHeaderMenuFinder

@implementation RNSHeaderMenuFinder

+ (nullable RNSMenuElementLocator *)findMenuElementWithId:(NSString *)elementId
                                            inHeaderItems:(NSArray<id<RNSHeaderItemDataProviding>> *)items
                                                titleMenu:(nullable RNSHeaderMenuData *)titleMenu
{
  for (id<RNSHeaderItemDataProviding> item in items) {
    if (item.menu == nil || item.itemId == nil) {
      continue;
    }
    RNSHeaderMenuElementSearchResult *result = [self findElementWithId:elementId inMenu:item.menu];
    if (result != nil) {
      return [[RNSMenuElementLocator alloc] initWithSearchResult:result
                                                        position:RNSMenuElementPositionItem
                                                      headerItem:item
                                                        rootMenu:item.menu
                                                   trackerItemId:item.itemId];
    }
  }

  if (titleMenu != nil) {
    RNSHeaderMenuElementSearchResult *result = [self findElementWithId:elementId inMenu:titleMenu];
    if (result != nil) {
      return [[RNSMenuElementLocator alloc] initWithSearchResult:result
                                                        position:RNSMenuElementPositionTitle
                                                      headerItem:nil
                                                        rootMenu:titleMenu
                                                   trackerItemId:RNSTitleMenuTrackerItemId];
    }
  }

  // TODO: search overflow menu (RNSMenuElementPositionOverflow)
  return nil;
}

+ (nullable RNSHeaderMenuElementSearchResult *)findElementWithId:(NSString *)elementId inMenu:(RNSHeaderMenuData *)menu
{
  if ([menu.menuElementId isEqualToString:elementId]) {
    return [[RNSHeaderMenuElementSearchResult alloc] initWithElement:menu parentMenu:nil];
  }

  for (id<RNSHeaderMenuElement> child in menu.children) {
    if ([child.menuElementId isEqualToString:elementId]) {
      return [[RNSHeaderMenuElementSearchResult alloc] initWithElement:child parentMenu:menu];
    }

    if ([child isKindOfClass:[RNSHeaderMenuData class]]) {
      RNSHeaderMenuElementSearchResult *result = [self findElementWithId:elementId inMenu:(RNSHeaderMenuData *)child];
      if (result != nil) {
        return result;
      }
    }
  }

  return nil;
}

+ (nullable RNSHeaderMenuData *)singleSelectionRootForElementWithId:(NSString *)elementId
                                                             inMenu:(RNSHeaderMenuData *)menu
{
  RNSHeaderMenuData *root = nil;
  if ([self searchForElementWithId:elementId
                              inMenu:menu
          currentSingleSelectionRoot:menu.singleSelection ? menu : nil
                           foundRoot:&root]) {
    return root;
  }
  return nil;
}

+ (BOOL)searchForElementWithId:(NSString *)elementId
                        inMenu:(RNSHeaderMenuData *)menu
    currentSingleSelectionRoot:(nullable RNSHeaderMenuData *)currentRoot
                     foundRoot:(RNSHeaderMenuData *_Nullable *_Nonnull)outRoot
{
  RNSHeaderMenuData *resolvedRoot = currentRoot;
  if (resolvedRoot == nil && menu.singleSelection) {
    resolvedRoot = menu;
  }

  for (id<RNSHeaderMenuElement> child in menu.children) {
    if ([child.menuElementId isEqualToString:elementId]) {
      *outRoot = resolvedRoot;
      return YES;
    }
    if ([child isKindOfClass:[RNSHeaderMenuData class]]) {
      if ([self searchForElementWithId:elementId
                                  inMenu:(RNSHeaderMenuData *)child
              currentSingleSelectionRoot:resolvedRoot
                               foundRoot:outRoot]) {
        return YES;
      }
    }
  }
  return NO;
}

@end
