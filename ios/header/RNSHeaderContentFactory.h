#pragma once

#import <UIKit/UIKit.h>

#import "RNSHeaderEventsDelegate.h"
#import "RNSHeaderItemDataProviding.h"
#import "RNSHeaderItemSpacerDataProviding.h"
#import "RNSImageLoading.h"
#import "RNSViewFrameChangeDelegate.h"

@class RNSHeaderMenuToggleStateTracker;

NS_ASSUME_NONNULL_BEGIN

@interface RNSHeaderContentFactory : NSObject

/**
 Builds regular bar button item to be added to the list of leading or trailing items.
 It does not define a menu, but it can be added to the resulting item separately.
 */
+ (UIBarButtonItem *)barButtonItemForHeaderItem:(id<RNSHeaderItemDataProviding>)item
                        withFrameChangeDelegate:(id<RNSViewFrameChangeDelegate>)delegate
                       withHeaderEventsDelegate:(id<RNSHeaderEventsDelegate>)headerEventsDelegate
                                withImageLoader:(id<RNSImageLoading>)imageLoader;

/**
 Builds views that can be added to other areas of the header: titleView, subtitleView, largeSubtitleView.
 */
+ (UIView *)wrappedViewForHeaderItem:(id<RNSHeaderItemDataProviding>)item
                 frameChangeDelegate:(id<RNSViewFrameChangeDelegate>)delegate;

/**
 Builds a bar spacer item that can be added to the list of leading or trailing items
 to add separation to the items. Prior to iOS 26 it could resize the space between
 item; on iOS 26 and above, it separates the default liquid glass bubble.
 */
+ (UIBarButtonItem *)spacerForHeaderSpacerItem:(id<RNSHeaderItemSpacerDataProviding>)spacer;

@end

NS_ASSUME_NONNULL_END
