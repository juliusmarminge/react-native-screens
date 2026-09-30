#import "RNSHeaderIconResolver.h"
#import <React/RCTLog.h>

@implementation RNSHeaderIconResolver

+ (nullable UIImage *)resolveIcon:(RNSHeaderIconData *)iconData
                  withImageLoader:(id<RNSImageLoading>)imageLoader
             asyncCompletionBlock:(nullable void (^)(UIImage *_Nullable))completionBlock
{
  if (iconData == nil) {
    return nil;
  }

  // If we already resolved this icon, return cached image
  if (iconData.resolvedImage != nil) {
    return iconData.resolvedImage;
  }

  switch (iconData.iconType) {
    case RNSHeaderIconTypeSfSymbol: {
      UIImage *image = [UIImage systemImageNamed:iconData.resourceName];
      if (image == nil && iconData.resourceName != nil) {
        RCTLogWarn(@"[RNScreens] Failed to load SF Symbol \"%@\" for header icon", iconData.resourceName);
      }
      iconData.resolvedImage = image;
      return image;
    }
    case RNSHeaderIconTypeXcasset: {
      UIImage *image = [UIImage imageNamed:iconData.resourceName];
      if (image == nil && iconData.resourceName != nil) {
        RCTLogWarn(@"[RNScreens] Failed to load xcasset \"%@\" for header icon", iconData.resourceName);
      }
      iconData.resolvedImage = image;
      return image;
    }
    case RNSHeaderIconTypeImageSource:
    case RNSHeaderIconTypeTemplateSource: {
      if (imageLoader == nil || iconData.jsonSource == nil) {
        return nil;
      }
      // Weak ref to iconData to avoid retaining it if the item is removed before load completes
      __weak RNSHeaderIconData *weakIconData = iconData;
      [imageLoader loadImageFromJsonSource:iconData.jsonSource
                                asTemplate:iconData.iconType == RNSHeaderIconTypeTemplateSource
                    withCompletionCallback:^(UIImage *_Nullable image) {
                      weakIconData.resolvedImage = image;
                      if (completionBlock) {
                        completionBlock(image);
                      }
                    }];
      return iconData.resolvedImage;
    }
  }
}

+ (nullable UIImage *)placeholderImageForIcon:(RNSHeaderIconData *)iconData
{
  if (iconData.jsonSource == nil) {
    return nil;
  }

  CGFloat width = [iconData.jsonSource[@"width"] doubleValue];
  CGFloat height = [iconData.jsonSource[@"height"] doubleValue];
  CGFloat scale = [iconData.jsonSource[@"scale"] doubleValue] ?: 1.0;
  CGSize size = (width > 0 && height > 0) ? CGSizeMake(width, height) : CGSizeMake(1, 1);

  UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
  format.scale = scale;
  UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size format:format];
  return [renderer imageWithActions:^(UIGraphicsImageRendererContext *_Nonnull ctx){
  }];
}

@end
