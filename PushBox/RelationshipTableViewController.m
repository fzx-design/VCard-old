//
//  RelationshipTableViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-30.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "RelationshipTableViewController.h"
#import "RelationshipTableViewCell.h"
#import "UIImageViewAddition.h"
#import "User.h"
#import "WeiboClient.h"
#import "UserCardViewController.h"

@implementation RelationshipTableViewController

@synthesize titleLabel = _titleLabel;
@synthesize backButton = _backButton;
@synthesize user = _user;

- (void)dealloc
{
    NSLog(@"RelationshipTableViewController dealloc");
    [_titleLabel release];
    [_backButton release];
    [_user release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.titleLabel = nil;
    self.backButton = nil;
}

- (id)initWithType:(RelationshipViewType)type
{
    self = [super init];
    _type = type;
    return self;
}

- (IBAction)backButtonClicked:(id)sender {
//	[self.parentViewController dismissModalViewControllerAnimated:YES];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_type == RelationshipViewTypeFriends) {
        self.titleLabel.text = NSLocalizedString(@"关注", nil);
    }
    else {
        self.titleLabel.text = NSLocalizedString(@"粉丝", nil);
    }
    _nextCursor = -1;
    
    [self refresh];
}

- (void)clearData
{
    if (_type == RelationshipViewTypeFriends) {
        [self.user removeFriends:self.user.friends];
    }
    else {
        [self.user removeFollowers:self.user.followers];
    }
    //[self.tableView reloadData];
}

- (void)refresh
{
    [self hideLoadMoreDataButton];
//    [self clearData];
	_nextCursor = -1;
	[self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.01];
//    [self loadMoreData];
}

- (void)loadMoreData
{
    if (_loading == YES) {
        return;
    }
    _loading = YES;
    
    WeiboClient *client = [WeiboClient client];
	[[UIApplication sharedApplication] showLoadingView];
    [client setCompletionBlock:^(WeiboClient *client) {
		[[UIApplication sharedApplication] hideLoadingView];
        if (!client.hasError) {
            NSArray *dictArray = [client.responseJSONObject objectForKey:@"users"];
			
			if (_nextCursor == -1) {
				[self clearData];
			}
			
            for (NSDictionary *dict in dictArray) {
                User *usr = [User insertUser:dict inManagedObjectContext:self.managedObjectContext];
                if (_type == RelationshipViewTypeFollowers) {
                    [self.user addFollowersObject:usr];
                }
                else {
                    [self.user addFriendsObject:usr];
                }
            }
            
            _nextCursor = [[client.responseJSONObject objectForKey:@"next_cursor"] intValue];
            
            if (_nextCursor == 0) {
                [self hideLoadMoreDataButton];
            }
            else {
                [self showLoadMoreDataButton];
            }
            
            [self doneLoadingTableViewData];
            _loading = NO;
        } else {
			[ErrorNotification showLoadingError];
		}
    }];
    
    if (_type == RelationshipViewTypeFriends) {
        [client getFriendsOfUser:self.user.userID cursor:_nextCursor count:20];
    }
    else {
        [client getFollowersOfUser:self.user.userID cursor:_nextCursor count:20];
    }
}

- (void)configureRequest:(NSFetchRequest *)request
{
    request.entity = [NSEntityDescription entityForName:@"User"
                                 inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:YES];
    if (_type == RelationshipViewTypeFriends) {
        request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", self.user.friends];
    }
    else {
        request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", self.user.followers];
    }
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    RelationshipTableViewCell *relationshipCell = (RelationshipTableViewCell *)cell;
    User *usr = [self.fetchedResultsController objectAtIndexPath:indexPath];
    relationshipCell.screenNameLabel.text = usr.screenName;
    relationshipCell.descriptionLabel.text = usr.selfDescription;
    [relationshipCell.profileImageView loadImageFromURL:usr.profileImageURL 
                                             completion:NULL 
                                         cacheInContext:self.managedObjectContext];
	UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_highlight.png"]] autorelease];
	imageView.contentMode = UIViewContentModeBottom;
	[relationshipCell setSelectedBackgroundView:imageView];
}

- (NSString *)customCellClassName
{
    return @"RelationshipTableViewCell";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    User *usr = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UserCardViewController *vc = [[UserCardViewController alloc] initWithUsr:usr];
    vc.currentUser = self.currentUser;
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    vc.modalTransitionStyle = self.modalTransitionStyle;
	[self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

@end
