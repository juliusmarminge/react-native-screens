#pragma once

#include <jsi/jsi.h>
#include <react/renderer/components/rnscreens/EventEmitters.h>
#include <react/renderer/components/rnscreens/Props.h>
#include <react/renderer/components/view/ConcreteViewShadowNode.h>
#include <react/renderer/core/LayoutContext.h>
#include "RNSHeaderItemState.h"

namespace facebook::react {

JSI_EXPORT extern const char RNSHeaderItemComponentName[];

class JSI_EXPORT RNSHeaderItemShadowNode final
    : public ConcreteViewShadowNode<
          RNSHeaderItemComponentName,
          RNSHeaderItemIOSProps,
          RNSHeaderItemIOSEventEmitter,
          RNSHeaderItemState> {
 public:
  using ConcreteViewShadowNode::ConcreteViewShadowNode;
  using StateData = ConcreteViewShadowNode::ConcreteStateData;

  void layout(LayoutContext layoutContext) override;

 private:
  void applyFrameCorrections();
};

} // namespace facebook::react
