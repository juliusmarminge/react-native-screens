#include "RNSHeaderConfigState.h"

namespace facebook::react {

void RNSHeaderConfigState::setImageLoader(
    std::weak_ptr<void> imageLoader) {
  imageLoader_ = imageLoader;
}

std::weak_ptr<void> RNSHeaderConfigState::getImageLoader() const noexcept {
  return imageLoader_;
}

#ifdef ANDROID
folly::dynamic RNSHeaderConfigState::getDynamic() const {
  return folly::dynamic::object("frameWidth", frameSize.width)(
      "frameHeight", frameSize.height)("contentOffsetX", contentOffset.x)(
      "contentOffsetY", contentOffset.y);
}
#endif // ANDROID

} // namespace facebook::react
