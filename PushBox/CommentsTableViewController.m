//
//  CommentsTableViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-31.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CommentsTableViewController.h"
#import "WeiboClient.h"
#import "Comment.h"
#import "User.h"
#import "Status.h"
#import "NSDateAddition.h"
#import "UIApplicationAddition.h"
#import "UIImageViewAddition.h"
#import "CommentReviewPopoverController.h"

@implementation CommentsTableViewController
@synthesize status = _status;
@synthesize titleLabel = _titleLabel;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize authorImageView = _authorImageView;
@synthesize authorNameLabel = _authorNameLabel;
@synthesize authorPreviewLabel = _authorPreviewLabel;

@synthesize commentsTableViewModel = _commentsTableViewModel;

- (void)dealloc
{
    NSLog(@"CommentsTableViewController dealloc");
    [_titleLabel release];
    [_status release];
	[_authorImageView release];
    [_authorNameLabel release];
    [_authorPreviewLabel release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.titleLabel= nil;
	self.authorImageView = nil;
    self.authorNameLabel = nil;
    self.authorPreviewLabel = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = NSLocalizedString(@"评论", nil);
    
    _nextPage = 1;
    [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(hideLoadMoreDataButton) withObject:nil afterDelay:0.1];
    
	[self.authorImageView loadImageFromURL:self.status.author.profileImageURL 
                                completion:NULL
                            cacheInContext:self.managedObjectContext];
	self.authorNameLabel.text = self.status.author.screenName;
	self.authorPreviewLabel.text = self.status.text;
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
    //	[self clearData];
	_nextPage = 1;
    //    [self loadMoreData];
	
	[self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.05];
	
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
            
            if (_nextPage == 1) {
				[self clearData];
			}
            
            int count = [dictArray count];
            if (count < 20) {
                [self hideLoadMoreDataButton];
            }
            else {
                [self showLoadMoreDataButton];
            }			
            for (NSDictionary *dict in dictArray) {
                [Comment insertComment:dict inManagedObjectContext:self.managedObjectContext];
            }
            //			[self.managedObjectContext processPendingChanges];
            _nextPage++;
            
        } else {
			[ErrorNotification showLoadingError];
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
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    if (self.dataSource == CommentsTableViewDataSourceCommentsOfStatus) {
        request.predicate = [NSPredicate predicateWithFormat:@"targetStatus == %@", self.status];
    }
    else {
        request.predicate = [NSPredicate predicateWithFormat:@"targetUser == %@", self.currentUser];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CommentsTableViewCell *commentCell = (CommentsTableViewCell *)cell;
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    commentCell.screenNameLabel.text = comment.author.screenName;
    commentCell.dateLabel.text = [comment.createdAt customString];
    commentCell.delegate = self;
    
    UITextView *textView = commentCell.textView;
    
    textView.text = comment.text;
    
	CGRect frame = textView.frame;
	frame.size = textView.contentSize;
	textView.frame = frame;
	
	CGFloat height = textView.frame.origin.y + textView.contentSize.height + 10;
	height = height > 65 ? height : 65;
	commentCell.frame = CGRectMake(0, 0, 448, height);
	
	commentCell.separatorLine.frame = CGRectMake(0, height - 2, 
                                                 commentCell.separatorLine.frame.size.width, 
                                                 commentCell.separatorLine.frame.size.height);
}

- (void)commentsTableViewCellCommentButtonClicked:(CommentsTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    CommentViewController *vc = [[CommentViewController alloc] init];
    vc.targetComment = comment;
	vc.delegate = self;
    vc.targetStatus = self.status;
    [[UIApplication sharedApplication] presentModalViewController:vc atHeight:kModalViewHeight];
    [vc release];
}

- (IBAction)commentButtonClicked:(id)sender {
    CommentViewController *vc = [[CommentViewController alloc] init];
	vc.delegate = self;
    vc.targetStatus = self.status;
	
    [[UIApplication sharedApplication] presentModalViewController:vc atHeight:kModalViewHeight];
    [vc release];
}

- (IBAction)backButtonClicked:(id)sender {
	if (self.commentsTableViewModel == CommentsTableViewNormalModel) {
		[UserCardNaviViewController sharedUserCardDismiss];
		[self.delegate commentsTableViewControllerDidDismiss:self];
	} else if (self.commentsTableViewModel == CommentsTableViewCommandCenterModel){
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (IBAction)commentReviewButtonClicked:(id)sender
{
    
	CommentReviewPopoverController *vc = [CommentReviewPopoverController sharedCommentReviewPopoverControllerWithTableType:_commentsTableViewModel];
	vc.status = self.status;
	vc.profileImageView = self.authorImageView;
	UIView *mainView = [[UIApplication sharedApplication] rootView];
	[mainView addSubview:vc.view];
}

- (NSString *)customCellClassName
{
    return @"CommentsTableViewCell";
}

- (void)commentFinished
{
	[self refresh];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(11, 26, 383, 39)];
	[self.view addSubview:textView];
    //	textView.font = [textView.font fontWithSize:14];
	textView.text = comment.text;
    
	CGFloat height = textView.frame.origin.y + textView.contentSize.height + 16;
	[textView removeFromSuperview];
	[textView release];
	
	return height;
}


@end
