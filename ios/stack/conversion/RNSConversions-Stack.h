#pragma once

#if defined(__cplusplus)

#import <UIKit/UIKit.h>
#import <react/renderer/components/rnscreens/Props.h>
#import "RNSDefines.h"
#import "RNSHeaderItemPlacement.h"
#import "RNSHeaderItemSpacerPlacement.h"
#import "RNSStackScreenProviding.h"
#import "RNSHeaderItemVisibilityPriority.h"
#include <type_traits>

namespace react = facebook::react;

namespace rnscreens::conversion {
#if RNS_IPHONE_OS_VERSION_AVAILABLE(16_0) && !TARGET_OS_TV
UINavigationItemStyle
UINavigationItemStyleFromReactRNSHeaderConfigIOSNavigationItemStyle(
    react::RNSHeaderConfigIOSNavigationItemStyle style)
    API_AVAILABLE(ios(16.0));
#endif


template <typename>
inline constexpr bool missingConversion = false;

template <typename TargetType, typename InputType>
TargetType convert(InputType) {
  static_assert(
      missingConversion<TargetType>,
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

RNSHeaderItemVisibilityPriority
RNSHeaderItemVisibilityPriorityFromReactRNSHeaderItemIOSVisibilityPriority(
    react::RNSHeaderItemIOSVisibilityPriority visibilityPriority);

#if RNS_IPHONE_OS_VERSION_AVAILABLE(27_0) && !TARGET_OS_TV && !TARGET_OS_VISION
API_AVAILABLE(ios(27.0))
UIBarButtonItemVisibilityPriority
UIBarButtonItemVisibilityPriorityFromRNSHeaderItemVisibilityPriority(
    RNSHeaderItemVisibilityPriority visibilityPriority);
#endif // Check for iOS >= 27 && !TARGET_OS_TV && !TARGET_OS_VISION

}; // namespace rnscreens::conversion

#endif // defined(__cplusplus)
