//
//  ContentItemView.h
//  Esquire-iPad
//
//  Created by china china on 11-4-2.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridItemsView.h"

#define kLoadMoreViewContentSpace 80.0f

#define kLoadMoreLabelWidth 100.0f
#define kLoadMoreLabelHeight 20.0f

@protocol DragFreshGridViewDelegate;


@interface DragFreshGridView : GridItemsView

@property (nonatomic, readonly) BOOL isLoadingMore;
@property (nonatomic, readonly) BOOL isReloading;
@property (nonatomic, assign) id<DragFreshGridViewDelegate> freshDelegate;

- (void)startReload;
- (void)stopReload;

- (void)startLoadMore;
- (void)stopLoadMore;

@end


@protocol DragFreshGridViewDelegate <NSObject>

@optional

- (void)didStarReloadInFreshView:(DragFreshGridView *)freshView;

@end