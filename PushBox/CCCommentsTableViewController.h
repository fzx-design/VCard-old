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

@interface CCCommentsTableViewController : EGOTableViewController<CommentsTableViewCellDelegats, CommentseViewDelegates, SwitchValueChanged> {
    int _nextPage;
    id _delegate;
    CommentsTableViewDataSource _dataSource;
	
	NSFetchedResultsController *_commentsToMeFetchedResultsController;
	
	RCSwitchClone *_switchView;
	
    UILabel *_titleLabel;
	UILabel *_theNewCommentCountLabel;
	UILabel *_theNewMentionsCountLabel;
}

@property(nonatomic, retain) Status *status;
@property(nonatomic, assign) CommentsTableViewDataSource dataSource;
@property(nonatomic, assign) id<CommentsTableViewControllerDelegate> delegate;

@property(nonatomic, retain) IBOutlet RCSwitchClone *switchView;

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *theNewCommentCountLabel;
@property(nonatomic, retain) IBOutlet UILabel *theNewMentionsCountLabel;

- (IBAction)mentionButtonClicked:(id)sender;

@end
