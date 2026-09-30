#pragma once

#include <jsi/jsi.h>
#include <react/renderer/components/rnscreens/EventEmitters.h>
#include <react/renderer/components/rnscreens/Props.h>
#include <react/renderer/components/view/ConcreteViewShadowNode.h>
#include <react/renderer/core/LayoutContext.h>
#include "RNSHeaderConfigState.h"

namespace facebook::react {

JSI_EXPORT extern const char RNSHeaderConfigComponentName[];

class JSI_EXPORT RNSHeaderConfigShadowNode final
    : public ConcreteViewShadowNode<
          RNSHeaderConfigComponentName,
#if !defined(ANDROID)
          RNSHeaderConfigIOSProps,
          RNSHeaderConfigIOSEventEmitter,
#else // !defined(ANDROID)
          RNSStackHeaderConfigAndroidProps,
          RNSStackHeaderConfigAndroidEventEmitter,
#endif // !defined(ANDROID)
          RNSHeaderConfigState> {
 public:
  using ConcreteViewShadowNode::ConcreteViewShadowNode;
  using StateData = ConcreteViewShadowNode::ConcreteStateData;

#ifdef ANDROID
  Point getContentOriginOffset(bool includeTransform) const override;
#else // ANDROID
  void layout(LayoutContext layoutContext) override;

  void setImageLoader(std::weak_ptr<void> imageLoader);

 private:
  void applyFrameCorrections();
  StateData &getStateDataMutable();
#endif // ANDROID
};

} // namespace facebook::react
