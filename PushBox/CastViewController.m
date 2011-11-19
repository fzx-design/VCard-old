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
#import "CastViewInfo.h"
#import "UIApplicationAddition.h"
#import "CardFrameViewController.h"

#define kStatusCountPerRequest 10
#define kBlurImageViewScale 2.0
#define kCastViewScale 2.5

@implementation CastViewController

@synthesize regionLeftDetectButton = _regionLeftDetectButton;
@synthesize regionRightDetectButton = _regionRightDetectButton;
@synthesize blurImageView = _blurImageView;
@synthesize rootShadowLeft = _rootShadowLeft;
@synthesize castView = _castView;

@synthesize user = _user;
@synthesize dataSource = _dataSource;
@synthesize prevDataSource = _prevDataSource;
@synthesize castViewManager = _castViewManager;

//@synthesize nextPageStack = _nextPageStack;
//@synthesize rowIndexStack = _rowIndexStack;
//@synthesize fetchedResultsControllerStack = _fetchedResultsControllerStack;

@synthesize infoStack = _infoStack;

@synthesize prevFetchedResultsController = _prevFetchedResultsController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Initialization

- (void)setUpCastViewManager
{
	self.castViewManager.castView = self.castView;
	self.castViewManager.fetchedResultsController = self.fetchedResultsController;
	self.castViewManager.currentUser = self.currentUser;
	[self.castViewManager initialSetUp];
}

- (void)setUpArguments
{
	_nextPage = 1;
	_loading = NO;
	_refreshFlag = NO;
}

- (void)setUpRefreshSettings
{
	NSInteger interval = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyRefreshingInterval];
	_timer = [NSTimer scheduledTimerWithTimeInterval:interval
											  target:self 
											selector:@selector(timerFired:) 
											userInfo:nil 
											 repeats:YES];
}

- (void)setUpNotification
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(changeRefreshingIntervalTime) 
				   name:kNotificationNameRefreshingIntervalChanged 
				 object:nil];
	[center addObserver:self selector:@selector(deleteCurrentCard) 
				   name:kNotificationNameCardShouldDeleteCard 
				 object:nil];
}

- (void)setUpView
{
	self.castView.delegate = self;
	self.blurImageView.alpha = 0.0;
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
	
	[self setUpCastViewManager];
	
	[self setUpArguments];
	
	[self setUpView];
	
	[self setUpNotification];
	
	[self setUpRefreshSettings];
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

- (void)recordCurrentState
{
	CastViewInfo *castViewInfo = [[[CastViewInfo alloc] init] autorelease];
	
	castViewInfo.fetchedResultsController = self.fetchedResultsController;
	castViewInfo.nextPage = _nextPage;
	castViewInfo.currentIndex = self.castViewManager.currentIndex;
	castViewInfo.dataSource = self.prevDataSource;
	castViewInfo.indexCount = [self.castViewManager numberOfRows];
	castViewInfo.indexSection = self.castView.pageSection;
	
	self.prevDataSource = self.dataSource;
	
	[self.infoStack addObject:castViewInfo];
	
	self.fetchedResultsController = nil;
	self.fetchedResultsController.delegate = nil;
	
	self.castViewManager.fetchedResultsController = nil;
	self.castViewManager.fetchedResultsController = self.fetchedResultsController;
	self.castViewManager.currentIndex = 0;
	self.castView.pageSection = 1;
	
	_nextPage = 1;
}

- (void)pushCardWithCompletion:(void (^)())completion
{
	[[UIApplication sharedApplication] showLoadingView];
	
	[self recordCurrentState];
	
//	[self clearData];
	
	[self loadMoreDataCompletion:nil];
	
	BOOL firstPush = (self.infoStack.count == 1);
	
	if (firstPush) {
		self.blurImageView.alpha = 0.0;
	}
	
	self.blurImageView.transform = CGAffineTransformMakeScale(kBlurImageViewScale, kBlurImageViewScale);
	
	[UIView animateWithDuration:0.5 animations:^{
		self.blurImageView.alpha = 1.0;
		self.blurImageView.transform = CGAffineTransformMakeScale(1, 1);
        self.castView.alpha = 0.0;
        self.castView.transform = CGAffineTransformScale(self.castView.transform, 1/kCastViewScale, 1/kCastViewScale);
    } completion:^(BOOL fin) {
		[self.castViewManager pushNewViews];
		self.rootShadowLeft.alpha = 1.0;
		self.castView.transform = CGAffineTransformScale(self.castView.transform, kCastViewScale, kCastViewScale);
        self.castView.alpha = 0.0;
		
		if (completion) {
			completion();
		}
		[[UIApplication sharedApplication] hideLoadingView];
    }];
}

- (BOOL)popCardWithCompletion:(void (^)())completion
{
	[[UIApplication sharedApplication] showLoadingView];
	CastViewInfo *castViewInfo = [self.infoStack lastObject];
	
	BOOL needPopAnimation = (self.infoStack.count == 1);
	
	self.dataSource = castViewInfo.dataSource;
	self.prevDataSource = self.dataSource;
	
	[self.castView moveOutViews:^() {

		self.fetchedResultsController = castViewInfo.fetchedResultsController;
        self.fetchedResultsController.delegate = nil;
		
		self.castViewManager.fetchedResultsController = nil;
		self.castViewManager.fetchedResultsController = self.fetchedResultsController;
        self.castViewManager.currentIndex = castViewInfo.currentIndex;
		self.castView.pageSection = castViewInfo.indexSection;
		self.dataSource = castViewInfo.dataSource;
		
		_nextPage = 1;
		
        [self.castViewManager popNewViews:castViewInfo];
		
        [self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
		
        self.blurImageView.alpha = 1.0;
        self.blurImageView.transform = CGAffineTransformMakeScale(1, 1);
		
		self.castView.transform = CGAffineTransformScale(self.castView.transform, 1/kCastViewScale, 1/kCastViewScale);
		self.castView.alpha = 0.0;
		[UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
			if (needPopAnimation) {
				self.blurImageView.alpha = 0.0;
				self.blurImageView.transform = CGAffineTransformMakeScale(kBlurImageViewScale, kBlurImageViewScale);
			}
			self.castView.transform = CGAffineTransformScale(self.castView.transform, kCastViewScale, kCastViewScale);
			self.castView.alpha = 1.0;
		} completion:^(BOOL fin) {
			if (!needPopAnimation) {
				self.blurImageView.alpha = 1.0;
				self.blurImageView.transform = CGAffineTransformMakeScale(1, 1);
			}
			
            [self.castViewManager didScrollToIndex:self.castViewManager.currentIndex];
			
			[self.infoStack removeLastObject];
			
            if (completion) {
                completion();
            }
			[[UIApplication sharedApplication] hideLoadingView];
        }];
	}];
	
	return needPopAnimation;
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

- (void)deleteCurrentCard
{
	[self.castViewManager deleteCurrentView];
}


#pragma mark - Load Cards methods

- (long long)getMaxID
{
	long long maxID = 0;
    Status *lastStatus = [self.fetchedResultsController.fetchedObjects lastObject];
    
    if (lastStatus && _lastStatus && !_refreshFlag) {
        NSString *statusID = lastStatus.statusID;
        maxID = [statusID longLongValue] - 1;
		_refreshFlag = NO;
    }
	
	return maxID;
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

- (void)insertFriendStatusFromClient:(WeiboClient *)client
{
	NSArray *dictArray = client.responseJSONObject;
	for (NSDictionary *dict in dictArray) {
		Status *newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
		[self.currentUser addFriendsStatusesObject:newStatus];
	}
	[self.managedObjectContext processPendingChanges];
	[self.fetchedResultsController performFetch:nil];
}

- (void)insertUserStatusFromClient:(WeiboClient *)client
{
	NSArray *dictArray = client.responseJSONObject;
	for (NSDictionary *dict in dictArray) {
		[Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
	}
	[self.managedObjectContext processPendingChanges];
	[self.fetchedResultsController performFetch:nil];
}

- (void)insertMentionsStatusFromClient:(WeiboClient *)client
{
	NSArray *dictArray = client.responseJSONObject;
	for (NSDictionary *dict in dictArray) {
		[Status insertMentionedStatus:dict inManagedObjectContext:self.managedObjectContext];
	}
	[self.managedObjectContext processPendingChanges];
	[self.fetchedResultsController performFetch:nil];
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
    	
	[client setCompletionBlock:^(WeiboClient *client) {
		if (!client.hasError) {
            
			[self clearData];
			
			[self insertFriendStatusFromClient:client];
			
//			[self reloadCards];
			
			_lastStatus = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
		
		}
		if (completion) {
			completion();
		}
		[[UIApplication sharedApplication] hideLoadingView];
	}];
	
	[client getFriendsTimelineSinceID:nil
								maxID:[NSString stringWithFormat:@"%lld", (long long)0]
					   startingAtPage:0
								count:kStatusCountPerRequest
							  feature:0];
}

- (void)loadMoreFriendTimeline:(void (^)())completion
{
	
	WeiboClient *client = [WeiboClient client];
	
	[client setCompletionBlock:^(WeiboClient *client) {
		
		_loading = NO;
		
		if (!client.hasError) {
			
			[self insertFriendStatusFromClient:client];
			
			if (_refreshFlag) {
				_refreshFlag = NO;
				
				Status *newStatus = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
				
				if (_lastStatus == nil || ![newStatus.statusID isEqualToString:_lastStatus.statusID]){
					
					_lastStatus = newStatus;
					
					[self clearData];
					
					[self insertFriendStatusFromClient:client];
										
					[self.castViewManager refreshCards];
				}
			}
			
			[self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
			
			[self.castViewManager didScrollToIndex:self.castViewManager.currentIndex];
			
		} else {
			[ErrorNotification showLoadingError];
		}
		if (completion) {
			completion();
		}
	}];
	
	[client getFriendsTimelineSinceID:nil
								maxID:[NSString stringWithFormat:@"%lld", [self getMaxID]]
					   startingAtPage:0 
								count:kStatusCountPerRequest
							  feature:0];
}

- (void)loadMoreUserTimeline:(void (^)())completion
{
	
	WeiboClient *client = [WeiboClient client];
	
	[client setCompletionBlock:^(WeiboClient *client) {
		
		_loading = NO;
		
		if (!client.hasError) {
			
			[self insertUserStatusFromClient:client];
						
			[self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
			
			[self.castViewManager didScrollToIndex:self.castViewManager.currentIndex];
			
		} else {
			[ErrorNotification showLoadingError];
		}
		
		if (completion) {
			completion();
		}
	}];
	
	[client getUserTimeline:self.user.userID
					SinceID:nil
					  maxID:[NSString stringWithFormat:@"%lld", [self getMaxID]]
			 startingAtPage:0
					  count:kStatusCountPerRequest
					feature:0];
}

- (void)loadMoreMention:(void (^)())completion
{
	
	WeiboClient *client = [WeiboClient client];
	
	[client setCompletionBlock:^(WeiboClient *client) {
		
		_loading = NO;
		
		if (!client.hasError) {
			
			[self insertMentionsStatusFromClient:client];
			
			[self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
			
			[self.castViewManager didScrollToIndex:self.castViewManager.currentIndex];
			
		} else {
			[ErrorNotification showLoadingError];
		}
		
		if (completion) {
			completion();
		}
	}];
	
	[client getMentionsSinceID:nil 
						 maxID:[NSString stringWithFormat:@""] 
						  page:_nextPage++ 
						 count:20];

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
			
			[self.castViewManager didScrollToIndex:self.castViewManager.currentIndex];
			
            if (completion) {
                completion();
            }
			[[UIApplication sharedApplication] hideLoadingView];
			_loading = NO;
        }];
        
        return;
    }
    
    if (self.dataSource == CastViewDataSourceFriendsTimeline) {
        [self loadMoreFriendTimeline:completion];
    }
    
    //
    if (self.dataSource == CastViewDataSourceUserTimeline) {
		[self loadMoreUserTimeline:completion];
    }
	
	if (self.dataSource == CastViewDataSourceMentions) {
		[self loadMoreMention:completion];
	}
//    //
//    if (self.dataSource == CastViewDataSourceSearchStatues) {
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
- (void)enableDismissRegion
{
	self.regionLeftDetectButton.enabled = YES;
	self.regionRightDetectButton.enabled = YES;
}

- (void)disableDismissRegion
{
	self.regionLeftDetectButton.enabled = NO;
	self.regionRightDetectButton.enabled = NO;
}

- (IBAction)dismissRegionTouched:(id)sender
{
	[self disableDismissRegion];
    [UserCardNaviViewController sharedUserCardDismiss];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameModalCardDismissed object:self];
}

#pragma mark - GYCastViewDelegate methods

- (void)didScrollToIndex:(int)index
{
	[self.castViewManager didScrollToIndex:index];
}

- (UIView*)viewForItemAtIndex:(GYCastView *)scrollView index:(int)index
{	
	return [self.castViewManager viewForItemAtIndex:scrollView index:index];
}

- (int)itemCount:(GYCastView *)scrollView
{
	return [self.castViewManager itemCount:scrollView];
}

- (void)loadMoreViews
{
	[self loadMoreDataCompletion:^(){
		[self.castView addMoreViews];
		NSLog(@"The number of fetched results is %d", self.fetchedResultsController.fetchedObjects.count);
	}];
}

- (void)resetViewsAroundCurrentIndex:(int)index
{
	[self.castViewManager resetViewsAroundCurrentIndex:index];
}



#pragma mark - Property
- (CastViewManager*)castViewManager
{
	if (_castViewManager == nil) {
		_castViewManager = [[CastViewManager alloc] init];
	}
	
	return _castViewManager;
}

- (NSMutableArray*)infoStack
{
	if (_infoStack == nil) {
		_infoStack = [[NSMutableArray alloc] init];
	}
	return _infoStack;
}


@end
