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

#define kCardWidth 570
#define kCardHeight 640
#define kHeaderAndFooterWidth 229.0

@interface CardTableViewController()
@property(nonatomic, retain) User* currentUser;
@property(nonatomic, retain) UITableViewCell *tempCell;  
@end

@implementation CardTableViewController

@synthesize currentUser = _currentUser;
@synthesize tempCell = _tempCell;

- (void)dealloc
{
    NSLog(@"CardTableViewController dealloc");
    [_currentUser release];
    [_tempCell release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [WeiboClient currentUserInManagedObjectContext:self.managedObjectContext];
    
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
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
{
//	if (_canScroll) {
//		int row = indexPath.row;
//		if (![self isRowValid:row]) {
//			return;
//		}
//		self.visibleRow = row;
    NSLog(@"scroll to row %d", indexPath.row);
    [self.tableView scrollToRowAtIndexPath:indexPath 
                          atScrollPosition:UITableViewScrollPositionMiddle 
                                  animated:YES];
    
    if ([self.tableView numberOfRowsInSection:0] == indexPath.row+1) {
        [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:1.5];
    }
    //		_shouldAnimateScrolling = YES;
    
    //[_delegate cardTableViewController:self didScrollToRow:row];
    
//    [self performSelector:@selector(configureCellUsability:) withObject:indexPath afterDelay:1];
    //	}
}

- (void)swipeRight:(UISwipeGestureRecognizer *)ges
{
	NSArray *indexArray = [self.tableView indexPathsForVisibleRows];
	NSIndexPath *nextIndex = [indexArray lastObject];
    
    //still have status
//    if (nextIndex.row+1 < [self.tableView numberOfRowsInSection:0]) {
//        NSIndexPath *nextNextIndex = [NSIndexPath indexPathForRow:nextIndex.row+1 inSection:0];
//        self.tempCell = [super tableView:self.tableView cellForRowAtIndexPath:nextNextIndex];
//    }
//    
    [self scrollToRowAtIndexPath:nextIndex];
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)ges
{
	NSArray *indexArray = [self.tableView indexPathsForVisibleRows];
	NSIndexPath *nextIndex = [indexArray objectAtIndex:0];
    
//    if (nextIndex.row > 0) {
//        NSIndexPath *nextNextIndex = [NSIndexPath indexPathForRow:nextIndex.row-1 inSection:0];
//        self.tempCell = [self tableView:self.tableView cellForRowAtIndexPath:nextNextIndex];
//    }
    
    [self scrollToRowAtIndexPath:nextIndex];
}

- (void)loadMoreData
{
    WeiboClient *client = [WeiboClient client];
    
    long long maxID = 0;
    Status *lastStatus = [self.fetchedResultsController.fetchedObjects lastObject];
    if (lastStatus) {
        NSString *statusID = lastStatus.statusID;
        maxID = [statusID longLongValue] - 1;
    }
    
    [client setCompletionBlock:^(WeiboClient *client) {
        if (!client.hasError) {
            NSArray *dictArray = client.responseJSONObject;
            for (NSDictionary *dict in dictArray) {
                Status *newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
                [self.currentUser addFriendsStatusesObject:newStatus];
                NSLog(@"%@", newStatus.text);
                //[self.managedObjectContext processPendingChanges];
            }
        }
    }];
    
    [client getFriendsTimelineSinceID:nil
                        withMaximumID:[NSString stringWithFormat:@"%lld", maxID]
                       startingAtPage:0 
                                count:5 
                              feature:0];
}

- (void)clearData
{
    [self.currentUser removeFriendsStatuses:self.currentUser.friendsStatuses];
    [self.managedObjectContext processPendingChanges];
}

- (void)refresh
{
    [self clearData];
    [self loadMoreData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"card table view configure cell");
    
    CardTableViewCell *tableViewCell = (CardTableViewCell *)cell;
    tableViewCell.statusCardViewController.managedObjectContext = self.managedObjectContext;
    tableViewCell.statusCardViewController.status = [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)configureRequest:(NSFetchRequest *)request
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"statusID"
                                                                     ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
    request.predicate = [NSPredicate predicateWithFormat:@"isFriendsStatusOf == %@", self.currentUser];
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
