#pragma once

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RNSSplitColumnFrameObserver;

@protocol RNSSplitColumnFrameObserverDelegate <NSObject>

- (void)frameObserver:(RNSSplitColumnFrameObserver *)observer
    didChangeFrameOriginOfNavigationController:(UINavigationController *)navigationController;

@end

NS_ASSUME_NONNULL_END
