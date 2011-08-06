//
//  CardTableViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-26.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CardTableViewController.h"
#import "WeiboClient.h"
#import "Status.h"
#import "User.h"
#import "UIApplicationAddition.h"

#define kCardWidth 570
#define kCardHeight 640
#define kHeaderAndFooterWidth 229.0

#define kStatusCountPerRequest 10

#define kBlurImageViewScale 2.27

@interface CardTableViewController()
@property(nonatomic, retain) UITableViewCell *tempCell;  
@end

@implementation CardTableViewController

@synthesize tempCell = _tempCell;
@synthesize delegate = _delegate;
@synthesize currentRowIndex = _currentRowIndex;
@synthesize swipeEnabled = _swipeEnabled;
@synthesize blurImageView = _blurImageView;
@synthesize dataSource = _dataSource;
@synthesize user = _user;
@synthesize prevFetchedResultsController = _prevFetchedResultsController;
@synthesize prevRowIndex = _prevRowIndex;

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
    
    self.tableView.scrollEnabled = NO;
	
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
	
	UISwipeGestureRecognizer *swipeRigthGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self 
																							action:@selector(swipeRight:)];
	swipeRigthGesture.direction = UISwipeGestureRecognizerDirectionUp;
	swipeRigthGesture.numberOfTouchesRequired = 1;
	[self.tableView addGestureRecognizer:swipeRigthGesture];
	[swipeRigthGesture release];
	
	UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
																						   action:@selector(swipeLeft:)];
	swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionDown;
	swipeLeftGesture.numberOfTouchesRequired = 1;
	[self.tableView addGestureRecognizer:swipeLeftGesture];
	[swipeLeftGesture release];
    
    self.currentRowIndex = 0;
    self.swipeEnabled = YES;
    self.blurImageView.alpha = 0.0;
    _nextPage = 1;
    _loading = NO;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:5
                                     target:self 
                                   selector:@selector(timerFired:) 
                                   userInfo:nil 
                                    repeats:YES];
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
            NSDictionary *dict = client.responseJSONObject;
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            if ([[dict objectForKey:@"comments"] intValue]) {
                [center postNotificationName:kNotificationNameNewCommentsToMe object:self];
            }
            if ([[dict objectForKey:@"followers"] intValue]) {
                [center postNotificationName:kNotificationNameNewFollowers object:self];
            }
            if ([[dict objectForKey:@"new_status"] intValue]) {
                [center postNotificationName:kNotificationNameNewStatuses object:self];
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

- (void)pushCardWithCompletion:(void (^)())completion
{
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
    } completion:^(BOOL fin) {
        [self clearData];
        [self.tableView reloadData];
        [self loadMoreDataCompletion:completion];
        self.tableView.transform = CGAffineTransformScale(self.tableView.transform, kBlurImageViewScale, kBlurImageViewScale);
        self.tableView.alpha = 1.0;
    }];
}

- (void)popCardWithCompletion:(void (^)())completion
{
    self.dataSource = CardTableViewDataSourceFriendsTimeline;
	[UIView animateWithDuration:1 delay:0 options:0 animations:^{
		self.tableView.alpha = 0.0;
	} completion:^(BOOL fin) {
		self.fetchedResultsController = self.prevFetchedResultsController;
        self.fetchedResultsController.delegate = self;
        self.currentRowIndex = self.prevRowIndex;
        self.prevFetchedResultsController = nil;
        self.prevRowIndex = 0;
        
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentRowIndex inSection:0]
                              atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:NO];
        [self performSelector:@selector(configureUsability) withObject:nil afterDelay:0.5];

        self.blurImageView.alpha = 1.0;
        self.blurImageView.transform = CGAffineTransformMakeScale(1, 1);
		self.tableView.transform = CGAffineTransformScale(self.tableView.transform, 1/kBlurImageViewScale, 1/kBlurImageViewScale);
		[UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
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
    NSIndexPath *prev = [NSIndexPath indexPathForRow:self.currentRowIndex-1 inSection:0];
    NSIndexPath *next = [NSIndexPath indexPathForRow:self.currentRowIndex+1 inSection:0];
    
    [[self.tableView cellForRowAtIndexPath:indexPath] setUserInteractionEnabled:YES];
    [[self.tableView cellForRowAtIndexPath:prev] setUserInteractionEnabled:NO];
    [[self.tableView cellForRowAtIndexPath:next] setUserInteractionEnabled:NO];
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.tableView numberOfRowsInSection:0] == indexPath.row+1) {
        [self performSelector:@selector(loadMoreDataCompletion:) withObject:nil afterDelay:1.5];
    }
    
    [self.tableView scrollToRowAtIndexPath:indexPath 
                          atScrollPosition:UITableViewScrollPositionMiddle 
                                  animated:YES];
    
    self.currentRowIndex = indexPath.row;
    
    
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
        }
    };
    
    [client setCompletionBlock:block];
    [client getFavoritesByPage:_nextPage++];
}

- (void)loadMoreDataCompletion:(void (^)())completion
{
    if (_loading) {
        return;
    }
    
    _loading = YES;
    
    if (self.dataSource == CardTableViewDataSourceFavorites) {
        [[UIApplication sharedApplication] showLoadingView];
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
    if (lastStatus) {
        NSString *statusID = lastStatus.statusID;
        maxID = [statusID longLongValue] - 1;
    }
    
    if (self.dataSource == CardTableViewDataSourceFriendsTimeline) {
        [[UIApplication sharedApplication] showLoadingView];
        [client setCompletionBlock:^(WeiboClient *client) {
            if (!client.hasError) {
                NSArray *dictArray = client.responseJSONObject;
                for (NSDictionary *dict in dictArray) {
                    Status *newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
                    [self.currentUser addFriendsStatusesObject:newStatus];
                }
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
            }
        }];
        
        [client getFriendsTimelineSinceID:nil
                            maxID:[NSString stringWithFormat:@"%lld", maxID]
                           startingAtPage:0 
                                    count:kStatusCountPerRequest
                                  feature:0];
    }
    
    if (self.dataSource == CardTableViewDataSourceUserTimeline) {
        [[UIApplication sharedApplication] showLoadingView];
        [client setCompletionBlock:^(WeiboClient *client) {
            if (!client.hasError) {
                NSArray *dictArray = client.responseJSONObject;
                for (NSDictionary *dict in dictArray) {
                    [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
                }
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
            }
        }];
        
        [client getUserTimeline:self.user.userID
                        SinceID:nil
                  maxID:[NSString stringWithFormat:@"%lld", maxID]
                 startingAtPage:0
                          count:kStatusCountPerRequest
                        feature:0];
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
    }
    [self.managedObjectContext processPendingChanges];
    self.currentRowIndex = 0;
}

- (void)refresh
{
    [self clearData];
    [self loadMoreDataCompletion:NULL];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"card table view configure cell");
    
    CardTableViewCell *tableViewCell = (CardTableViewCell *)cell;
    tableViewCell.statusCardViewController.currentUser = self.currentUser;
    tableViewCell.statusCardViewController.status = [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)configureRequest:(NSFetchRequest *)request
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"statusID"
                                                                     ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
    
    switch (self.dataSource) {
        case CardTableViewDataSourceFriendsTimeline:
            request.predicate = [NSPredicate predicateWithFormat:@"isFriendsStatusOf == %@", self.currentUser];
            break;
        case CardTableViewDataSourceUserTimeline:
            request.predicate = [NSPredicate predicateWithFormat:@"author == %@", self.user];
            break;
        case CardTableViewDataSourceFavorites:
            request.predicate = [NSPredicate predicateWithFormat:@"favoritedBy == %@", self.currentUser];
    }
}

- (NSString *)customCellClassName
{
    return @"CardTableViewCell";
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    //[self.tableView beginUpdates];
    //NSLog(@"%d", [self.fetchedResultsController.fetchedObjects count]);
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
//    
//    UITableView *tableView = self.tableView;
//    
//    switch(type) {
//            
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
//                             withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                             withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
//                    atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                             withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
//                             withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //[self.tableView endUpdates];
    [self.tableView reloadData];
}


@end
