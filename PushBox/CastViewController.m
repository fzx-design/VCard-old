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
#import "OptionsTableViewController.h"

#import "SystemDefault.h"

#define kStatusCountPerRequest 10
#define kBlurImageViewScale 2.0
#define kCastViewScale 2.5
#define kReadingInterval 0.7

@implementation CastViewController

@synthesize regionLeftDetectButton = _regionLeftDetectButton;
@synthesize regionRightDetectButton = _regionRightDetectButton;
@synthesize blurImageView = _blurImageView;
@synthesize rootShadowLeft = _rootShadowLeft;
@synthesize castView = _castView;
@synthesize meImageView = _meImageView;

@synthesize user = _user;
@synthesize dataSource = _dataSource;
@synthesize prevDataSource = _prevDataSource;
@synthesize castViewManager = _castViewManager;
@synthesize castViewPileUpController = _castViewPileUpController;
@synthesize searchString = _searchString;

@synthesize statusTypeID = _statusTypeID;

@synthesize delegate = _delegate;

@synthesize infoStack = _infoStack;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Tools

- (BOOL)pileUpEnabled
{
    return [[SystemDefault systemDefault] pileUpEnabled] && self.dataSource == CastViewDataSourceFriendsTimeline;
}

- (void)playSoundEffect
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultKeySoundEnabled]) {
		UIAudioAddition* audioAddition = [[UIAudioAddition alloc] init];
		[audioAddition playRefreshDoneSound];
		[audioAddition release];
	}
}

#pragma mark - Initialization

- (void)setUpCastViewManager
{
	self.castViewManager.castView = self.castView;
	self.castViewManager.fetchedResultsController = self.fetchedResultsController;
	self.castViewManager.currentUser = self.currentUser;
    self.castViewManager.dataSource = self.dataSource;
	[self.castViewManager initialSetUp];
}

- (void)setUpArguments
{
	_nextPage = 1;
	_currentNextPage = 1;
	_loading = NO;
	_refreshFlag = NO;
    _shouldRefreshCardView = NO;
	_lastStatusID = 0;
    _statusTypeID = 0;
    _meImageView.hidden = YES;
    _addMoreViewsFlag = NO;
    
    _startDate = [[NSDate date] retain];
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
    self.meImageView = nil;
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

- (void)checkSearchResults
{
	int numberOfPages = self.fetchedResultsController.fetchedObjects.count;
	if (numberOfPages == 0 && self.dataSource == CastViewDataSourceSearch) {
		[ErrorNotification showNoResultsError];
	}
}

- (void)recordCurrentState
{
	CastViewInfo *castViewInfo = [[[CastViewInfo alloc] init] autorelease];
	
	castViewInfo.fetchedResultsController = self.fetchedResultsController;
	castViewInfo.nextPage = _currentNextPage;
	castViewInfo.currentIndex = self.castViewManager.currentIndex;
	castViewInfo.dataSource = self.prevDataSource;
	castViewInfo.indexCount = [self.castViewManager numberOfRows];
	castViewInfo.indexSection = self.castView.pageSection;
	castViewInfo.statusID = _lastStatusID;
    castViewInfo.statusType = _statusTypeID;
	
	self.prevDataSource = self.dataSource;
	
	[self.infoStack addObject:castViewInfo];
	
	self.fetchedResultsController = nil;
	self.fetchedResultsController.delegate = nil;
	
	self.castViewManager.fetchedResultsController = nil;
	self.castViewManager.fetchedResultsController = self.fetchedResultsController;
	self.castViewManager.currentIndex = 0;
    self.castViewManager.dataSource = self.dataSource;
	self.castView.pageSection = 1;
	
	_currentNextPage = 1;
	_oldNextPage = 1;
	_lastStatusID = 0;
    _statusTypeID = 0;
}

- (void)pushCardWithCompletion:(void (^)())completion
{
	[[UIApplication sharedApplication] showLoadingView];
	
	[self recordCurrentState];
	
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
		
		self.rootShadowLeft.alpha = 1.0;
		self.castView.transform = CGAffineTransformScale(self.castView.transform, kCastViewScale, kCastViewScale);
        self.castView.alpha = 0.0;
		
		[self loadMoreDataCompletion:^(){
			[self.castViewManager pushNewViews];
			if (completion) {
				completion();
			}
			
			[[UIApplication sharedApplication] hideLoadingView];
		}];
    }];
}

- (void)popCardWithCompletion:(void (^)())completion
{
	[[UIApplication sharedApplication] showLoadingView];
	CastViewInfo *castViewInfo = [self.infoStack lastObject];
	
	BOOL needPopAnimation = (self.infoStack.count == 1);
	
	self.dataSource = castViewInfo.dataSource;
	self.prevDataSource = self.dataSource;
	
	[self.castView moveOutViews:^() {
        
        [self.castViewManager resetAllViews];
        
		self.fetchedResultsController = castViewInfo.fetchedResultsController;
        self.fetchedResultsController.delegate = nil;
		self.dataSource = castViewInfo.dataSource;
		
		self.castViewManager.fetchedResultsController = nil;
		self.castViewManager.fetchedResultsController = self.fetchedResultsController;
        self.castViewManager.currentIndex = castViewInfo.currentIndex;
        self.castViewManager.dataSource = self.dataSource;
		self.castView.pageSection = castViewInfo.indexSection;
        
		_statusTypeID = castViewInfo.statusType;
		_lastStatusID = castViewInfo.statusID;
		
		_currentNextPage = castViewInfo.nextPage;
		
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
			
            [self didScrollToIndex:self.castViewManager.currentIndex];
			
			[self.infoStack removeLastObject];
			
            if (completion) {
                completion();
            }
			[[UIApplication sharedApplication] hideLoadingView];
        }];
	}];
}

- (void)clearCardStack
{
	while (self.infoStack.count > 1) {
		[self.infoStack removeLastObject];
	}
}

- (BOOL)inSearchMode
{
	return _prevDataSource == CastViewDataSourceSearch;
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
//    [self swipeRight];
	[self.castViewManager moveCardsToIndex:self.castViewManager.currentIndex + 1];
}

- (void)deleteCurrentCard
{
	[self.castViewManager deleteCurrentView];
    [self.delegate castViewControllerdidScrollToRow:self.castViewManager.currentIndex withNumberOfRows:[self.castViewManager numberOfRows]];
}

#pragma mark - Load Cards methods

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

- (NSString*)pileLastID
{
    Status* status = [self.fetchedResultsController.fetchedObjects objectAtIndex:[self.castViewPileUpController lastIndex]];
    
    return [NSString stringWithFormat:@"%lld", [status.statusID longLongValue] - 1];
}

- (void)checkPiles
{
	if (![self.castViewManager gotEnoughViewsToShow]) {
		[self loadMoreDataCompletion:^{
            if (_addMoreViewsFlag) {
                [self.castView addMoreViews];
            }
            _addMoreViewsFlag = NO;
        }];
	}
}

- (void)setPiles
{
    if (![self pileUpEnabled]) {
        return;
    }
    
    int i = 0;
	for (i = self.castViewPileUpController.lastIndexFR; i < self.fetchedResultsController.fetchedObjects.count; ++i) {
        Status *status = [self.fetchedResultsController.fetchedObjects objectAtIndex:i];
        
        [self.castViewPileUpController insertCardwithID:[status.statusID longLongValue] andIndexInFR:i];
        
        if ([self.castViewManager gotEnoughViewsToShow]) {
            break;
        }
    }
    
    self.castViewPileUpController.lastIndexFR = i;
    
    [self.castViewPileUpController print];
    
    [self checkPiles];

}

- (void)insertStatusFromClient:(WeiboClient *)client
{
	NSArray *dictArray = client.responseJSONObject;
	
	for (NSDictionary *dict in dictArray) {
		
        if (!dict) {
            break;
        }
        
		Status *newStatus = nil;
		
		if (self.dataSource == CastViewDataSourceFriendsTimeline) {
			
			newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
			[self.currentUser addFriendsStatusesObject:newStatus];
			
		} else if(self.dataSource == CastViewDataSourceUserTimeline){
			
			[Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
			
		} else if(self.dataSource == CastViewDataSourceMentions){
            
			[Status insertMentionedStatus:dict inManagedObjectContext:self.managedObjectContext];
            
		} else if(self.dataSource == CastViewDataSourceSearch){
            
			[Status insertTrendsStatus:dict withString:self.searchString inManagedObjectContext:self.managedObjectContext];
			
		} else if(self.dataSource == CastViewDataSourceTrends){
            
			[Status insertTrendsStatus:dict withString:self.searchString inManagedObjectContext:self.managedObjectContext];
		}
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
            
            _addMoreViewsFlag = YES;
            
//			[self clearData];
			
			[self insertStatusFromClient:client];
            
            self.castView.pageSection = 1;
			
            [self setPiles];
            
			if (self.fetchedResultsController.fetchedObjects.count != 0) {
				
				Status *status = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
				
				_lastStatusID = [status.statusID longLongValue];
			}
					
		}
		if (completion) {
			completion();
		}
		
		int count = self.fetchedResultsController.fetchedObjects.count;
		
		int numberOfRow = count > kStatusCountPerRequest ? kStatusCountPerRequest : count;
		
		[self.delegate castViewControllerdidScrollToRow:0 withNumberOfRows:numberOfRow];
						
		[[UIApplication sharedApplication] hideLoadingView];
	}];
	
	[client getFriendsTimelineSinceID:nil
								maxID:[NSString stringWithFormat:@"%lld", (long long)0]
					   startingAtPage:_currentNextPage++
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
    if (self.dataSource == CastViewDataSourceFavorites) {
        [self loadAllFavoritesWithCompletion:^(void) {
            [self.managedObjectContext processPendingChanges];
            [self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
			
			[self didScrollToIndex:self.castViewManager.currentIndex];
			
            if (completion) {
                completion();
            }
			[[UIApplication sharedApplication] hideLoadingView];
			_loading = NO;
        }];
        
        return;
    }
    

	WeiboClient *client = [WeiboClient client];
	
	[client setCompletionBlock:^(WeiboClient *client) {
		
		_loading = NO;
		
		if (!client.hasError) {
			
			[self insertStatusFromClient:client];
            
            if (self.dataSource == CastViewDataSourceFriendsTimeline) {
                
                if (_refreshFlag) {
                    
                    [self.castViewPileUpController clearPiles];
                    
                    self.castView.pageSection = 1;
                    
                }
                
                [self setPiles];
            }
			
			if (_refreshFlag) {
                
				_refreshFlag = NO;
//				
				long long statusID = 0;
				
				if (self.fetchedResultsController.fetchedObjects.count) {
					
					Status *newStatus = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
					
					statusID = [newStatus.statusID longLongValue];
				}
                
				if (_lastStatusID < statusID || [self pileUpEnabled] || _shouldRefreshCardView){
                    
                    _shouldRefreshCardView = NO;
					
                    if (_lastStatusID < statusID) {
                        
                        _oldNextPage = _currentNextPage;
                        
                        _lastStatusID = statusID;
                        
                        [self performSelector:@selector(playSoundEffect) withObject:nil afterDelay:1];
                        
                    } else {
                        _currentNextPage = _oldNextPage;
                    }
					
                    [self.castViewManager refreshCards];
                    
//					[self clearData];
//					
//					[self insertStatusFromClient:client];
					
					
				} else {
					
					_currentNextPage = _oldNextPage;
				}
			}
			
			[self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
			
			[self didScrollToIndex:self.castViewManager.currentIndex];
			
		} else {
			
			_currentNextPage = _oldNextPage;
			
//			[ErrorNotification showLoadingError];
		}
		
		if (completion) {
			completion();
		}
		
		[[UIApplication sharedApplication] hideLoadingView];
		
	}];

	if (self.dataSource == CastViewDataSourceFriendsTimeline) {
        
        if (_refreshFlag || ![self pileUpEnabled]) {
            [client getFriendsTimelineSinceID:nil
                                        maxID:(long long)0
                               startingAtPage:_currentNextPage++
                                        count:kStatusCountPerRequest
                                      feature:_statusTypeID];
        } else {
            
            [client getFriendsTimelineSinceID:nil
                                        maxID:[self pileLastID]
                               startingAtPage:0
                                        count:kStatusCountPerRequest
                                      feature:_statusTypeID];
        }
    }
    
    if (self.dataSource == CastViewDataSourceUserTimeline) {
		[client getUserTimeline:self.user.userID
						SinceID:nil
						  maxID:(long long)0
				 startingAtPage:_currentNextPage++
						  count:kStatusCountPerRequest
						feature:_statusTypeID];
    }
	
	if (self.dataSource == CastViewDataSourceMentions) {
		[client getMentionsSinceID:nil 
							 maxID:[NSString stringWithFormat:@""] 
							  page:_currentNextPage++ 
							 count:20];
	}
	if (self.dataSource == CastViewDataSourceSearch) {
		[client getTrendsStatuses:self.searchString];
	}
	if (self.dataSource == CastViewDataSourceTrends) {
		[client getTrendsStatuses:self.searchString];
	}
    
}

- (void)reload:(void (^)())completion
{
    _shouldRefreshCardView = YES;
    _refreshFlag = YES;
	_currentNextPage = 1;
    _addMoreViewsFlag = YES;
    [self loadMoreDataCompletion:completion];
}

- (void)refresh
{
	_refreshFlag = YES;
	_currentNextPage = 1;
    _addMoreViewsFlag = YES;
    [self loadMoreDataCompletion:NULL];
}

- (void)switchToSearchCards:(void (^)())completion
{
	if ([self inSearchMode]) {
		[[UIApplication sharedApplication] showLoadingView];
		_lastStatusID = 0;
		self.fetchedResultsController = nil;
		self.fetchedResultsController.delegate = nil;
		self.castViewManager.fetchedResultsController = nil;
		self.castViewManager.fetchedResultsController = self.fetchedResultsController;
        self.castViewManager.dataSource = self.dataSource;
		[self reload:^{
			[self checkSearchResults];
            if (completion) {
                completion();
            }
        }];
	} else {
		[self pushCardWithCompletion:^{
			[self checkSearchResults];
            if (completion) {
                completion();
            }
        }];
	}
}

#pragma mark - CoreDataTableViewController methods

- (void)configureRequest:(NSFetchRequest *)request
{
    NSSortDescriptor *sortDescriptor;
	
    switch (self.dataSource) {
        case CastViewDataSourceFriendsTimeline:
			sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"statusID" ascending:NO];
			request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
			
			request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat:@"isFriendsStatusOf == %@", self.currentUser];
            break;
        case CastViewDataSourceUserTimeline:
			sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"statusID" ascending:NO];
			request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
			
			request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat:@"author == %@", self.user];
            break;
        case CastViewDataSourceFavorites:
			sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
			request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
			
			request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat:@"favoritedBy == %@", self.currentUser];
			break;
		case CastViewDataSourceMentions:
			sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
			request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
			
			request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat:@"isMentioned == %@", [NSNumber numberWithBool:YES]];
			break;
		case CastViewDataSourceSearch:
			sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
			request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
			
			request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat:@"searchString == %@", self.searchString];
			break;
		case CastViewDataSourceTrends:
			sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
			request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
			
			request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat:@"searchString == %@", self.searchString];
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
	self.castViewManager.currentIndex = index;
	[self.delegate castViewControllerdidScrollToRow:index withNumberOfRows:[self.castViewManager numberOfRows]];
	
    int indexInFR = index;
    if (self.dataSource == CastViewDataSourceFriendsTimeline) {
        indexInFR = [self.castViewPileUpController indexInFRForViewIndex:index];
    }

    NSTimeInterval secondsElapsed = abs([_startDate timeIntervalSinceNow]);
    
    if (secondsElapsed > kReadingInterval) {
        [self.castViewPileUpController addNewReadID:_prevReadID];
    }
    
    if (indexInFR >= 0 && indexInFR < self.fetchedResultsController.fetchedObjects.count) {
        Status *status = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexInFR];
        _prevReadID = [status.statusID longLongValue];
    }

    [_startDate release];
    _startDate = [[NSDate date] retain];
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
    _addMoreViewsFlag = YES;
    [self loadMoreDataCompletion:^(){
        [self.castView addMoreViews];
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

- (CastViewPileUpController*)castViewPileUpController
{
	if (_castViewPileUpController == nil) {
		_castViewPileUpController = [CastViewPileUpController sharedCastViewPileUpController];
        _castViewPileUpController.managedObjectContext = self.managedObjectContext;
	}
	
	return _castViewPileUpController;
}

- (NSMutableArray*)infoStack
{
	if (_infoStack == nil) {
		_infoStack = [[NSMutableArray alloc] init];
	}
	return _infoStack;
}


@end
