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

@class CommentsTableViewController;
@protocol CommentsTableViewControllerDelegate
- (void)commentsTableViewControllerDidDismiss:(CommentsTableViewController *)vc;
@end

@class Status;

@interface CommentsTableViewController : EGOTableViewController<CommentsTableViewCellDelegats> {
    UILabel *_titleLabel;
    Status *_status;
    int _nextPage;
    
    id _delegate;
}

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) Status *status;
@property(nonatomic, assign) id<CommentsTableViewControllerDelegate> delegate;

- (IBAction)commentButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;

@end
