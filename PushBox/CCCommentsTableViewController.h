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

#define kNotificationNameShouldShowMentions @"kNotificationNameShouldShowMentions"

@class CommentsTableViewController;
@class Status;

@interface CCCommentsTableViewController : EGOTableViewController<CommentsTableViewCellDelegats, CommentseViewDelegates> {
    UILabel *_titleLabel;
    int _nextPage;
	Status *_status;
    CommentsTableViewDataSource _dataSource;
    id _delegate;
	
	UILabel *_theNewCommentCountLabel;
	UILabel *_theNewMentionsCountLabel;
}

@property(nonatomic, retain) Status *status;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, assign) CommentsTableViewDataSource dataSource;
@property(nonatomic, assign) id<CommentsTableViewControllerDelegate> delegate;

@property(nonatomic, retain) IBOutlet UILabel *theNewCommentCountLabel;
@property(nonatomic, retain) IBOutlet UILabel *theNewMentionsCountLabel;

- (IBAction)mentionButtonClicked:(id)sender;

@end
