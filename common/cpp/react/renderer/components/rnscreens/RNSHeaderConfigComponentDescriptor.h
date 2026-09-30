#pragma once

#ifdef ANDROID
#include <fbjni/fbjni.h>
#endif // ANDROID

#include <react/debug/react_native_assert.h>
#include <react/renderer/components/rnscreens/Props.h>
#include <react/renderer/core/ConcreteComponentDescriptor.h>
#include "RNSHeaderConfigShadowNode.h"

namespace facebook::react {

class RNSHeaderConfigComponentDescriptor final
    : public ConcreteComponentDescriptor<RNSHeaderConfigShadowNode> {
 public:
  using ConcreteComponentDescriptor::ConcreteComponentDescriptor;

  void adopt(ShadowNode &shadowNode) const override {
    react_native_assert(
        dynamic_cast<RNSHeaderConfigShadowNode *>(&shadowNode));
    auto &configShadowNode =
        static_cast<RNSHeaderConfigShadowNode &>(shadowNode);
    react_native_assert(
        dynamic_cast<YogaLayoutableShadowNode *>(&configShadowNode));
    auto &layoutableShadowNode =
        static_cast<YogaLayoutableShadowNode &>(configShadowNode);

    auto state = std::static_pointer_cast<
        const RNSHeaderConfigShadowNode::ConcreteState>(
        shadowNode.getState());
    auto stateData = state->getData();

    if (stateData.frameSize.width != 0 && stateData.frameSize.height != 0) {
      layoutableShadowNode.setSize(
          Size{stateData.frameSize.width, stateData.frameSize.height});
    }

#if !defined(ANDROID)
    std::weak_ptr<void> imageLoader =
        contextContainer_->at<std::shared_ptr<void>>("RCTImageLoader");
    configShadowNode.setImageLoader(imageLoader);
#endif // !defined(ANDROID)

    ConcreteComponentDescriptor::adopt(shadowNode);
  }
};

} // namespace facebook::react
