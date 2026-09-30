#include "RNSHeaderConfigShadowNode.h"

namespace facebook::react {

#if !defined(ANDROID)
extern const char RNSHeaderConfigComponentName[] =
    "RNSHeaderConfigIOS";
#else // !defined(ANDROID)
extern const char RNSHeaderConfigComponentName[] =
    "RNSStackHeaderConfigAndroid";
#endif // !defined(ANDROID)

#ifdef ANDROID
Point RNSHeaderConfigShadowNode::getContentOriginOffset(
    bool /*includeTransform*/) const {
  auto stateData = getStateData();
  return stateData.contentOffset;
}
#else // ANDROID
void RNSHeaderConfigShadowNode::layout(LayoutContext layoutContext) {
  YogaLayoutableShadowNode::layout(layoutContext);
  applyFrameCorrections();
}

void RNSHeaderConfigShadowNode::applyFrameCorrections() {
  ensureUnsealed();

  const auto &stateData = getStateData();
  layoutMetrics_.frame.origin.x = stateData.contentOffset.x;
  layoutMetrics_.frame.origin.y = stateData.contentOffset.y;
}

void RNSHeaderConfigShadowNode::setImageLoader(
    std::weak_ptr<void> imageLoader) {
  getStateDataMutable().setImageLoader(imageLoader);
}

RNSHeaderConfigShadowNode::StateData &
RNSHeaderConfigShadowNode::getStateDataMutable() {
  ensureUnsealed();
  return const_cast<RNSHeaderConfigShadowNode::StateData &>(
      getStateData());
}
#endif // ANDROID
} // namespace facebook::react
