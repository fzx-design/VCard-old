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
	self.castView.delegate = self;
	[self.castView setScrollsToTop:NO];
	self.currentIndex = 1;
}

#pragma mark - Tools

- (int)numberOfRows
{
	return self.castView.pageNum;
}

#pragma mark - Card Frames methods

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

- (CardFrameViewController*)getRefreshCardFrameViewControllerWithIndex:(int)index
{
	for (CardFrameViewController* cardFrameViewController in self.cardFrames) {
		if (cardFrameViewController.index - self.currentIndex == index + 2) {
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



#pragma mark - GYCastViewDelegate methods

- (void)didScrollToIndex:(int)index
{
	NSLog(@"Currently %d views", self.cardFrames.count);
	self.currentIndex = index;
	[self.delegate castViewControllerdidScrollToRow:self.currentIndex withNumberOfRows:[self numberOfRows]];
}

- (UIView*)viewForItemAtIndex:(GYCastView *)scrollView index:(int)index
{	
	CardFrameViewController *cardFrameViewController = [self getCardFrameViewControllerForIndex:index];
	
	return cardFrameViewController.view;
}

- (int)itemCount:(GYCastView *)scrollView
{
	return 10;
}

- (void)loadMoreViews
{
//	[self loadMoreDataCompletion:^(){
//		[self.castView addMoreViews];
//	}];
}


#pragma mark - Properties

- (NSMutableArray*)cardFrames
{
	if (_cardFrames == nil) {
//		_cardFrames = [[NSMutableArray alloc] initWithCapacity:PreLoadCardNumber];
//		for (int i = 0; i < PreLoadCardNumber; ++i) {
//			[_cardFrames replaceObjectAtIndex:i withObject:[NSNull null]];
//		}
		_cardFrames = [[NSMutableArray alloc] init];
	}
	return _cardFrames;
}

@end
