//
//  CCCommentsTableViewController.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-23.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "EGOTableViewController.h"
#import "CommentsTableViewCell.h"
#import "CommentViewController.h"
#import "UserCardNaviViewController.h"
#import "CommentsTableViewController.h"
#import "RCSwitchClone.h"

#define kNotificationNameShouldShowMentions @"kNotificationNameShouldShowMentions"
#define kNotificationObjectNameComment @"kNotificationObjectNameComment"
#define kNotificationObjectNameMention @"kNotificationObjectNameMention"

@class CommentsTableViewController;
@class Status;

@interface CCCommentsTableViewController : EGOTableViewController<CommentsTableViewCellDelegats, SwitchValueChanged> {
    int _nextPage;
	int _nextByMePage;
    id _delegate;
    CommentsTableViewDataSource _dataSource;
	
	NSFetchedResultsController *_commentsToMeFetchedResultsController;
	NSFetchedResultsController *_commentsByMeFetchedResultsController;
	
	RCSwitchClone *_switchView;
	
    UILabel *_titleLabel;
	UILabel *_theNewCommentCountLabel;
	UILabel *_theNewMentionsCountLabel;
	
	UILabel *_fromMeLabel;
	UILabel *_toMeLabel;
}

@property(nonatomic, retain) Status *status;
@property(nonatomic, assign) CommentsTableViewDataSource dataSource;
@property(nonatomic, assign) id<CommentsTableViewControllerDelegate> delegate;

@property(nonatomic, retain) IBOutlet RCSwitchClone *switchView;

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *theNewCommentCountLabel;
@property(nonatomic, retain) IBOutlet UILabel *theNewMentionsCountLabel;

@property(nonatomic, retain) IBOutlet UILabel *fromMeLabel;
@property(nonatomic, retain) IBOutlet UILabel *toMeLabel;

- (IBAction)mentionButtonClicked:(id)sender;
- (void)returnToCommandCenter;

@end
