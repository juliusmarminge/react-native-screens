#include "RNSHeaderItemShadowNode.h"

namespace facebook::react {

extern const char RNSHeaderItemComponentName[] = "RNSHeaderItemIOS";

void RNSHeaderItemShadowNode::layout(LayoutContext layoutContext) {
  YogaLayoutableShadowNode::layout(layoutContext);
  applyFrameCorrections();
}

void RNSHeaderItemShadowNode::applyFrameCorrections() {
  ensureUnsealed();

  const auto &stateData = getStateData();
  layoutMetrics_.frame.origin.x = stateData.contentOffset.x;
  layoutMetrics_.frame.origin.y = stateData.contentOffset.y;
}

} // namespace facebook::react
