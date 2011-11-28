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
#import "Status.h"
#import "UIImageViewAddition.h"
#import "NSDateAddition.h"
#import "CastViewPileUpController.h"

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
@synthesize dataSource = _dataSource;

- (void)initialSetUp
{
	self.castView.pageSize = CastViewPageSize;
	[self.castView setScrollsToTop:NO];
	self.currentIndex = 0;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(expandCurrentPile) 
                   name:kNotificationNameExpandPile 
                 object:nil];
}

#pragma mark - Tools

- (int)numberOfRows
{
	return self.castView.pageNum;
}

- (BOOL)gotEnoughViewsToShow
{
	BOOL result = YES;
	CastViewPileUpController *pileUpController = [CastViewPileUpController sharedCastViewPileUpController];
	if (self.castView.pageSection * 10 > [pileUpController itemCount]) {
		result = NO;
	}
	return result;
}

- (Status *)statusForViewIndex:(int)index
{
    
    Status* status = nil;
    int indexInFR = 0;
    
    if (self.dataSource == CastViewDataSourceFriendsTimeline) {
        CastViewPileUpController *pileUpController = [CastViewPileUpController sharedCastViewPileUpController];
        indexInFR = [pileUpController indexInFRForViewIndex:index];

    } else {
        indexInFR = index;
    }
    
    if (self.fetchedResultsController.fetchedObjects.count > indexInFR && indexInFR >= 0) {
        status = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexInFR];
    }
    
    return status;
}

- (void)configureCardFrameController:(CardFrameViewController*)vc atIndex:(int)index
{    
    if (self.dataSource == CastViewDataSourceFriendsTimeline) {
        CastViewPileUpController *pc = [CastViewPileUpController sharedCastViewPileUpController];
        [vc configureCardFrameWithStatus:[self statusForViewIndex:index] AndPile:[pc pileAtIndex:index]];
    } else {
        [vc configureCardFrameWithStatus:[self statusForViewIndex:index]];
    }
    vc.index = index;
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
    
    [self configureCardFrameController:cardFrameViewController atIndex:index];
	
	cardFrameViewController.contentViewController.currentUser = self.currentUser;
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

- (void)prepareForExpandingPile
{
    for (CardFrameViewController* cardFrameViewController in self.cardFrames) {
        if (cardFrameViewController.index - self.currentIndex > 0) {
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
            [self configureCardFrameController:cardFrameViewController atIndex:cardFrameViewController.index];
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
	
    [self configureCardFrameController:vc1 atIndex:FirstPageIndex];
    [self configureCardFrameController:vc2 atIndex:SecondPageIndex];
	
	[self resetCardFrameIndex];
	
	vc1.index = 0;
	vc2.index = 1;
	
	[self.castView refreshViewsWithFirstPage:vc1.view andSecondPage:vc2.view];
	
	[self performSelector:@selector(playSoundEffect) withObject:nil afterDelay:1];
}

- (void)moveCardsToIndex:(int)index
{
	if (index >= self.castView.pageNum) {
		return;
	}
	int diff = index - self.currentIndex;
	if (abs(diff) < 3) {
		[self.castView moveViewsWithPageOffset:diff andCurrentPage:index];
	} else if (diff) {
		[self prepareForMovingCards];
		
		diff = diff > 0 ? 3 : -3;
		
		CardFrameViewController* vc1 = [self getNeighborCardFrameViewControllerWithIndex];
		CardFrameViewController* vc2 = [self getNeighborCardFrameViewControllerWithIndex];
		CardFrameViewController* vc3 = [self getNeighborCardFrameViewControllerWithIndex];

        [self configureCardFrameController:vc1 atIndex:index - 1];
		
        [self configureCardFrameController:vc2 atIndex:index];
        
        [self configureCardFrameController:vc3 atIndex:index + 1];
        
        if (index == 0) {
            vc1 = nil;
        } else if(index == self.castView.pageNum - 1){
            vc3 = nil;
        }
		
		[self.castView moveViewsWithPageOffset:diff andCurrentPage:index withFirstPage:vc1.view secondPage:vc2.view thirdPage:vc3.view];
	}
	
}

- (void)deleteCurrentView
{
	CardFrameViewController *toDelete = nil;
	for (CardFrameViewController *cardFrameViewController in self.cardFrames) {
		if (cardFrameViewController.index - self.currentIndex == 0) {
			toDelete = cardFrameViewController;
            break;
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
            
            CastViewPileUpController *pileController = [CastViewPileUpController sharedCastViewPileUpController];
            [pileController deletePileAtIndex:self.currentIndex];
            
			[self.castView deleteView];
			[self reloadCards];
		}
	}];
}

- (void)expandCurrentPile
{
    CardFrameViewController *toExpand = nil;
	for (CardFrameViewController *cardFrameViewController in self.cardFrames) {
		if (cardFrameViewController.index - self.currentIndex == 0) {
			toExpand = cardFrameViewController;
            break;
		}
	}
	
	[UIView animateWithDuration:0.3 animations:^{
		for (CardFrameViewController *cardFrameViewController in self.cardFrames) {
			UIView* view = cardFrameViewController.view;
			if (cardFrameViewController.index - self.currentIndex > 0) {
				CGRect frame = view.frame;
				frame.origin.x += 560;
				view.frame = frame;				
			} 
		}
	} completion:^(BOOL finished) {

            [self prepareForExpandingPile];
            
            CastViewPileUpController *pileController = [CastViewPileUpController sharedCastViewPileUpController];
            [pileController deletePileAtIndex:self.currentIndex];
            
            NSLog(@"expand pile at index : %d", self.currentIndex);
            
            [self.castView resetWithCurrentIndex:self.currentIndex numberOfPages:[self itemCount:nil]];
//			[self reloadCards];
	}];
}

- (void)pushNewViews
{
	[self.castView removeAllSubviews]; 
	
	[self.castView resetWithCurrentIndex:0 numberOfPages:[self itemCount:nil]];
	
	[self reloadCards];
}

- (void)popNewViews:(CastViewInfo*)info
{
	[self.castView resetWithCurrentIndex:info.currentIndex numberOfPages:info.indexCount];
	[self reloadCards];
}

#pragma mark - Tracking View methods

- (void)configureTrackingPopover:(SliderTrackPopoverView*)popover AtIndex:(int)index andDataSource:(CastViewDataSource)dataSource
{
	int count = self.fetchedResultsController.fetchedObjects.count;
	if (index < 0 || index >= count) {
		return;
	}
	
//	Status *status = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
    Status *status = [self statusForViewIndex:index];
    
	NSString *profileImageString = status.author.profileImageURL;
	[popover.proFileImage loadImageFromURL:profileImageString
								completion:nil
							cacheInContext:self.fetchedResultsController.managedObjectContext];
	
	if (dataSource == CastViewDataSourceUserTimeline) {
		popover.screenNameLabel.text = [status.createdAt customString];
	} else {
		popover.screenNameLabel.text = status.author.screenName;
	}
	

}

#pragma mark - GYCastViewDelegate methods

- (UIView*)viewForItemAtIndex:(GYCastView *)scrollView index:(int)index
{
	
	CardFrameViewController *cardFrameViewController = [self getCardFrameViewControllerForIndex:index];
	
	return cardFrameViewController.view;
}

- (int)itemCount:(GYCastView *)scrollView
{
    int count = 0;

    if (self.dataSource == CastViewDataSourceFriendsTimeline) {
        CastViewPileUpController *controller = [CastViewPileUpController sharedCastViewPileUpController];
        count = [controller itemCount];
    } else {
        count = self.fetchedResultsController.fetchedObjects.count;
        if (count > 10 * self.castView.pageSection) {
            count = 10 * self.castView.pageSection;
        }
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
