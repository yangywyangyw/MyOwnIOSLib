//
//  ContentItemView.m
//  Esquire-iPad
//
//  Created by china china on 11-4-2.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DragFreshGridView.h"
#import "RefreshView.h"

@interface DragFreshGridView()<RefreshViewDelegate>
@property (nonatomic, retain) UIView *loadMoreView;
@property (nonatomic, retain) UILabel *loadMoreLabel;
@property (nonatomic, retain) RefreshView *reloadView;
@end

@implementation DragFreshGridView

@synthesize loadMoreView = _loadMoreView;
@synthesize loadMoreLabel = _loadMoreLabel;
@synthesize reloadView = _reloadView;

@synthesize isLoadingMore = _isLoadingMore;
@synthesize isReloading = _isReloading;

@synthesize freshDelegate;

- (void)dealloc {
    
    [_loadMoreView release];
    [_loadMoreLabel release];
    [_reloadView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
			spacing:(NSInteger)spacing
		borderWidth:(NSInteger)border
		  itemWidth:(NSInteger)itmWidth
		 itemHeight:(NSInteger)itmHeight
	scrollDirection:(GridItemsScrollDirection)dir
{
	self = [super initWithFrame:frame
						spacing:spacing
					borderWidth:border
					  itemWidth:itmWidth
					 itemHeight:itmHeight
				scrollDirection:dir];
    if (self) 
	{
        self.loadMoreView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.loadMoreLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kLoadMoreLabelWidth, kLoadMoreLabelHeight)] autorelease];
        
        [self.loadMoreView setHidden:YES];
        [self.loadMoreLabel setBackgroundColor:[UIColor clearColor]];
        [self.loadMoreLabel setTextColor:[UIColor darkGrayColor]];
        [self.loadMoreLabel setText:@"加载中..."];
        
        [self.loadMoreView addSubview:self.loadMoreLabel];
        [self addSubview:self.loadMoreView];
        
        self.reloadView = [[[RefreshView alloc]initWithOwner:self delegate:self] autorelease];
        
        _isLoadingMore = NO;
        _isReloading = NO;
        
	}
	return self;

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self sendSubviewToBack:self.loadMoreView];
}

//////loadMore

- (void)startLoadMore
{
    if (_isLoadingMore) return;
    _isLoadingMore = YES;
    self.loadMoreView.hidden = NO;
    if (self.direction == VerticalScroll || self.direction == VerticalMultipleRowsScroll) {
        self.loadMoreView.frame = CGRectMake(0, self.contentSize.height, CGRectGetWidth(self.frame), kLoadMoreViewContentSpace);
        self.contentInset = UIEdgeInsetsMake(0, 0, kLoadMoreViewContentSpace, 0);
    } else {
        self.loadMoreView.frame = CGRectMake(self.contentSize.width, 0, kLoadMoreViewContentSpace, CGRectGetHeight(self.frame));
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, kLoadMoreViewContentSpace);
    }
    
    self.loadMoreLabel.center = CGPointMake(CGRectGetWidth(self.loadMoreView.frame)/2, CGRectGetHeight(self.loadMoreView.frame)/2);
}

- (void)stopLoadMore
{
    if (!_isLoadingMore) return;
    _isLoadingMore = NO;
    self.loadMoreView.hidden = YES;
    self.contentInset = UIEdgeInsetsZero;
}


///////reload

- (void)startReload
{
    if (_isReloading) return;
    _isReloading = YES;
    [self.reloadView startLoading];
}

- (void)stopReload
{
    if (!_isReloading) return;
    _isReloading = NO;
    [self.reloadView stopLoading];
}

- (void)refreshViewDidCallBack 
{
    if ([self.freshDelegate respondsToSelector:@selector(didStarReloadInFreshView:)]) {
        [self.freshDelegate didStarReloadInFreshView:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
    [self.reloadView scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    [self.reloadView scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    [self.reloadView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
}

@end
