#import "RNSHeaderIconMapper.h"

@implementation RNSHeaderIconMapper

+ (nullable RNSHeaderIconData *)iconFromDictionary:(nullable id)dictionary
{
  if (![dictionary isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  NSDictionary *dict = (NSDictionary *)dictionary;

  NSString *type = dict[@"type"];
  if (![type isKindOfClass:[NSString class]]) {
    return nil;
  }

  if ([type isEqualToString:@"sfSymbol"]) {
    return [[RNSHeaderIconData alloc] initWithType:RNSHeaderIconTypeSfSymbol resourceName:dict[@"name"] jsonSource:nil];
  }

  if ([type isEqualToString:@"xcasset"]) {
    return [[RNSHeaderIconData alloc] initWithType:RNSHeaderIconTypeXcasset resourceName:dict[@"name"] jsonSource:nil];
  }

  if ([type isEqualToString:@"imageSource"]) {
    NSDictionary *source = dict[@"imageSource"];
    if (![source isKindOfClass:[NSDictionary class]]) {
      return nil;
    }
    return [[RNSHeaderIconData alloc] initWithType:RNSHeaderIconTypeImageSource resourceName:nil jsonSource:source];
  }

  if ([type isEqualToString:@"templateSource"]) {
    NSDictionary *source = dict[@"templateSource"];
    if (![source isKindOfClass:[NSDictionary class]]) {
      return nil;
    }
    return [[RNSHeaderIconData alloc] initWithType:RNSHeaderIconTypeTemplateSource resourceName:nil jsonSource:source];
  }

  return nil;
}

@end
