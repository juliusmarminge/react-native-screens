#pragma once

#import <Foundation/Foundation.h>

@class RNSHeaderIconData;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RNSMenuItemType) {
  RNSMenuItemTypeAutomatic = 0,
  RNSMenuItemTypeAction,
  RNSMenuItemTypeToggle,
};

@protocol RNSHeaderMenuElement <NSObject>

@property (nonatomic, copy, readonly) NSString *menuElementId;

@end

@interface RNSHeaderMenuItemData : NSObject <RNSHeaderMenuElement>

@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, readonly) RNSMenuItemType itemType;
@property (nonatomic, readonly) BOOL initialToggleState;
@property (nonatomic, readonly) BOOL keepsMenuPresented;
@property (nonatomic, strong, readonly, nullable) RNSHeaderIconData *icon;

- (instancetype)initWithId:(NSString *)menuElementId
                     title:(nullable NSString *)title
                  itemType:(RNSMenuItemType)itemType
        initialToggleState:(BOOL)initialToggleState
        keepsMenuPresented:(BOOL)keepsMenuPresented
                      icon:(nullable RNSHeaderIconData *)icon;

@end

@interface RNSHeaderMenuData : NSObject <RNSHeaderMenuElement>

@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, readonly) BOOL singleSelection;
@property (nonatomic, readonly) BOOL displayInline;
@property (nonatomic, readonly) BOOL displayAsPalette;
@property (nonatomic, copy, readonly) NSArray<id<RNSHeaderMenuElement>> *children;
@property (nonatomic, strong, readonly, nullable) RNSHeaderIconData *icon;

- (instancetype)initWithId:(NSString *)menuElementId
                     title:(nullable NSString *)title
           singleSelection:(BOOL)singleSelection
             displayInline:(BOOL)displayInline
          displayAsPalette:(BOOL)displayAsPalette
                  children:(NSArray<id<RNSHeaderMenuElement>> *)children
                      icon:(nullable RNSHeaderIconData *)icon;

@end

NS_ASSUME_NONNULL_END
