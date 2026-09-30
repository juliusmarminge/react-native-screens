#pragma once

#include <react/debug/react_native_assert.h>
#include <react/renderer/components/rnscreens/Props.h>
#include <react/renderer/core/ConcreteComponentDescriptor.h>
#include "RNSHeaderItemShadowNode.h"

namespace facebook::react {

class RNSHeaderItemComponentDescriptor final
    : public ConcreteComponentDescriptor<RNSHeaderItemShadowNode> {
 public:
  using ConcreteComponentDescriptor::ConcreteComponentDescriptor;
};

} // namespace facebook::react
