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

#define LabelNormalColor [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]
#define LabelNormalShadowColor [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]
#define LabelHighlightedColor [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
#define LabelHighlightedShadowColor [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:0.5]

@implementation CCCommentsTableViewController
@synthesize titleLabel = _titleLabel;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize status = _status;
@synthesize theNewCommentCountLabel = _theNewCommentCountLabel;
@synthesize theNewMentionsCountLabel = _theNewMentionsCountLabel;
@synthesize switchView = _switchView;

@synthesize fromMeLabel = _fromMeLabel;
@synthesize toMeLabel = _toMeLabel;

- (void)dealloc
{
    NSLog(@"CommentsTableViewController dealloc");
    [_titleLabel release];
	[_theNewCommentCountLabel release];
    [_theNewMentionsCountLabel release];
	[_switchView release];
	
	[_fromMeLabel release];
	[_toMeLabel release];
	
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.titleLabel = nil;
	self.switchView = nil;
    self.theNewCommentCountLabel = nil;
    self.theNewMentionsCountLabel = nil;
	
	self.fromMeLabel = nil;
	self.toMeLabel = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = NSLocalizedString(@"评论", nil);
    
    _nextPage = 1;
	_nextByMePage = 1;
	
	self.switchView.delegate = self;
	[self.switchView setType:SwitchTypeComment];
	
    [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(hideLoadMoreDataButton) withObject:nil afterDelay:0.1];
}

- (void)clearData
{
    [self hideLoadMoreDataButton];
    if (self.dataSource == CommentsTableViewDataSourceCommentsByMe) {
//        [self.status removeComments:self.status.comments];
		[Comment deleteCommentsByMe:self.managedObjectContext];
    }
    else if(self.dataSource == CommentsTableViewDataSourceCommentsToMe){
		[Comment deleteCommentsToMe:self.managedObjectContext];
//        [self.currentUser removeCommentsToMe:self.currentUser.commentsToMe];
    }
}

- (void)refresh
{
	if (_dataSource == CommentsTableViewDataSourceCommentsToMe) {
		_nextPage = 1;
		NSDictionary *userData = [NSDictionary dictionaryWithObject:kNotificationObjectNameComment forKey:@"type"];
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameNotificationRefreshed object:self userInfo:userData];
	} else if(_dataSource == CommentsTableViewDataSourceCommentsByMe){
		_nextByMePage = 1;
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
			
//			if (_nextPage == 1 && self.dataSource == CommentsTableViewDataSourceCommentsToMe) {
//				[self clearData];
//			}
//			if (_nextByMePage == 1 && self.dataSource == CommentsTableViewDataSourceCommentsByMe) {
//				[self clearData];
//			}
			
			int count = [dictArray count];
			if (count < 20) {
				[self hideLoadMoreDataButton];
			}
			else {
				[self showLoadMoreDataButton];
			}
			
			if (_dataSource == CommentsTableViewDataSourceCommentsToMe) {
				for (NSDictionary *dict in dictArray) {
					Comment * tmp = [Comment insertCommentToMe:dict inManagedObjectContext:self.managedObjectContext];
					NSLog(@"%@___", tmp.text);
				}
				[self.managedObjectContext processPendingChanges];
				
//				if (_commentsToMeFetchedResultsController != nil) {
//					[_commentsToMeFetchedResultsController release];
//				}
				NSFetchRequest *request = [[NSFetchRequest alloc] init];
				
				[request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:self.managedObjectContext]];
				[request setPredicate:[NSPredicate predicateWithFormat:@"toMe == %@", [NSNumber numberWithBool:YES]]];
				
				NSArray *items = [self.managedObjectContext executeFetchRequest:request error:NULL];
				
				[request release];

				NSLog(@"%d", [items count]);
				
				_nextPage++;
				_commentsToMeFetchedResultsController = [self.fetchedResultsController retain];
				
			} else if(_dataSource == CommentsTableViewDataSourceCommentsByMe) {
				for (NSDictionary *dict in dictArray) {
					[Comment insertCommentByMe:dict inManagedObjectContext:self.managedObjectContext];
				}
				[self.managedObjectContext processPendingChanges];
				
				if (_commentsByMeFetchedResultsController != nil) {
					[_commentsByMeFetchedResultsController release];
				}
				_nextByMePage++;
				_commentsByMeFetchedResultsController = [self.fetchedResultsController retain];
			}
			
		} else {
			[ErrorNotification showLoadingError];
		}
		self.switchView.userInteractionEnabled = YES;
		[self doneLoadingTableViewData];
		_loading = NO;

    }];
    
    if (self.dataSource == CommentsTableViewDataSourceCommentsByMe) {
		[client getCommentsByMeSinceID:nil maxID:nil page:_nextByMePage count:20];
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
    if (_dataSource == CommentsTableViewDataSourceCommentsToMe) {
		request.predicate = [NSPredicate predicateWithFormat:@"toMe == %@", [NSNumber numberWithBool:YES]];
	} else if(_dataSource == CommentsTableViewDataSourceCommentsByMe) {
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

- (void)switchToByMe
{
	self.dataSource = CommentsTableViewDataSourceCommentsByMe;
	if (_commentsByMeFetchedResultsController == nil) {
		self.fetchedResultsController.delegate = nil;
		self.fetchedResultsController = nil;
		[self refresh];
		
	} else {
		
		self.fetchedResultsController.delegate = nil;
		self.fetchedResultsController = nil;
		self.fetchedResultsController = _commentsByMeFetchedResultsController;
	}
	
	[self.tableView reloadData];
}

- (void)switchToToMe
{
	self.dataSource = CommentsTableViewDataSourceCommentsToMe;
	if (_commentsToMeFetchedResultsController == nil) {
		self.fetchedResultsController.delegate = nil;
		self.fetchedResultsController = nil;
		[self refresh];
		
	} else {
		self.fetchedResultsController.delegate = nil;
		self.fetchedResultsController = nil;
		self.fetchedResultsController = _commentsToMeFetchedResultsController;
	}
	
	[self.tableView reloadData];
}

- (void)switchedOn
{
	
	self.toMeLabel.textColor = LabelNormalColor;
	self.toMeLabel.shadowColor = LabelNormalShadowColor;
	self.fromMeLabel.textColor = LabelHighlightedColor;
	self.fromMeLabel.shadowColor = LabelHighlightedShadowColor;
	[self performSelector:@selector(switchToByMe) withObject:nil afterDelay:0.25];
}

- (void)switchedOff
{
	self.toMeLabel.textColor = LabelHighlightedColor;
	self.toMeLabel.shadowColor = LabelHighlightedShadowColor;
	self.fromMeLabel.textColor = LabelNormalColor;
	self.fromMeLabel.shadowColor = LabelNormalShadowColor;
	[self performSelector:@selector(switchToToMe) withObject:nil afterDelay:0.25];
}

- (void)returnToCommandCenter
{
	[self.switchView setOn:NO];
	[self switchedOff];
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

