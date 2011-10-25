//
//  CCCommentsTableViewController.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-23.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "CCCommentsTableViewController.h"
#import "UserCardBaseViewController.h"		//To get define
#import "WeiboClient.h"
#import "Comment.h"
#import "User.h"
#import "Status.h"
#import "NSDateAddition.h"
#import "UIApplicationAddition.h"
#import "UIImageViewAddition.h"

@implementation CCCommentsTableViewController
@synthesize titleLabel = _titleLabel;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize status = _status;
@synthesize theNewCommentCountLabel = _theNewCommentCountLabel;
@synthesize theNewMentionsCountLabel = _theNewMentionsCountLabel;

- (void)dealloc
{
    NSLog(@"CommentsTableViewController dealloc");
    [_titleLabel release];
	[_theNewCommentCountLabel release];
    [_theNewMentionsCountLabel release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_titleLabel release];
    self.theNewCommentCountLabel = nil;
    self.theNewMentionsCountLabel = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = NSLocalizedString(@"评论", nil);
    
    _nextPage = 1;
    [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(hideLoadMoreDataButton) withObject:nil afterDelay:0.1];
}

- (void)clearData
{
    _nextPage = 1;
    [self hideLoadMoreDataButton];
    if (self.dataSource == CommentsTableViewDataSourceCommentsOfStatus) {
        [self.status removeComments:self.status.comments];
    }
    else {
        [self.currentUser removeCommentsToMe:self.currentUser.commentsToMe];
    }
}

- (void)refresh
{
	[self clearData];
    [self loadMoreData];
    WeiboClient *client = [WeiboClient client];
    [client resetUnreadCount:ResetUnreadCountTypeComments];
}

- (void)loadMoreData
{
    if (_loading) {
        return;
    }
    
    _loading = YES;
    
    WeiboClient *client = [WeiboClient client];
	[[UIApplication sharedApplication] showLoadingView];
    [client setCompletionBlock:^(WeiboClient *client) {
		
		[[UIApplication sharedApplication] hideLoadingView];
        if (!client.hasError) {

            NSArray *dictArray = client.responseJSONObject;
            for (NSDictionary *dict in dictArray) {
                [Comment insertComment:dict inManagedObjectContext:self.managedObjectContext];
            }
			
			int count = [dictArray count];
            if (count < 20) {
                [self hideLoadMoreDataButton];
            }
            else {
                [self showLoadMoreDataButton];
            }
			
			[self.managedObjectContext processPendingChanges];
			
            _nextPage++;
			
        } else {
			[ErrorNotification showPostError];
		}
		[self doneLoadingTableViewData];
		_loading = NO;
    }];
    
    if (self.dataSource == CommentsTableViewDataSourceCommentsOfStatus) {
        [client getCommentsOfStatus:self.status.statusID page:_nextPage count:20];
    }
    else {
        [client getCommentsToMeSinceID:nil maxID:nil page:_nextPage count:20];
    }
}

- (void)configureRequest:(NSFetchRequest *)request
{
    request.entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
	request.predicate = [NSPredicate predicateWithFormat:@"targetUser == %@ && author != %@", self.currentUser, self.currentUser];
}

- (void)commentsTableViewCellCommentButtonClicked:(CommentsTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    CommentViewController *vc = [[CommentViewController alloc] init];
    vc.targetComment = comment;
    vc.targetStatus = self.status;
    [[UIApplication sharedApplication] presentModalViewController:vc atHeight:kModalViewHeight];
    [vc release];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CommentsTableViewCell *commentCell = (CommentsTableViewCell *)cell;
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    commentCell.screenNameLabel.text = comment.author.screenName;
    commentCell.dateLabel.text = [comment.createdAt stringRepresentation];
    commentCell.delegate = self;
    
    UITextView *textView = commentCell.textView;
    textView.text = comment.text;
    
	CGRect frame = textView.frame;
	frame.size = textView.contentSize;
	textView.frame = frame;
	
	CGFloat height = textView.frame.origin.y + textView.contentSize.height + 10;
	height = height > 65 ? height : 65;
	commentCell.frame = CGRectMake(0, 0, 448, height);
	
	commentCell.separatorLine.frame = CGRectMake(0, height-10, 
                                                 commentCell.separatorLine.frame.size.width, 
                                                 commentCell.separatorLine.frame.size.height);
}

- (NSString *)customCellClassName
{
    return @"CCCommentsTableViewCell";
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
//	
//	UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(11, 26, 383, 39)];
//	[self.view addSubview:textView];
//	//	textView.font = [textView.font fontWithSize:14];
//	textView.text = comment.text;
//    
//	CGFloat height = textView.frame.origin.y + textView.contentSize.height;
//	[textView removeFromSuperview];
//	[textView release];
//	
//	return height;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CommentsTableViewController *vc = [[CommentsTableViewController alloc] init];
    vc.dataSource = CommentsTableViewDataSourceCommentsOfStatus;
    vc.currentUser = comment.targetUser;
    vc.status = comment.targetStatus;
	vc.commentsTableViewModel = CommentsTableViewCommandCenterModel;
	
	[self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (IBAction)mentionButtonClicked:(id)sender
{
	self.theNewMentionsCountLabel.hidden = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowMentions object:self];
}

- (IBAction)commentButtonClicked:(id)sender
{
	self.theNewCommentCountLabel.hidden = YES;
	[self refresh];
}

@end

