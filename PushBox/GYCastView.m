//
//  GYCastView.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-13.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "GYCastView.h"

#import "UIApplicationAddition.h"
#import "NSDateAddition.h"

@implementation GYCastView

#define SHADOW_HEIGHT 20.0
#define SHADOW_INVERSE_HEIGHT 10.0
#define SHADOW_RATIO (SHADOW_INVERSE_HEIGHT / SHADOW_HEIGHT)
#define RefreshCardsOffsetPage 3
#define MoveCardsOffsetPage 2

@synthesize scrollView, pageSize, dropShadow, delegate, pageNum, pageSection, scrollEnabled, scrolling;

- (void)awakeFromNib
{
	firstLayout = YES;
	dropShadow = YES;
}

- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		firstLayout = YES;
		dropShadow = YES;
	}
	
	return self;
}

- (id)initWithFrameAndPageSize:(CGRect)frame pageSize:(CGSize)size 
{    
	if (self = [self initWithFrame:frame]) 
	{
		self.pageSize = size;
    }
    return self;
}

#pragma mark - Tool Functions

- (int)currentPage
{
	CGFloat pageWidth = scrollView.frame.size.width;
	int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	return page;
}

#pragma mark - Load Page methods

- (void)loadPage:(int)page
{
	// Sanity checks
    if (page < 0) return;
    if (page >= pageNum) {
        
        if (loadingMoreViewsFlag) {
            return;
        }
        loadingMoreViewsFlag = YES;
        
        pageSection++;
        
		[self.delegate loadMoreViews];
		if ([self currentPage] == pageNum - 1) {
			[[UIApplication sharedApplication] showLoadingView];
		}
		return;
	}
    
	UIView *view = [delegate viewForItemAtIndex:self index:page];
	
	CGRect viewFrame = view.frame;
    
    int x = viewFrame.size.width * page;
    
	if (view.frame.origin.x != x) {
        viewFrame.origin.x = x;
        view.frame = viewFrame;
    }
    
	if (view.superview == nil) {
		[self.scrollView addSubview:view];
	}
}

- (void)setDistantPage:(int)page WithView:(UIView*)view
{
	int index = [self currentPage] + page;
	
	CGRect viewFrame = view.frame;
	viewFrame.origin.x = viewFrame.size.width * index;
	viewFrame.origin.y = 0;
	
	view.frame = viewFrame;
	if (view.superview == nil) {
		[self.scrollView addSubview:view];
	}
}

- (void)setRefreshPage:(int)page WithView:(UIView*)view
{
	[self setDistantPage:(page + RefreshCardsOffsetPage + MoveCardsOffsetPage) WithView:view];
}

#pragma mark - Set Up methods

- (void)reset
{
    _test = YES;
    
	animating = YES;
    
    loadingMoreViewsFlag = NO;
    
	pageSection = 1;
	
	pageNum = [delegate itemCount:self];
    
	self.scrollView.contentSize = CGSizeMake(pageNum * self.scrollView.frame.size.width, scrollView.frame.size.height);
	
	self.scrollView.contentOffset = CGPointMake(0.0, 0.0);
	
	[self.delegate resetViewsAroundCurrentIndex:0];
	
	[self.delegate didScrollToIndex:0];
	
	for (int i = 0; i < 7 ; ++i) {
		[self loadPage:i];
	}
	
	animating = NO;
}

- (void)resetWithCurrentIndex:(int)index numberOfPages:(int)page
{
	animating = YES;
    
    loadingMoreViewsFlag = NO;
	
	pageNum = page;
	
	self.scrollView.contentSize = CGSizeMake(pageNum * self.scrollView.frame.size.width, scrollView.frame.size.height);
	
	self.scrollView.contentOffset = CGPointMake(index * self.scrollView.frame.size.width, 0.0);
	
	[self.delegate resetViewsAroundCurrentIndex:index];
	
	[self.delegate didScrollToIndex:index];
	
	for (int i = index - 3; i <= index + 3; ++i) {
		[self loadPage:i];
	}
	
	animating = NO;
}

- (void)layoutSubviews
{
	if(firstLayout){
		
		firstLayout = NO;
		animating = NO;
		
		CGRect scrollViewRect = CGRectMake(0, 0, pageSize.width, pageSize.height);
		scrollViewRect.origin.x = ((self.frame.size.width - pageSize.width) / 2);
		scrollViewRect.origin.y = ((self.frame.size.height - pageSize.height) / 2);
		
		scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
		scrollView.clipsToBounds = NO;
		scrollView.pagingEnabled = YES;
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.showsVerticalScrollIndicator = NO;
		scrollView.delegate = self;
		
		[self addSubview:scrollView];
		
		[self reset];
	}
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	
	// If the point is not inside the scrollview, ie, in the preview areas we need to return
	// the scrollview here for interaction to work
	if (!CGRectContainsPoint(scrollView.frame, point)) {
		return self.scrollView;
	}
	
	// If the point is inside the scrollview there's no reason to mess with the event.
	// This allows interaction to be handled by the active subview just like any scrollview
	return [super hitTest:point	withEvent:event];
}

#pragma mark - Adjust Views in Castview

- (void)removeAllSubviews
{
	for (UIView* view in self.scrollView.subviews) {
		[view removeFromSuperview];
	}
}

- (void)changeViews
{
	[self reset];
}

- (void)reloadViews
{
	[self layoutSubviews];

	int page = [self currentPage] - 3;
	for (int i = 0; i < 7; ++i) {
		[self loadPage:page + i];
	}
}

- (void)moveOutViews:(void (^)())completion
{
	animating = YES;
	
	self.scrollView.userInteractionEnabled = NO;
	
	int page = (int)[self currentPage];
	
	[self.delegate resetViewsAroundCurrentIndex:page];
	
	self.scrollView.contentSize = CGSizeMake((pageNum + 3) * self.scrollView.frame.size.width, scrollView.frame.size.height);
	
	[UIView animateWithDuration:0.5 animations:^(){
		[self.scrollView setContentOffset:CGPointMake((page + 3) * self.scrollView.frame.size.width, 0)];
	} completion:^(BOOL finished) {
		if (finished && completion) {
			completion();
		}
		self.scrollView.userInteractionEnabled = YES;
	}];
}

- (void)deleteView
{
	CGSize size = self.scrollView.contentSize;
	size.width -= self.scrollView.frame.size.width;
	self.scrollView.contentSize = size;
	
	int page = [self currentPage];
	for (int i = page - 3; i <= page + 3; ++i) {
		[self loadPage:i];
	}
    [self.delegate didScrollToIndex:[self currentPage]];
}

- (void)addMoreViews
{

	pageNum = [self.delegate itemCount:self];
    
	int shouldNumber = (pageSection - 1) * kNumberOfCardsInSection;
    
    if (pageNum - shouldNumber < 10) {
        pageSection--;
    } 
    
    self.scrollView.contentSize = CGSizeMake(pageNum * self.scrollView.frame.size.width, scrollView.frame.size.height);
    [self.delegate didScrollToIndex:[self currentPage]];
    [self loadPage:[self currentPage] + 1];
    [self loadPage:[self currentPage] + 2];

    [[UIApplication sharedApplication] hideLoadingView];
    loadingMoreViewsFlag = NO;
}

- (void)refreshViewsWithFirstPage:(UIView*)firstView 
					andSecondPage:(UIView*)secondView
{
	animating = YES;
	
	[self setScrollEnabled:NO];
	
	int page = (int)[self currentPage];
		
	self.scrollView.contentSize = CGSizeMake((pageNum + 3) * self.scrollView.frame.size.width, scrollView.frame.size.height);
	[self setRefreshPage:FirstPageIndex WithView:firstView];
	[self setRefreshPage:SecondPageIndex WithView:secondView];
	
	self.pageNum = [self.delegate itemCount:self];
	
	[UIView animateWithDuration:1.25 animations:^(){
		[self.delegate didScrollToIndex:0];
		[self.scrollView setContentOffset:CGPointMake((page + MoveCardsOffsetPage + RefreshCardsOffsetPage) * self.scrollView.frame.size.width, 0)];
	} completion:^(BOOL finished) {
		if (finished) {
			[self reset];
			[self setScrollEnabled:YES];
		}
	}];

}

- (void)moveViewsWithPageOffset:(int)offset andCurrentPage:(int)currentPage
{
	animating = YES;
	
	self.scrollView.userInteractionEnabled = NO;
	
	int page = (int)[self currentPage];
	
	self.scrollView.contentSize = CGSizeMake((pageNum + 3) * self.scrollView.frame.size.width, scrollView.frame.size.height);
//	[self setRefreshPage:FirstPageIndex WithView:firstView];
//	[self setRefreshPage:SecondPageIndex WithView:secondView];
	
	[UIView animateWithDuration:0.75 animations:^(){
		[self.delegate didScrollToIndex:currentPage];
		[self.scrollView setContentOffset:CGPointMake((page + offset) * self.scrollView.frame.size.width, 0)];
	} completion:^(BOOL finished) {
		if (finished) {
//			[self resetViewsAroundCurrentViewWithCurrentIndex:currentPage numberOfPages:self.pageNum];
			[self resetWithCurrentIndex:currentPage numberOfPages:[self.delegate itemCount:self]];
			self.scrollView.userInteractionEnabled = YES;
		}
	}];
}

- (void)moveViewsWithPageOffset:(int)offset 
				 andCurrentPage:(int)currentPage 
				  withFirstPage:(UIView*)view1 
					 secondPage:(UIView*)view2 
					  thirdPage:(UIView*)view3
{
	animating = YES;
	
	self.scrollView.userInteractionEnabled = NO;
	
	int page = (int)[self currentPage];
		
	self.scrollView.contentSize = CGSizeMake((pageNum + 3) * self.scrollView.frame.size.width, scrollView.frame.size.height);
	
	[self setDistantPage:offset - 1 WithView:view1];
	[self setDistantPage:offset		WithView:view2];
	[self setDistantPage:offset + 1 WithView:view3];
	
	[UIView animateWithDuration:0.75 animations:^(){
		[self.delegate didScrollToIndex:currentPage];
		[self.scrollView setContentOffset:CGPointMake((page + offset) * self.scrollView.frame.size.width, 0)];
	} completion:^(BOOL finished) {
		if (finished) {
//			[self resetViewsAroundCurrentViewWithCurrentIndex:currentPage numberOfPages:self.pageNum];
			[self resetWithCurrentIndex:currentPage numberOfPages:[self.delegate itemCount:self]];
			self.scrollView.userInteractionEnabled = YES;
		}
	}];
}

#pragma mark - UIScrollViewDelegate methods

- (void)checkLoad
{
    int page = [self currentPage];
	
    _test = YES;
    
	if (prePage != page) {
        
		if (prePage > page) {
			[self loadPage:(page - 3)];
		} else {
			[self loadPage:(page + 3)];
		}
		
		prePage = page;
		
		[self.delegate didScrollToIndex:page];
		[self reloadViews];
        
	}
    
//    self.scrollView.userInteractionEnabled = YES;
}

- (void)enableScroll
{
    self.scrollView.userInteractionEnabled = NO;
}

-(void)scrollViewDidScroll:(UIScrollView *)sv
{
	if (animating) {
		return;
	}
    
    scrolling = YES;
    
	int page = [self currentPage];
    
    if (prePage == page) {
        return;
    }
    
    if (_test) {
        
        _test = NO;
        
        dispatch_queue_t scrollQueue = dispatch_queue_create("scrollQueue", NULL);
        
        dispatch_async(scrollQueue, ^{
            
            NSDate *date = [NSDate date];
            
            while ([date timeIntervalSinceNow] > -0.41) {
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self checkLoad];
            });
//           [self performSelector:@selector(checkLoad) withObject:nil afterDelay:0.0];
        });
        
        dispatch_release(scrollQueue);
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    scrolling = NO;
}

- (void)setScrollsToTop:(BOOL)scrollsToTop
{
	[self.scrollView setScrollsToTop:scrollsToTop];
}

- (void)setScrollEnabled:(BOOL)enabled
{
    self.scrollView.scrollEnabled = enabled;
}

- (void)dealloc 
{
	[scrollViewPages release];
	[scrollView release];
    [super dealloc];
}


@end
