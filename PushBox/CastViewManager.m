//
//  CastViewManager.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-18.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "CastViewManager.h"
#import "CardFrameViewController.h"

#define CastViewPageSize CGSizeMake(560, 640)
#define CastViewFrame CGRectMake(0.0f, 0.0f, 560, 640)
#define PreLoadCardNumber 7

@implementation CastViewManager

@synthesize cardFrames = _cardFrames;
@synthesize castView = _castView;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize currentIndex = _currentIndex;
@synthesize delegate = _delegate;
@synthesize currentUser = _currentUser;

- (void)initialSetUp
{
	self.castView.pageSize = CastViewPageSize;
	[self.castView setScrollsToTop:NO];
	self.currentIndex = 1;
}

#pragma mark - Tools

- (int)numberOfRows
{
	return self.castView.pageNum;
}

#pragma mark - Card Frames methods

- (CardFrameViewController*)getRefreshCardFrameViewControllerWithIndex:(int)index
{
	for (CardFrameViewController* cardFrameViewController in self.cardFrames) {
		if (abs(cardFrameViewController.index - self.currentIndex) == index + 2) {
			return cardFrameViewController;
		}
	}
	return nil;
}

- (CardFrameViewController*)getReusableFrameViewController
{
	for (CardFrameViewController* cardFrameViewController in self.cardFrames) {
		if (abs(cardFrameViewController.index - self.currentIndex) > 3) {
			return cardFrameViewController;
		}
	}
	return nil;
}

- (CardFrameViewController*)findCardFrameViewControllerForIndex:(int)index
{
	for (CardFrameViewController* cardFrameViewController in self.cardFrames) {
		if (cardFrameViewController.index == index) {
			return cardFrameViewController;
		}
	}
	return nil;
}

- (CardFrameViewController*)getCardFrameViewControllerForIndex:(int)index
{
	CardFrameViewController *cardFrameViewController = [self findCardFrameViewControllerForIndex:index];
	if (cardFrameViewController != nil) {
		return cardFrameViewController;
	}
	
	cardFrameViewController = [self getReusableFrameViewController];
	
	if (cardFrameViewController == nil) {
		SmartCardViewController *smartCardViewController = [[[SmartCardViewController alloc] init] autorelease];
		cardFrameViewController = [[[CardFrameViewController alloc] init] autorelease];
		cardFrameViewController.contentViewController = smartCardViewController;
		
		[self.cardFrames addObject:cardFrameViewController];
	} else {
		if (cardFrameViewController.view.superview != nil) {
			[cardFrameViewController.contentViewController clear];
//			[cardFrameViewController.view removeFromSuperview];
		}
	}
	
	cardFrameViewController.index = index;
	cardFrameViewController.contentViewController.currentUser = self.currentUser;
	cardFrameViewController.contentViewController.status = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
	cardFrameViewController.contentViewController.view.frame = CastViewFrame;
	
	return cardFrameViewController;	
}

#pragma mark - Operations

- (void)prepareForMovingCards
{
	for (CardFrameViewController* cardFrameViewController in self.cardFrames) {
		if (abs(cardFrameViewController.index - self.currentIndex) >= 2) {
			[cardFrameViewController.view removeFromSuperview];
		}
	}
}

- (void)resetCardFrameIndex
{
	for (CardFrameViewController *vc in self.cardFrames) {
		vc.index = InitialIndex;
	}
}

- (void)reloadCards
{
	[self.fetchedResultsController performFetch:nil];
	for (CardFrameViewController *cardFrameViewController in self.cardFrames) {
		if (abs(cardFrameViewController.index - self.currentIndex) <= 3) {
			cardFrameViewController.contentViewController.status = [self.fetchedResultsController.fetchedObjects objectAtIndex:cardFrameViewController.index];
		}
	}
	
	[self.castView reloadViews];
}

- (void)refreshCards
{
	[self prepareForMovingCards];
	
	CardFrameViewController* vc1 = [self getRefreshCardFrameViewControllerWithIndex:FirstPageIndex];
	CardFrameViewController* vc2 = [self getRefreshCardFrameViewControllerWithIndex:SecondPageIndex];
	
	if (self.fetchedResultsController.fetchedObjects.count > 0) {
		vc1.contentViewController.status = [self.fetchedResultsController.fetchedObjects objectAtIndex:FirstPageIndex];
	} else {
		vc1 = nil;
	}
	if (self.fetchedResultsController.fetchedObjects.count > 1) {
		vc2.contentViewController.status = [self.fetchedResultsController.fetchedObjects objectAtIndex:SecondPageIndex];
	} else {
		vc2 = nil;
	}
	
	[self resetCardFrameIndex];
	
	vc1.index = 0;
	vc2.index = 1;
	
	[self.castView refreshViewsWithFirstPage:vc1.view andSecondPage:vc2.view];
}

- (void)pushNewViews
{
	NSLog(@"Push____ numberOfPages: %d", [self itemCount:nil]);
	[self.castView resetWithCurrentIndex:0 numberOfPages:[self itemCount:nil]];
	[self reloadCards];
}

- (void)popNewViews:(CastViewInfo*)info
{
	NSLog(@"Pre info ci: %d and ic: %d", info.currentIndex, info.indexCount);
	[self.castView resetWithCurrentIndex:info.currentIndex numberOfPages:info.indexCount];
	[self reloadCards];
}

#pragma mark - GYCastViewDelegate methods

- (void)didScrollToIndex:(int)index
{
	self.currentIndex = index;
	[self.delegate castViewControllerdidScrollToRow:self.currentIndex withNumberOfRows:[self numberOfRows]];
}

- (UIView*)viewForItemAtIndex:(GYCastView *)scrollView index:(int)index
{
	NSLog(@"The index is %d and the pageNum is %d", index, self.castView.pageNum);
	
	CardFrameViewController *cardFrameViewController = [self getCardFrameViewControllerForIndex:index];
	
	return cardFrameViewController.view;
}

- (int)itemCount:(GYCastView *)scrollView
{
	int count = self.fetchedResultsController.fetchedObjects.count;
	if (count > 10 * self.castView.pageSection) {
		count = 10 * self.castView.pageSection;
	}
	return count;
}

- (void)resetViewsAroundCurrentIndex:(int)index
{
	for (CardFrameViewController *vc in self.cardFrames) {
		if (abs(vc.index - index) > 1) {
			
			NSLog(@"%d removed", vc.index);
			
			vc.index = InitialIndex;
			[vc.view removeFromSuperview];
		}
	}
}


#pragma mark - Properties

- (NSMutableArray*)cardFrames
{
	if (_cardFrames == nil) {
		_cardFrames = [[NSMutableArray alloc] init];
	}
	return _cardFrames;
}

@end
