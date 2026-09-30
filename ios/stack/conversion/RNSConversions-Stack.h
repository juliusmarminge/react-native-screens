#pragma once

#if defined(__cplusplus)

#import <UIKit/UIKit.h>
#import <react/renderer/components/rnscreens/Props.h>
#import "RNSHeaderItemPlacement.h"
#import "RNSHeaderItemSpacerPlacement.h"
#import "RNSStackScreenProviding.h"
#import "always_false.h"

namespace react = facebook::react;

namespace rnscreens::conversion {

template <typename TargetType, typename InputType>
TargetType convert(InputType) {
  static_assert(
      rnscreens::always_false<TargetType>::value,
      "[RNScreens] Missing template specialisation for demanded types!");
}

template <>
RNSStackScreenActivityMode convert(react::RNSStackScreenActivityMode mode);

template <>
RNSHeaderItemPlacement convert(react::RNSHeaderItemIOSPlacement placement);

template <>
RNSHeaderItemSpacerPlacement convert(
    react::RNSHeaderItemSpacerIOSPlacement placement);

template <>
UINavigationItemBackButtonDisplayMode convert(
    react::RNSHeaderConfigIOSBackButtonDisplayMode displayMode);

RNSStackScreenActivityMode RNSStackScreenActivityModeFromReactRNSStackScreenActivityMode(react::RNSStackScreenActivityMode mode);

}; // namespace rnscreens::conversion

#endif // defined(__cplusplus)
