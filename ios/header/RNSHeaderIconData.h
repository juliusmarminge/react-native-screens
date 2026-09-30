#pragma once

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RNSHeaderIconType) {
  RNSHeaderIconTypeSfSymbol,
  RNSHeaderIconTypeXcasset,
  RNSHeaderIconTypeImageSource,
  RNSHeaderIconTypeTemplateSource,
};

@interface RNSHeaderIconData : NSObject

@property (nonatomic, readonly) RNSHeaderIconType iconType;
@property (nonatomic, copy, readonly, nullable) NSString *resourceName;
@property (nonatomic, copy, readonly, nullable) NSDictionary *jsonSource;
@property (nonatomic, strong, nullable) UIImage *resolvedImage;

- (instancetype)initWithType:(RNSHeaderIconType)iconType
                resourceName:(nullable NSString *)resourceName
                  jsonSource:(nullable NSDictionary *)jsonSource;

@end

NS_ASSUME_NONNULL_END
