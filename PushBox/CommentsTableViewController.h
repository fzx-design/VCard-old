//
//  CommentsTableViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-31.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "EGOTableViewController.h"
#import "CommentsTableViewCell.h"
#import "CommentViewController.h"
#import "UserCardNaviViewController.h"

typedef enum {
    CommentsTableViewDataSourceCommentsToMe,
    CommentsTableViewDataSourceCommentsOfStatus,
} CommentsTableViewDataSource;

typedef enum {
	CommentsTableViewCommandCenterModel,
	CommentsTableViewNormalModel,
} CommentsTableViewModel;

@class CommentsTableViewController;
@protocol CommentsTableViewControllerDelegate
- (void)commentsTableViewControllerDidDismiss:(CommentsTableViewController *)vc;
@end

@class Status;

@interface CommentsTableViewController : EGOTableViewController<CommentsTableViewCellDelegats, CommentseViewDelegates> {
    UILabel *_titleLabel;
    Status *_status;
    int _nextPage;
    CommentsTableViewDataSource _dataSource;
    id _delegate;
    
	UIImageView *_authorImageView;
	UILabel *_authorNameLabel;
	UILabel *_authorPreviewLabel;
	
	CommentsTableViewModel _commentsTableViewModel;
}

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) Status *status;
@property(nonatomic, assign) CommentsTableViewDataSource dataSource;
@property(nonatomic, assign) id<CommentsTableViewControllerDelegate> delegate;
@property(nonatomic, retain) IBOutlet UIImageView* newCommentsImageView;

@property(nonatomic, retain) IBOutlet UIImageView *authorImageView;
@property(nonatomic, retain) IBOutlet UILabel *authorNameLabel;
@property(nonatomic, retain) IBOutlet UILabel *authorPreviewLabel;

@property(nonatomic) CommentsTableViewModel commentsTableViewModel;

- (IBAction)commentButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;

@end
