//
//  GYCastView.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-13.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "GYCastView.h"

@implementation GYCastView

#define SHADOW_HEIGHT 20.0
#define SHADOW_INVERSE_HEIGHT 10.0
#define SHADOW_RATIO (SHADOW_INVERSE_HEIGHT / SHADOW_HEIGHT)
#define RefreshCardsOffsetPage 3
#define MoveCardsOffsetPage 2

@synthesize scrollView, pageSize, dropShadow, delegate, pageNum;


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

-(int)currentPage
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
		[self.delegate loadMoreViews];
		return;
	}
	
	UIView *view = [delegate viewForItemAtIndex:self index:page];
	
	// Position the view in our scrollview
	CGRect viewFrame = view.frame;
	viewFrame.origin.x = viewFrame.size.width * page;
	viewFrame.origin.y = 0;
	view.frame = viewFrame;
	
	if (view.superview == nil) {
		[self.scrollView addSubview:view];
	}
}

- (void)setDistantPage:(int)page WithView:(UIView*)view
{
	int index = [self currentPage] + page + MoveCardsOffsetPage;
	
	CGRect viewFrame = view.frame;
	viewFrame.origin.x = viewFrame.size.width * index;
	viewFrame.origin.y = 0;
	
	view.frame = viewFrame;
		
	[self.scrollView addSubview:view];
}

- (void)setRefreshPage:(int)page WithView:(UIView*)view
{
	[self setDistantPage:(page + RefreshCardsOffsetPage) WithView:view];
}

#pragma mark - Set Up methods

- (void)layoutSubviews
{
	if(firstLayout){
		testKey = YES;
		
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
		
		int pageCount = [delegate itemCount:self];
		scrollViewPages = [[NSMutableArray alloc] initWithCapacity:pageCount];
		
		pageNum = [delegate itemCount:self];
		
		self.scrollView.contentSize = CGSizeMake(pageNum * self.scrollView.frame.size.width, scrollView.frame.size.height);
		
		for (int i = 0; i < pageNum; ++i) {
			[self loadPage:i];
		}
		
		firstLayout = NO;
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

- (void)reloadViews
{
	[self layoutSubviews];

	int page = [self currentPage] - 3;
	for (int i = 0; i < 7; ++i) {
		[self loadPage:page + i];
	}
}

- (void)addMoreViews
{
	pageNum += 10;
	self.scrollView.contentSize = CGSizeMake(pageNum * self.scrollView.frame.size.width, scrollView.frame.size.height);
}

- (void)refreshViewsWithFirstPage:(UIView*)firstView 
					andSecondPage:(UIView*)secondView
{
	float page = [self currentPage];
	self.scrollView.contentSize = CGSizeMake((pageNum + 3) * self.scrollView.frame.size.width, scrollView.frame.size.height);
	[self setRefreshPage:FirstPageIndex WithView:firstView];
	[self setRefreshPage:SecondPageIndex WithView:secondView];
	
	
	testKey = NO;
	
	[UIView animateWithDuration:1.25 animations:^(){
		[self.scrollView setContentOffset:CGPointMake((page + MoveCardsOffsetPage + RefreshCardsOffsetPage) * self.scrollView.frame.size.width, 0)];
	}];

}


#pragma mark -
#pragma mark UIScrollViewDelegate methods

-(void)scrollViewDidScroll:(UIScrollView *)sv
{
	if (!testKey) {
		return;
	}
	int page = [self currentPage];
	
	if (prePage != page) {
		prePage = page;
		
		[self.delegate didScrollToIndex:page];
		
		page -= 3;
		for (int i = 0; i < 7; ++i) {
			[self loadPage:page + i];
		}
	}
}

- (void)setScrollsToTop:(BOOL)scrollsToTop
{
	[self.scrollView setScrollsToTop:scrollsToTop];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    int currentPage = [self currentPage];
	
	for (int i = 0; i < [scrollViewPages count]; i++) {
		UIView *viewController = [scrollViewPages objectAtIndex:i];
        if((NSNull *)viewController != [NSNull null]){
			if(i < currentPage - 1 || i > currentPage+1){
				[viewController removeFromSuperview];
				[scrollViewPages replaceObjectAtIndex:i withObject:[NSNull null]];
			}
		}
	}
	
}

- (void)dealloc 
{
	[scrollViewPages release];
	[scrollView release];
    [super dealloc];
}


@end
