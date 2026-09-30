#pragma once

#import <UIKit/UIKit.h>

@class RNSHeaderMenuData;

NS_ASSUME_NONNULL_BEGIN

@protocol RNSHeaderConfigDataProviding <NSObject>

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

/**
 Children are expected to conform to either RNSHeaderItemDataProviding
 or RNSHeaderItemSpacerDataProviding, other types are ignored.
 */
@property (nonatomic, readonly) NSArray<id> *children;

@end

NS_ASSUME_NONNULL_END
