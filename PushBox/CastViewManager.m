//
//  CastViewManager.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-18.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "CastViewManager.h"
#import "CardFrameViewController.h"
#import "OptionsTableViewController.h"

#define CastViewPageSize CGSizeMake(560, 640)
#define CastViewFrame CGRectMake(0.0f, 0.0f, 560, 640)
#define CastViewPageWidth 560
#define PreLoadCardNumber 7

@implementation CastViewManager

@synthesize cardFrames = _cardFrames;
@synthesize castView = _castView;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize currentIndex = _currentIndex;
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

- (CardFrameViewController*)getNeighborCardFrameViewControllerWithIndex
{
	for (CardFrameViewController* cardFrameViewController in self.cardFrames) {
		if (abs(cardFrameViewController.index - self.currentIndex) > 1) {
			cardFrameViewController.index = self.currentIndex;
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
		}
	}
	
	cardFrameViewController.index = index;
	cardFrameViewController.contentViewController.currentUser = self.currentUser;
	if (self.fetchedResultsController.fetchedObjects.count > index) {
		cardFrameViewController.contentViewController.status = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
	} else {
		NSLog(@"_________________Error1");
	}
	cardFrameViewController.contentViewController.view.frame = CastViewFrame;
	
	return cardFrameViewController;	
}

#pragma mark - Operations

- (void)prepareForMovingCards
{
	for (CardFrameViewController* cardFrameViewController in self.cardFrames) {
		if (abs(cardFrameViewController.index - self.currentIndex) >= 2) {
			cardFrameViewController.index = InitialIndex;
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
			if (self.fetchedResultsController.fetchedObjects.count > cardFrameViewController.index) {
				cardFrameViewController.contentViewController.status = [self.fetchedResultsController.fetchedObjects objectAtIndex:cardFrameViewController.index];
			} else {
				NSLog(@"_________________Error2");
			}
		}
	}
	
	[self.castView reloadViews];
}

- (void)playSoundEffect
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultKeySoundEnabled]) {
		UIAudioAddition* audioAddition = [[UIAudioAddition alloc] init];
		[audioAddition playRefreshDoneSound];
		[audioAddition release];
	}
}

- (void)refreshCards
{
	[self prepareForMovingCards];
	
	CardFrameViewController* vc1 = [self getNeighborCardFrameViewControllerWithIndex];
	CardFrameViewController* vc2 = [self getNeighborCardFrameViewControllerWithIndex];
	
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
	
	[self performSelector:@selector(playSoundEffect) withObject:nil afterDelay:1];
}

- (void)moveCardsToIndex:(int)index
{
	int diff = index - self.currentIndex;
	if (abs(diff) < 3) {
		[self.castView moveViewsWithPageOffset:diff andCurrentPage:index];
	} else if (diff) {
		[self prepareForMovingCards];
		
		diff = diff > 0 ? 3 : -3;
		
		CardFrameViewController* vc1 = [self getNeighborCardFrameViewControllerWithIndex];
		CardFrameViewController* vc2 = [self getNeighborCardFrameViewControllerWithIndex];
		CardFrameViewController* vc3 = [self getNeighborCardFrameViewControllerWithIndex];
		
		if (index - 1 >= 0) {
			vc1.contentViewController.status = [self.fetchedResultsController.fetchedObjects objectAtIndex:index - 1];
			vc1.index = index - 1;
		} else {
			vc1 = nil;
		}
		
		vc2.contentViewController.status = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
		vc2.index = index;
		
		if (index + 1 < [self numberOfRows]) {
			vc3.contentViewController.status = [self.fetchedResultsController.fetchedObjects objectAtIndex:index + 1];
			vc3.index = index + 1;
		} else {
			vc3 = nil;
		}
		
		
		[self.castView moveViewsWithPageOffset:diff andCurrentPage:index withFirstPage:vc1.view secondPage:vc2.view thirdPage:vc3.view];
	}
	
}

- (void)deleteCurrentView
{
	CardFrameViewController *toDelete;
	for (CardFrameViewController *cardFrameViewController in self.cardFrames) {
		if (cardFrameViewController.index - self.currentIndex == 0) {
			toDelete = cardFrameViewController;
		}
	}
	
	[UIView animateWithDuration:0.3 animations:^{
		for (CardFrameViewController *cardFrameViewController in self.cardFrames) {
			UIView* view = cardFrameViewController.view;
			if ((cardFrameViewController.index - self.currentIndex == 0)) {
				CGRect frame = view.frame;
				frame.origin.y -= 640;
				view.frame = frame;
			} else if (cardFrameViewController.index - self.currentIndex > 0) {
				CGRect frame = view.frame;
				frame.origin.x -= 560;
				view.frame = frame;
				cardFrameViewController.index--;
				
			} 
		}
	} completion:^(BOOL finished) {
		if (finished) {
			self.castView.pageNum--;
			[toDelete.view removeFromSuperview];
			toDelete.index = InitialIndex;
			[self.castView deleteView];
			[self reloadCards];
		}
	}];
}

- (void)pushNewViews
{
	[self.castView resetWithCurrentIndex:0 numberOfPages:[self itemCount:nil]];
	[self reloadCards];
}

- (void)popNewViews:(CastViewInfo*)info
{
	[self.castView resetWithCurrentIndex:info.currentIndex numberOfPages:info.indexCount];
	[self reloadCards];
}

#pragma mark - GYCastViewDelegate methods

- (UIView*)viewForItemAtIndex:(GYCastView *)scrollView index:(int)index
{
	
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
