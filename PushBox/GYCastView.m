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

-(void)loadPage:(int)page
{
	// Sanity checks
    if (page < 0) return;
    if (page >= pageNum) {
		pageNum += 10;
		self.scrollView.contentSize = CGSizeMake(pageNum * self.scrollView.frame.size.width, scrollView.frame.size.height);
		return;
	}
	
	//	UIView *view;
	
	// Check if the page is already loaded
	UIView *view = [scrollViewPages objectAtIndex:page];
	
	// if the view is null we request the view from our delegate
	if ((NSNull *)view == [NSNull null]) 
	{
		view = [delegate viewForItemAtIndex:self index:page];
		[scrollViewPages replaceObjectAtIndex:page withObject:view];
	}
	
	// add the controller's view to the scroll view	if it's not already added
	if (view.superview == nil) 
	{
		// Position the view in our scrollview
		CGRect viewFrame = view.frame;
		viewFrame.origin.x = viewFrame.size.width * page;
		viewFrame.origin.y = 0;
		
		view.frame = viewFrame;
		
		[self.scrollView addSubview:view];
	}
}

- (void)layoutSubviews
{
	// We need to do some setup once the view is visible. This will only be done once.
	if(firstLayout)
	{  
		// Position and size the scrollview. It will be centered in the view.
		CGRect scrollViewRect = CGRectMake(0, 0, pageSize.width, pageSize.height);
		scrollViewRect.origin.x = ((self.frame.size.width - pageSize.width) / 2);
		scrollViewRect.origin.y = ((self.frame.size.height - pageSize.height) / 2);
		
		scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
		scrollView.clipsToBounds = NO; // Important, this creates the "preview"
		scrollView.pagingEnabled = YES;
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.showsVerticalScrollIndicator = NO;
		scrollView.delegate = self;
		
		[self addSubview:scrollView];
		
		
		int pageCount = [delegate itemCount:self];
		scrollViewPages = [[NSMutableArray alloc] initWithCapacity:pageCount];
		
		// Fill our pages collection with empty placeholders
		for(int i = 0; i < pageCount; i++)
		{
			[scrollViewPages addObject:[NSNull null]];
		}
		
		pageNum = [delegate itemCount:self];
		
		// Calculate the size of all combined views that we are scrolling through 
		self.scrollView.contentSize = CGSizeMake([delegate itemCount:self] * self.scrollView.frame.size.width, scrollView.frame.size.height);
		
		// Load the first two pages
		[self loadPage:0];
		[self loadPage:1];
		
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

-(int)currentPage
{
	// Calculate which page is visible 
	CGFloat pageWidth = scrollView.frame.size.width;
	int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	return page;
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

-(void)scrollViewDidScroll:(UIScrollView *)sv
{
	int page = [self currentPage];
	
	if (prePage != page) {
		prePage = page;
		
		// Load the visible and neighbouring pages 
		[self loadPage:page-1];
		[self loadPage:page];
		[self loadPage:page+1];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    int currentPage = [self currentPage];
	
	for (int i = 0; i < [scrollViewPages count]; i++) {
		UIView *viewController = [scrollViewPages objectAtIndex:i];
        if((NSNull *)viewController != [NSNull null]){
			if(i < currentPage-1 || i > currentPage+1){
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
