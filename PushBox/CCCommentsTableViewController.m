//
//  CCCommentsTableViewController.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-23.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "CCCommentsTableViewController.h"
#import "UserCardBaseViewController.h"		//To get define
#import "CCUserInfoCardViewController.h"	//To get define
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
@synthesize switchView = _switchView;

- (void)dealloc
{
    NSLog(@"CommentsTableViewController dealloc");
    [_titleLabel release];
	[_theNewCommentCountLabel release];
    [_theNewMentionsCountLabel release];
	[_switchView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.titleLabel = nil;
	self.switchView = nil;
    self.theNewCommentCountLabel = nil;
    self.theNewMentionsCountLabel = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = NSLocalizedString(@"评论", nil);
    
    _nextPage = 1;
	
	self.switchView.delegate = self;
	[self.switchView setType:SwitchTypeComment];
	
    [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(hideLoadMoreDataButton) withObject:nil afterDelay:0.1];
}

- (void)clearData
{
    _nextPage = 1;
    [self hideLoadMoreDataButton];
    if (self.dataSource == CommentsTableViewDataSourceCommentsByMe) {
//        [self.status removeComments:self.status.comments];
    }
    else {
        [self.currentUser removeCommentsToMe:self.currentUser.commentsToMe];
    }
}

- (void)refresh
{
	_nextPage = 1;
	
	if (_dataSource == CommentsTableViewDataSourceCommentsToMe) {
		NSDictionary *userData = [NSDictionary dictionaryWithObject:kNotificationObjectNameComment forKey:@"type"];
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameNotificationRefreshed object:self userInfo:userData];
	}

	[self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.05];
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
			
			if (_dataSource == CommentsTableViewDataSourceCommentsToMe) {
				for (NSDictionary *dict in dictArray) {
					[Comment insertCommentToMe:dict inManagedObjectContext:self.managedObjectContext];
				}
				[self.managedObjectContext processPendingChanges];
			} else if(_dataSource == CommentsTableViewDataSourceCommentsByMe) {
				for (NSDictionary *dict in dictArray) {
					[Comment insertCommentByMe:dict inManagedObjectContext:self.managedObjectContext];
				}
				[self.managedObjectContext processPendingChanges];
			}
			
			_nextPage++;
			
		} else {
			[ErrorNotification showLoadingError];
		}
		self.switchView.userInteractionEnabled = YES;
		[self doneLoadingTableViewData];
		_loading = NO;

    }];
    
    if (self.dataSource == CommentsTableViewDataSourceCommentsByMe) {
		[client getCommentsByMeSinceID:nil maxID:nil page:_nextPage count:20];
    }
    else if(self.dataSource == CommentsTableViewDataSourceCommentsToMe){
        [client getCommentsToMeSinceID:nil maxID:nil page:_nextPage count:20];
    }
}



- (void)configureRequest:(NSFetchRequest *)request
{
    request.entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    if (self.dataSource == CommentsTableViewDataSourceCommentsToMe) {
		request.predicate = [NSPredicate predicateWithFormat:@"toMe == %@", [NSNumber numberWithBool:YES]];
	} else if(self.dataSource == CommentsTableViewDataSourceCommentsByMe) {
		request.predicate = [NSPredicate predicateWithFormat:@"byMe == %@", [NSNumber numberWithBool:YES]];
	}
}

- (void)commentsTableViewCellCommentButtonClicked:(CommentsTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    CommentViewController *vc = [[CommentViewController alloc] init];
    vc.targetComment = comment;
    vc.targetStatus = comment.targetStatus;
	vc.delegate = self;
		
    [[UIApplication sharedApplication] presentModalViewController:vc atHeight:kModalViewHeight];
    [vc release];
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
	
	commentCell.separatorLine.frame = CGRectMake(0, height - 6, 
                                                 commentCell.separatorLine.frame.size.width, 
                                                 commentCell.separatorLine.frame.size.height);
	
	UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_highlight.png"]] autorelease];
	imageView.contentMode = UIViewContentModeBottom;
	[commentCell setSelectedBackgroundView:imageView];
}

- (NSString *)customCellClassName
{
    return @"CCCommentsTableViewCell";
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CommentsTableViewController *vc = [[CommentsTableViewController alloc] init];
    vc.dataSource = CommentsTableViewDataSourceCommentsOfStatus;
    vc.currentUser = comment.targetUser;
    vc.status = comment.targetStatus;
	vc.commentsTableViewModel = CommentsTableViewCommandCenterModel;
	
	[self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)switchToToMe
{
	[[UIApplication sharedApplication] showLoadingView];
	self.dataSource = CommentsTableViewDataSourceCommentsToMe;
	self.switchView.userInteractionEnabled = NO;
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
	[self refresh];
	
	[self.tableView reloadData];
}

- (void)switchToByMe
{
	[[UIApplication sharedApplication] showLoadingView];
	self.dataSource = CommentsTableViewDataSourceCommentsByMe;
	self.switchView.userInteractionEnabled = NO;
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
	[self refresh];
	
	[self.tableView reloadData];
}

- (void)switchedOn
{
	[self performSelector:@selector(switchToByMe) withObject:nil afterDelay:0.25];
}

- (void)switchedOff
{
	
	[self performSelector:@selector(switchToToMe) withObject:nil afterDelay:0.25];
}

- (IBAction)mentionButtonClicked:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowMentions object:self];
	
	NSDictionary *userData = [NSDictionary dictionaryWithObject:kNotificationObjectNameMention forKey:@"type"];
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameNotificationRefreshed object:self userInfo:userData];
}

- (IBAction)commentButtonClicked:(id)sender
{
	[self refresh];
}

@end

