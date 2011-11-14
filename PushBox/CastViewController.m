//
//  CastViewController.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-14.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "CastViewController.h"
#import "PushBoxAppDelegate.h"
#import "WeiboClient.h"
#import "Status.h"
#import "User.h"
#import "UIApplicationAddition.h"
#import "CardFrameViewController.h"

#define CastViewPageSize CGSizeMake(560, 640)
#define kStatusCountPerRequest 10
#define kBlurImageViewScale 2.27

@implementation CastViewController

@synthesize regionLeftDetectButton = _regionLeftDetectButton;
@synthesize regionRightDetectButton = _regionRightDetectButton;
@synthesize blurImageView = _blurImageView;
@synthesize rootShadowLeft = _rootShadowLeft;
@synthesize castView = _castView;

@synthesize user = _user;
@synthesize dataSource = _dataSource;

@synthesize delegate = _delegate;
@synthesize currentIndex = _currentIndex;

@synthesize prevFetchedResultsController = _prevFetchedResultsController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.blurImageView = nil;
	self.castView = nil;
	self.rootShadowLeft = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.fetchedResultsController.delegate = nil;
	self.castView.pageSize = CastViewPageSize;
	self.castView.delegate = self;
	[self.castView setScrollsToTop:NO];
	
	_nextPage = 1;
	self.currentIndex = 0;
	self.blurImageView.alpha = 0.0;
	_loading = NO;
	_refreshFlag = NO;
	
	NSInteger interval = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyRefreshingInterval];
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(changeRefreshingIntervalTime) 
				   name:kNotificationNameRefreshingIntervalChanged 
				 object:nil];
	[center addObserver:self selector:@selector(deleteCurrentCard) 
				   name:kNotificationNameCardShouldDeleteCard 
				 object:nil];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval
											  target:self 
											selector:@selector(timerFired:) 
											userInfo:nil 
											 repeats:YES];
}

#pragma mark - Get Unread methods

- (void)changeRefreshingIntervalTime
{
	[_timer invalidate];
	
	NSInteger interval = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyRefreshingInterval];
	
	_timer = [NSTimer scheduledTimerWithTimeInterval:interval
											  target:self 
											selector:@selector(timerFired:) 
											userInfo:nil 
											 repeats:YES];
}

- (void)getUnread
{
    WeiboClient *client = [WeiboClient client];
    [client setCompletionBlock:^(WeiboClient *client) {
        if (!client.hasError) {
			
			BOOL notificationFlag = NO;
			
            NSDictionary *dict = client.responseJSONObject;
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            if ([[dict objectForKey:@"comments"] intValue]) {
                [center postNotificationName:kNotificationNameNewCommentsToMe object:self];
				notificationFlag = YES;
            }
            if ([[dict objectForKey:@"followers"] intValue]) {
                [center postNotificationName:kNotificationNameNewFollowers object:self];
				notificationFlag = YES;
            }
			if ([[dict objectForKey:@"mentions"] intValue]) {
				[center postNotificationName:kNotificationNameNewMentions object:self];
				notificationFlag = YES;
			}
            if ([[dict objectForKey:@"new_status"] intValue]) {
                [center postNotificationName:kNotificationNameNewStatuses object:self];
            }
			if (notificationFlag) {
				[center postNotificationName:kNotificationNameNewNotification object:self userInfo:dict];
			}
        }
    }];
    
    NSString *sinceID = nil;
    if (self.dataSource == CastViewDataSourceFriendsTimeline) {
        if (self.fetchedResultsController.fetchedObjects.count) {
            Status *newest = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];

            sinceID = newest.statusID;
            NSLog(@"%@", newest.text);
        }
    }
    [client getUnreadCountSinceStatusID:sinceID];
}

- (void)timerFired:(NSTimer *)timer
{
    [self getUnread];
}

#pragma mark - Push And Pop Cards methods

- (void)pushCardWithCompletion:(void (^)())completion
{
	
}

- (void)popCardWithCompletion:(void (^)())completion
{
	
}

#pragma mark - Card Movement Settings methods

- (void)scrollToRow:(int)row
{
	
}

- (void)configureUsability
{
	
}

- (void)swipeRight
{
	
}

- (void)swipeLeft
{
	
}

- (void)showNextCard
{
    [self swipeRight];
}

#pragma mark - Refresh Animation methods

- (void)moveCardsIn
{
	CGRect frame = self.castView.frame;
	frame.origin.x += 782;
	self.castView.frame = frame;
	
	[UIView animateWithDuration:1.0 delay:0.5 options:0 animations:^{
		self.castView.alpha = 1.0;
		CGRect frame = self.castView.frame;
		frame.origin.x -= 782;
		self.castView.frame = frame;
	} completion:^(BOOL finished) {
		if (finished) {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultKeySoundEnabled]) {
				UIAudioAddition* audioAddition = [[UIAudioAddition alloc] init];
				[audioAddition playRefreshDoneSound];
				[audioAddition release];
			}
		}
	}];
}

- (void)processData
{
	[self scrollToRow:0];
}

- (void)adjustCardViewPosition
{
    [self performSelector:@selector(processData) withObject:nil afterDelay:1.0];
	[self performSelector:@selector(moveCardsIn) withObject:nil afterDelay:0.5];
}

- (void)adjustCardViewAfterLoadingWithCompletion:(void (^)())completion
{
	[UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
		self.castView.alpha = 0.0;
	} completion:^(BOOL finished) {
		if (finished) {
			if (completion) {
				completion();
			}
			[self adjustCardViewPosition];
		}
 	}];
}


#pragma mark - Load Cards methods

- (int)numberOfRows
{
	return [self.fetchedResultsController.fetchedObjects count];
}

- (void)clearData
{
    switch (self.dataSource) {
        case CastViewDataSourceUserTimeline:
            [self.user removeStatuses:self.user.statuses];
            break;
        case CastViewDataSourceFriendsTimeline:
            [self.currentUser removeFriendsStatuses:self.currentUser.friendsStatuses];
            break;
        case CastViewDataSourceFavorites:
            [self.currentUser removeFavorites:self.currentUser.favorites];
            break;
		case CastViewDataSourceMentions:
//			[self.currentUser removestatuses::<#(Status *)#>]
			break;
		default:
			break;
    }
    [self.managedObjectContext processPendingChanges];
}

- (void)loadAllFavoritesWithCompletion:(void (^)())completion
{
    WeiboClient *client = [WeiboClient client];
    
    WCCompletionBlock block = ^(WeiboClient *client) {
        if (!client.hasError) {
            NSArray *dictsArray = client.responseJSONObject;
            if ([dictsArray count]) {
                for (NSDictionary *dict in dictsArray) {
                    Status *status = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
                    [self.currentUser addFavoritesObject:status];
                }
            }
            else {
                _nextPage = 1;
            }
			if (completion) {
				completion();
			}
        } else {
			[self loadAllFavoritesWithCompletion:completion];
		}
    };
    
    [client setCompletionBlock:block];
    [client getFavoritesByPage:_nextPage++];
}

- (void)firstLoad:(void (^)())completion
{
	WeiboClient *client = [WeiboClient client];
    
    long long maxID = 0;
    Status *lastStatus = [self.fetchedResultsController.fetchedObjects lastObject];
	
	NSLog(@"%@", lastStatus.text);
    if (lastStatus && _lastStatus && !_refreshFlag) {
        NSString *statusID = lastStatus.statusID;
        maxID = [statusID longLongValue] - 1;
		[[UIApplication sharedApplication] showLoadingView];
    }
	
	[client setCompletionBlock:^(WeiboClient *client) {
		if (!client.hasError) {
			
			NSArray *dictArray = client.responseJSONObject;
            
			[self clearData];
			[self.managedObjectContext processPendingChanges];
			for (NSDictionary *dict in dictArray) {
				Status *newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
				[self.currentUser addFriendsStatusesObject:newStatus];
			}
			[self.managedObjectContext processPendingChanges];
			_lastStatus = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
			if (completion) {
				completion();
			}
			[[UIApplication sharedApplication] hideLoadingView];
            
			return;
            
		} 
		if (completion) {
			completion();
		}
		[[UIApplication sharedApplication] hideLoadingView];
	}];
	
	[client getFriendsTimelineSinceID:nil
								maxID:[NSString stringWithFormat:@"%lld", maxID]
					   startingAtPage:0
								count:kStatusCountPerRequest
							  feature:0];
}

- (void)loadMoreDataCompletion:(void (^)())completion
{
    if (_loading) {
        return;
    }
    _loading = YES;
    
	//
    if (self.dataSource == CardTableViewDataSourceFavorites) {
        [self loadAllFavoritesWithCompletion:^(void) {
            [self.managedObjectContext processPendingChanges];
            [self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
            [self.delegate castViewController:self 
                                    didScrollToRow:self.currentIndex
                                  withNumberOfRows:[self numberOfRows]];
            if (completion) {
                completion();
            }
			[[UIApplication sharedApplication] hideLoadingView];
			_loading = NO;
        }];
        
        return;
    }
    
    WeiboClient *client = [WeiboClient client];
    
    long long maxID = 0;
    Status *lastStatus = [self.fetchedResultsController.fetchedObjects lastObject];
    
	NSLog(@"%@", lastStatus.text);
    if (lastStatus && _lastStatus && !_refreshFlag) {
        NSString *statusID = lastStatus.statusID;
        maxID = [statusID longLongValue] - 1;
		_refreshFlag = NO;
		[[UIApplication sharedApplication] showLoadingView];
    }
    
    //
    if (self.dataSource == CardTableViewDataSourceFriendsTimeline) {
        [client setCompletionBlock:^(WeiboClient *client) {
            if (!client.hasError) {
                
                NSArray *dictArray = client.responseJSONObject;
				
				for (NSDictionary *dict in dictArray) {
                    Status *newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
                    [self.currentUser addFriendsStatusesObject:newStatus];
                }
				
				[self.managedObjectContext processPendingChanges];
                
				if (_refreshFlag) {
					_refreshFlag = NO;
                    
					Status *newStatus = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
					
					if (_lastStatus == nil || ![newStatus.statusID isEqualToString:_lastStatus.statusID]){
						_lastStatus = newStatus;
						
						[self adjustCardViewAfterLoadingWithCompletion:^(){
							[self clearData];
							for (NSDictionary *dict in dictArray) {
								Status *newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
								[self.currentUser addFriendsStatusesObject:newStatus];
							}
							[self.managedObjectContext processPendingChanges];
						}];
						
					} else if ([newStatus.statusID isEqualToString:_lastStatus.statusID]) {
						if (completion) {
							completion();
						}
						[[UIApplication sharedApplication] hideLoadingView];
						_loading = NO;
						return;
					}
				}
                [self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
                [self.delegate castViewController:self 
                                        didScrollToRow:self.currentIndex
                                      withNumberOfRows:[self numberOfRows]];
            } else {
				[ErrorNotification showLoadingError];
			}
			if (completion) {
				completion();
			}
			[[UIApplication sharedApplication] hideLoadingView];
			_loading = NO;
        }];
        
        [client getFriendsTimelineSinceID:nil
									maxID:[NSString stringWithFormat:@"%lld", maxID]
                           startingAtPage:0 
                                    count:kStatusCountPerRequest
                                  feature:0];
    }
    
    //
    if (self.dataSource == CardTableViewDataSourceUserTimeline) {
        [[UIApplication sharedApplication] showLoadingView];
		[client setCompletionBlock:^(WeiboClient *client) {
            if (!client.hasError) {
				
                NSArray *dictArray = client.responseJSONObject;
				for (NSDictionary *dict in dictArray) {
					[Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
                }
				[self.managedObjectContext processPendingChanges];
				
				if (_refreshFlag) {
					_refreshFlag = NO;
					
					Status *newStatus = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
					
					if (_lastStatus == nil || ![newStatus.statusID isEqualToString:_lastStatus.statusID]) {
						
						[self adjustCardViewAfterLoadingWithCompletion:^(){
							[self clearData];
							[self.managedObjectContext processPendingChanges];
							
							for (NSDictionary *dict in dictArray) {
								[Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
							}
						}];
						
					} else if ([newStatus.statusID isEqualToString:_lastStatus.statusID]) {
						if (completion) {
							completion();
						}
						[[UIApplication sharedApplication] hideLoadingView];
						_loading = NO;
						return;
					} 
				}
                
                [self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
                [self.delegate castViewController:self 
                                        didScrollToRow:self.currentIndex
                                      withNumberOfRows:[self numberOfRows]];
                
                if (completion) {
                    completion();
                }
				
            } else {
				if (completion) {
                    completion();
                }
				[ErrorNotification showLoadingError];
			}
			[[UIApplication sharedApplication] hideLoadingView];
			_loading = NO;
        }];
        
        [client getUserTimeline:self.user.userID
                        SinceID:nil
						  maxID:[NSString stringWithFormat:@"%lld", maxID]
                 startingAtPage:0
                          count:kStatusCountPerRequest
                        feature:0];
    }
    
//    //
//    if (self.dataSource == CardTableViewDataSourceSearchStatues) {
//        [[UIApplication sharedApplication] showLoadingView];
//		[client setCompletionBlock:^(WeiboClient *client) {
//            if (!client.hasError) {
//				
//                NSArray *dictArray = client.responseJSONObject;
//				for (NSDictionary *dict in dictArray) {
//                    Status *newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
//                    [self.currentUser addFriendsStatusesObject:newStatus];
//                }
//				[self.managedObjectContext processPendingChanges];
//				
//				if (_refreshFlag) {
//					_refreshFlag = NO;
//					
//					Status *newStatus = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
//					
//					if (_lastStatus == nil || ![newStatus.statusID isEqualToString:_lastStatus.statusID]){
//						_lastStatus = newStatus;
//						[self scrollToRow:0];
//						
//					} else if ([newStatus.statusID isEqualToString:_lastStatus.statusID]) {
//						if (completion) {
//							completion();
//						}
//						[[UIApplication sharedApplication] hideLoadingView];
//						_loading = NO;
//						return;
//					} 
//				}
//                
//                [self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
//                [self.delegate castViewController:self 
//                                        didScrollToRow:self.currentIndex
//                                      withNumberOfRows:[self numberOfRows]];
//                
//                if (completion) {
//                    completion();
//                }
//				
//            } else {
//				if (completion) {
//                    completion();
//                }
//				[ErrorNotification showLoadingError];
//			}
//			[[UIApplication sharedApplication] hideLoadingView];
//			_loading = NO;
//        }];
//        
//        [client getTrendsStatuses:self.searchString];
//    }
//	
//	//
//	if (self.dataSource == CardTableViewDataSourceMentions) {
//		[client setCompletionBlock:^(WeiboClient *client) {
//            if (!client.hasError) {
//				
//                NSArray *dictArray = client.responseJSONObject;
//				
//				for (NSDictionary *dict in dictArray) {
//                    Status * status = [Status insertMentionedStatus:dict inManagedObjectContext:self.managedObjectContext];
//					NSLog(@"%@", status.text);
//                }
//				
//				[self.managedObjectContext processPendingChanges];
//				
//				if (_refreshFlag) {
//					_refreshFlag = NO;
//					
//					Status *newStatus = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
//					
//					if (_lastMentionStatusID == nil || ![newStatus.statusID isEqualToString:_lastMentionStatusID]){
//						[_lastMentionStatusID release];
//						_lastMentionStatusID = [[NSString stringWithString:newStatus.statusID] copy];
//						
//						[self adjustCardViewAfterLoadingWithCompletion:^(){
//							[self clearData];
//							for (NSDictionary *dict in dictArray) {
//								[Status insertMentionedStatus:dict inManagedObjectContext:self.managedObjectContext];
//							}
//							[self.managedObjectContext processPendingChanges];
//						}];
//						
//					} else if ([newStatus.statusID isEqualToString:_lastMentionStatusID]) {
//						[self adjustCardViewAfterLoadingWithCompletion:nil];
//						[[UIApplication sharedApplication] hideLoadingView];
//						_loading = NO;
//						[self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
//						[self.delegate cardTableViewController:self 
//												didScrollToRow:self.currentRowIndex
//											  withNumberOfRows:[self numberOfRows]];
//						if (completion) {
//							completion();
//						}
//						return;
//					}
//				}
//                [self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
//                [self.delegate cardTableViewController:self 
//                                        didScrollToRow:self.currentRowIndex
//                                      withNumberOfRows:[self numberOfRows]];
//				if (completion) {
//					completion();
//				}
//            } else {
//				[ErrorNotification showLoadingError];
//			}
//			[[UIApplication sharedApplication] hideLoadingView];
//			_loading = NO;
//        }];
//		
//		[client getMentionsSinceID:nil 
//							 maxID:[NSString stringWithFormat:@""] 
//							  page:_nextPageForMention++ 
//							 count:20];
        
//	}
}

- (void)refresh
{
	_refreshFlag = YES;
    [self loadMoreDataCompletion:NULL];
}

#pragma mark - CoreDataTableViewController methods

- (void)configureRequest:(NSFetchRequest *)request
{
    NSSortDescriptor *sortDescriptor;
	
    switch (self.dataSource) {
        case CardTableViewDataSourceFriendsTimeline:
			sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"statusID" ascending:NO];
			request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
			
			request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat:@"isFriendsStatusOf == %@", self.currentUser];
            break;
        case CardTableViewDataSourceUserTimeline:
			sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"statusID" ascending:NO];
			request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
			
			request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat:@"author == %@", self.user];
            break;
        case CardTableViewDataSourceFavorites:
			sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
			request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
			
			request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat:@"favoritedBy == %@", self.currentUser];
			break;
		case CardTableViewDataSourceMentions:
			sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
			request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
			
			request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat:@"isMentioned == %@", [NSNumber numberWithBool:YES]];
			break;
		default:
			break;
    }
}

- (NSString *)customCellClassName
{
    return @"CardTableViewCell";
}

#pragma mark - Usercard Dismiss methods
-(void)enableDismissRegion
{
	self.regionLeftDetectButton.enabled = YES;
	self.regionRightDetectButton.enabled = YES;
}

-(void)disableDismissRegion
{
	self.regionLeftDetectButton.enabled = NO;
	self.regionRightDetectButton.enabled = NO;
}

-(IBAction)dismissRegionTouched:(id)sender
{
	[self disableDismissRegion];
    [UserCardNaviViewController sharedUserCardDismiss];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameModalCardDismissed object:self];
}

#pragma mark - GYCastViewDelegate methods

-(UIView*)viewForItemAtIndex:(GYCastView *)scrollView index:(int)index
{
	CGRect viewFrame = CGRectMake(0.0f, 0.0f, 560, 645);
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
	
	SmartCardViewController *smartCardViewController = [[SmartCardViewController alloc] init];
	
	smartCardViewController.currentUser = self.currentUser;
	smartCardViewController.status = [self.fetchedResultsController objectAtIndexPath:indexPath];
	smartCardViewController.view.frame = viewFrame;
	
	CardFrameViewController *cardFrameViewController = [[CardFrameViewController alloc] init];
	cardFrameViewController.contentViewController = smartCardViewController;
	
	[smartCardViewController release];
	
	return cardFrameViewController.view;
}

-(int)itemCount:(GYCastView *)scrollView
{
	return 10;
}

@end
