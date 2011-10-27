//
//  CardTableViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-26.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CardTableViewController.h"
#import "PushBoxAppDelegate.h"
#import "WeiboClient.h"
#import "Status.h"
#import "User.h"
#import "UIApplicationAddition.h"

#define kCardWidth 570
#define kCardHeight 640
#define kHeaderAndFooterWidth 232.0

#define kStatusCountPerRequest 10

#define kBlurImageViewScale 2.27

@interface CardTableViewController(){
	CGPoint startPoint;
}
@property(nonatomic, retain) UITableViewCell *tempCell;
@end

@implementation CardTableViewController

@synthesize regionLeftDetectButton;
@synthesize regionRightDetectButton;
@synthesize rootShadowLeft = _rootShadowLeft;
@synthesize tempCell = _tempCell;
@synthesize delegate = _delegate;
@synthesize currentRowIndex = _currentRowIndex;
@synthesize swipeEnabled = _swipeEnabled;
@synthesize blurImageView = _blurImageView;
@synthesize dataSource = _dataSource;
@synthesize user = _user;
@synthesize prevFetchedResultsController = _prevFetchedResultsController;
@synthesize prevRowIndex = _prevRowIndex;
@synthesize insertionAnimationEnabled = _insertionAnimationEnabled;
@synthesize searchString;

- (void)dealloc
{
    NSLog(@"CardTableViewController dealloc");
    [_tempCell release];
    [_blurImageView release];
    [_user release];
    [_prevFetchedResultsController release];
    [_timer invalidate];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.blurImageView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.scrollEnabled = YES;
	self.tableView.pagingEnabled = YES;
	
	CGRect oldFrame = self.tableView.frame;
	
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
	self.tableView.frame = oldFrame;
	self.tableView.delegate = self;
	self.tableView.showsVerticalScrollIndicator = NO;
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kHeaderAndFooterWidth)];
    header.userInteractionEnabled = NO;
    header.backgroundColor = [UIColor clearColor];
    [self.tableView setTableHeaderView:header];
    [header release];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kHeaderAndFooterWidth)];
    footer.userInteractionEnabled = NO;
    footer.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:footer];
    [footer release];
    
	[self.tableView setScrollsToTop:NO];
    self.currentRowIndex = 0;
    self.swipeEnabled = YES;
    self.blurImageView.alpha = 0.0;
    self.insertionAnimationEnabled = YES;
    _nextPage = 1;
    _loading = NO;
	_checkingDirection = NO;
	_refreshFlag = NO;
	
	NSInteger interval = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyRefreshingInterval];
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(changeRefreshingIntervalTime) 
				   name:kNotificationNameRefreshingIntervalChanged 
				 object:nil];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval
											  target:self 
											selector:@selector(timerFired:) 
											userInfo:nil 
											 repeats:YES];
}

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

- (BOOL)insertionAnimationEnabled
{
    return [[self.fetchedResultsController fetchedObjects] count] < 2;
}

- (void)timerFired:(NSTimer *)timer
{
    [self getUnread];
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
    if (self.dataSource == CardTableViewDataSourceFriendsTimeline) {
        if (self.fetchedResultsController.fetchedObjects.count) {
            Status *newest = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
            sinceID = newest.statusID;
            NSLog(@"%@", newest.text);
        }
    }
    [client getUnreadCountSinceStatusID:sinceID];
}

-(void)setHeaderViewWithOffset{
	self.tableView.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 232 + 464 * self.currentRowIndex)] autorelease];
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.tableView numberOfRowsInSection:0] == indexPath.row + 1) {
        [self performSelector:@selector(loadMoreDataCompletion:) withObject:nil afterDelay:0.5];
    }
	
	NSInteger indexDiff = indexPath.row - self.currentRowIndex;
	CGFloat diff = self.tableView.contentOffset.y + 464 * indexDiff;
	
	self.currentRowIndex += indexDiff;
	[self setHeaderViewWithOffset];
	[self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, diff) animated:NO];
	[self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.currentRowIndex * 1024) animated:YES];
	
	[self.delegate cardTableViewController:self didScrollToRow:self.currentRowIndex withNumberOfRows:[self numberOfRows]];
	[self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
}

- (void)scrollToRow:(int)row
{
    if (row == self.currentRowIndex) {
        return;
    }
    if (row >= 0 && row < [self numberOfRows]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self scrollToRowAtIndexPath:indexPath];
    }
}

- (void)pushCardWithCompletion:(void (^)())completion
{
    if (!self.prevFetchedResultsController) {
        self.prevFetchedResultsController = self.fetchedResultsController;
        self.prevRowIndex = self.currentRowIndex;
    }
	
	[[UIApplication sharedApplication] showLoadingView];
	
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    self.currentRowIndex = 0;
	
	if (self.dataSource == CardTableViewDataSourceMentions) {
		_refreshFlag = YES;
	}
	
    self.blurImageView.alpha = 0.0;
	self.blurImageView.transform = CGAffineTransformMakeScale(kBlurImageViewScale, kBlurImageViewScale);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.blurImageView.alpha = 1.0;
        self.blurImageView.transform = CGAffineTransformMakeScale(1, 1);
        self.tableView.alpha = 0.0;
        self.tableView.transform = CGAffineTransformScale(self.tableView.transform, 1/kBlurImageViewScale, 1/kBlurImageViewScale);
    } completion:^(BOOL fin) {
		[self clearData];
		[self setHeaderViewWithOffset];
        [self.tableView reloadData];
        self.tableView.transform = CGAffineTransformScale(self.tableView.transform, kBlurImageViewScale, kBlurImageViewScale);
        self.tableView.alpha = 0.0;
		self.rootShadowLeft.alpha = 1.0;
        [self loadMoreDataCompletion:completion];
		
    }];
}

- (void)pushCardWithoutCompletion
{
	[[UIApplication sharedApplication] showLoadingView];
	
    if (!self.prevFetchedResultsController) {
        self.prevFetchedResultsController = self.fetchedResultsController;
        self.prevRowIndex = self.currentRowIndex;
    }
	
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    self.currentRowIndex = 0;
	
    self.blurImageView.alpha = 0.0;
	self.blurImageView.transform = CGAffineTransformMakeScale(kBlurImageViewScale, kBlurImageViewScale);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.blurImageView.alpha = 1.0;
        self.blurImageView.transform = CGAffineTransformMakeScale(1, 1);
        self.tableView.alpha = 0.0;
        self.tableView.transform = CGAffineTransformScale(self.tableView.transform, 1/kBlurImageViewScale, 1/kBlurImageViewScale);
    }];
}

- (void)popCardWithCompletion:(void (^)())completion
{
	[[UIApplication sharedApplication] showLoadingView];
	
    self.dataSource = CardTableViewDataSourceFriendsTimeline;
	[UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
		self.tableView.alpha = 0.0;
	} completion:^(BOOL fin) {
		self.fetchedResultsController = self.prevFetchedResultsController;
        self.fetchedResultsController.delegate = self;
        self.prevFetchedResultsController = nil;
        self.currentRowIndex = self.prevRowIndex;
		
        self.prevRowIndex = 0;
		[self setHeaderViewWithOffset];
        [self.tableView reloadData];
		
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentRowIndex inSection:0]
                              atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:NO];
        [self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
		
        self.blurImageView.alpha = 1.0;
        self.blurImageView.transform = CGAffineTransformMakeScale(1, 1);
		self.tableView.transform = CGAffineTransformScale(self.tableView.transform, 1/kBlurImageViewScale, 1/kBlurImageViewScale);
		[UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            self.blurImageView.alpha = 0.0;
            self.blurImageView.transform = CGAffineTransformMakeScale(kBlurImageViewScale, kBlurImageViewScale);
			self.tableView.transform = CGAffineTransformScale(self.tableView.transform, kBlurImageViewScale, kBlurImageViewScale);
			self.tableView.alpha = 1.0;
		} completion:^(BOOL fin) {
            [self.delegate cardTableViewController:self 
                                    didScrollToRow:self.currentRowIndex 
                                  withNumberOfRows:[self numberOfRows]];
            if (completion) {
                completion();
            }
			[[UIApplication sharedApplication] hideLoadingView];
        }];
	}];
}

- (int)numberOfRows
{
    return [self.tableView numberOfRowsInSection:0];
}

- (void)configureUsability
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentRowIndex inSection:0];
    NSIndexPath *prev = [NSIndexPath indexPathForRow:self.currentRowIndex - 1 inSection:0];
    NSIndexPath *next = [NSIndexPath indexPathForRow:self.currentRowIndex + 1 inSection:0];
    
    [[self.tableView cellForRowAtIndexPath:indexPath] setUserInteractionEnabled:YES];
    [[self.tableView cellForRowAtIndexPath:prev] setUserInteractionEnabled:NO];
    [[self.tableView cellForRowAtIndexPath:next] setUserInteractionEnabled:NO];
}

- (void)swipeRight:(UISwipeGestureRecognizer *)ges
{
    if (!self.swipeEnabled) {
        return;
    }
	NSArray *indexArray = [self.tableView indexPathsForVisibleRows];
	NSIndexPath *nextIndex = [indexArray lastObject];
	
    [self scrollToRowAtIndexPath:nextIndex];
    [self.delegate cardTableViewController:self didScrollToRow:nextIndex.row withNumberOfRows:[self numberOfRows]];
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)ges
{
    if (!self.swipeEnabled) {
        return;
    }
	NSArray *indexArray = [self.tableView indexPathsForVisibleRows];
	NSIndexPath *nextIndex = [indexArray objectAtIndex:0];
    
    [self scrollToRowAtIndexPath:nextIndex];
    [self.delegate cardTableViewController:self didScrollToRow:nextIndex.row withNumberOfRows:[self numberOfRows]];
}

- (void)showNextCard
{
    [self swipeRight:nil];
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
                [self loadAllFavoritesWithCompletion:completion];
            }
            else {
                _nextPage = 1;
                if (completion) {
                    completion();
                }
            }
        } else {
			if (completion) {
				completion();
			}
		}
    };
    
    [client setCompletionBlock:block];
    [client getFavoritesByPage:_nextPage++];
}

- (void)moveCardsIn
{
	CGRect frame = self.tableView.frame;
	frame.origin.x += 782;
	self.tableView.frame = frame;
	
	[UIView animateWithDuration:1.0 delay:0.5 options:0 animations:^{
		self.tableView.alpha = 1.0;
		CGRect frame = self.tableView.frame;
		frame.origin.x -= 782;
		self.tableView.frame = frame;
	} completion:^(BOOL finished) {
        UIAudioAddition* audioAddition = [[UIAudioAddition alloc] init];
        [audioAddition playRefreshDoneSound];
        [audioAddition release];
	}];
}

- (void)adjustCardViewPosition
{
	[self.managedObjectContext processPendingChanges];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self scrollToRowAtIndexPath:indexPath];
	
	[self performSelector:@selector(moveCardsIn) withObject:nil afterDelay:0.5];
	
}

- (void)adjustCardViewAfterLoadingWithCompletion:(void (^)())completion
{
	[UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
		self.tableView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[self adjustCardViewPosition];
		if (completion) {
			completion();
		}
 	}];
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
            [self.delegate cardTableViewController:self 
                                    didScrollToRow:self.currentRowIndex
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
                [self.delegate cardTableViewController:self 
                                        didScrollToRow:self.currentRowIndex
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
                [self.delegate cardTableViewController:self 
                                        didScrollToRow:self.currentRowIndex
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
    
    //
    if (self.dataSource == CardTableViewDataSourceSearchStatues) {
        [[UIApplication sharedApplication] showLoadingView];
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
						[self scrollToRow:0];
						
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
                [self.delegate cardTableViewController:self 
                                        didScrollToRow:self.currentRowIndex
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
        
        [client getTrendsStatuses:self.searchString];
    }
	
	//
	if (self.dataSource == CardTableViewDataSourceMentions) {
		[client setCompletionBlock:^(WeiboClient *client) {
            if (!client.hasError) {
				
                NSArray *dictArray = client.responseJSONObject;
				
				for (NSDictionary *dict in dictArray) {
                    Status * status = [Status insertMentionedStatus:dict inManagedObjectContext:self.managedObjectContext];
					NSLog(@"%@", status.text);
                }
				
				[self.managedObjectContext processPendingChanges];
				
				if (_refreshFlag) {
					_refreshFlag = NO;
					
					Status *newStatus = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
					
					if (_lastMentionStatusID == nil || ![newStatus.statusID isEqualToString:_lastMentionStatusID]){
						[_lastMentionStatusID release];
						_lastMentionStatusID = [[NSString stringWithString:newStatus.statusID] copy];
						
						[self adjustCardViewAfterLoadingWithCompletion:^(){
							[self clearData];
							for (NSDictionary *dict in dictArray) {
								[Status insertMentionedStatus:dict inManagedObjectContext:self.managedObjectContext];
							}
							[self.managedObjectContext processPendingChanges];
						}];
						
					} else if ([newStatus.statusID isEqualToString:_lastMentionStatusID]) {
						[self adjustCardViewAfterLoadingWithCompletion:nil];
						[[UIApplication sharedApplication] hideLoadingView];
						_loading = NO;
						[self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
						[self.delegate cardTableViewController:self 
												didScrollToRow:self.currentRowIndex
											  withNumberOfRows:[self numberOfRows]];
						if (completion) {
							completion();
						}
						return;
					}
				}
                [self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];
                [self.delegate cardTableViewController:self 
                                        didScrollToRow:self.currentRowIndex
                                      withNumberOfRows:[self numberOfRows]];
				if (completion) {
					completion();
				}
            } else {
				[ErrorNotification showLoadingError];
			}
			[[UIApplication sharedApplication] hideLoadingView];
			_loading = NO;
        }];
		
		[client getMentionsSinceID:nil 
							 maxID:[NSString stringWithFormat:@""] 
							  page:0 
							 count:20];

	}
}

- (void)clearData
{
    switch (self.dataSource) {
        case CardTableViewDataSourceUserTimeline:
            [self.user removeStatuses:self.user.statuses];
            break;
        case CardTableViewDataSourceFriendsTimeline:
            [self.currentUser removeFriendsStatuses:self.currentUser.friendsStatuses];
            break;
        case CardTableViewDataSourceFavorites:
            [self.currentUser removeFavorites:self.currentUser.favorites];
            break;
		case CardTableViewDataSourceMentions:
			break;
		default:
			break;
    }
    [self.managedObjectContext processPendingChanges];
}

- (void)refresh
{
	_refreshFlag = YES;
    [self loadMoreDataCompletion:NULL];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{    
    if (YES)
    {   
		CardTableViewCell *tableViewCell = (CardTableViewCell *)cell;
        tableViewCell.smartCardViewController.currentUser = self.currentUser;
        tableViewCell.smartCardViewController.status = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
    else 
    {   
		CardTableViewCell *tableViewCell = (CardTableViewCell *)cell;
        tableViewCell.statusCardViewController.currentUser = self.currentUser;
        tableViewCell.statusCardViewController.status = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
}

- (void)configureRequest:(NSFetchRequest *)request
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"statusID"
                                                                     ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    switch (self.dataSource) {
        case CardTableViewDataSourceFriendsTimeline:
			request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat:@"isFriendsStatusOf == %@", self.currentUser];
            break;
        case CardTableViewDataSourceUserTimeline:
			request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat:@"author == %@", self.user];
            break;
        case CardTableViewDataSourceFavorites:
			request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat:@"favoritedBy == %@", self.currentUser];
			break;
		case CardTableViewDataSourceMentions:
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationRight];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
//	[self.tableView reloadData];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	dragStartOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if(_checkingDirection) {
		_checkingDirection = NO;
		CGFloat checkResult = scrollView.contentOffset.y - preDiff;
		preDiff = 0;
		
		if((checkResult * _direction) < 0) {
			return;
		}
		
		if (checkResult > 0 && self.currentRowIndex < [self numberOfRows] - 1) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentRowIndex + 1 inSection:0];
			[self scrollToRowAtIndexPath:indexPath];
		} 
		else if(checkResult > 0 && self.currentRowIndex == [self numberOfRows] - 1) {
			[self performSelector:@selector(loadMoreDataCompletion:) withObject:nil afterDelay:0.5];
		}
		else if(checkResult < 0 && self.currentRowIndex != 0){
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentRowIndex - 1 inSection:0];
			[self scrollToRowAtIndexPath:indexPath];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	_checkingDirection = YES;
	if(scrollView.contentOffset.y > dragStartOffset) {
		_direction = 1;
	}
	else if(scrollView.contentOffset.y < dragStartOffset) {
		_direction = -1;
	}
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	if (_checkingDirection) {
		preDiff = scrollView.contentOffset.y;
	}
}

-(void)enableDismissRegion
{
	self.regionLeftDetectButton.alpha = 1.0;
	self.regionRightDetectButton.alpha = 1.0;
}

-(void)disableDismissRegion
{
	self.regionLeftDetectButton.alpha = 0.0;
	self.regionRightDetectButton.alpha = 0.0;
}

-(IBAction)dismissRegionTouched:(id)sender
{
	if ([UserCardNaviViewController sharedUserCardNaviViewControllerExisted]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldDismissUserCard object:self];
	} 
	[self disableDismissRegion];
}

@end
