//
//  StatusCardViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-26.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataViewController.h"
#import "UserCardViewController.h"
#import "DetailImageViewController.h"
#import "CommentsTableViewController.h"
#import "CommentViewController.h"
#import "PostViewController.h"
#import <MessageUI/MessageUI.h>

@class Status;

@interface StatusCardViewController : CoreDataViewController<DetailImageViewControllerDelegate, 
UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    UIImageView *_profileImageView;
    UILabel *_screenNameLabel;
    UILabel *_dateLabel;
    UIButton *_actionsButton;
    UILabel *_repostCountLabel;
    UILabel *_commentCountLabel;
    UIButton *_addFavourateButton;
	UIScrollView *_tweetScrollView;
    UIImageView *_tweetImageView;
	UITextView *_tweetTextView;
	UITextView *_repostTextView;
	UIView *_repostView;
	UIImageView *_repostTweetImageView;
    
    Status *_status;
}

@property(nonatomic, retain) IBOutlet UIImageView* profileImageView;
@property(nonatomic, retain) IBOutlet UILabel* screenNameLabel;
@property(nonatomic, retain) IBOutlet UILabel* dateLabel;
@property(nonatomic, retain) IBOutlet UIButton* actionsButton;
@property(nonatomic, retain) IBOutlet UILabel* repostCountLabel;
@property(nonatomic, retain) IBOutlet UILabel* commentCountLabel;
@property(nonatomic, retain) IBOutlet UIButton* addFavourateButton;
@property(nonatomic, retain) IBOutlet UIScrollView* tweetScrollView;
@property(nonatomic, retain) IBOutlet UIImageView* tweetImageView;
@property(nonatomic, retain) IBOutlet UITextView* tweetTextView;
@property(nonatomic, retain) IBOutlet UITextView* repostTextView;
@property(nonatomic, retain) IBOutlet UIView* repostView;
@property(nonatomic, retain) IBOutlet UIImageView* repostTweetImageView;

@property(nonatomic, retain) Status* status;

- (IBAction)actionsButtonClicked:(UIButton *)sender;
- (IBAction)profileImageButtonClicked:(id)sender;
- (IBAction)commentButtonClicked:(id)sender;
- (IBAction)repostButtonClicked:(id)sender;
- (IBAction)addFavButtonClicked:(id)sender;


@end
