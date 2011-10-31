//
//  RootViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataViewController.h"
#import "LoginViewController.h"
#import "DockViewController.h"
#import "CardTableViewController.h"
#import "PostViewController.h"
#import "MessagesViewController.h"

@interface RootViewController : CoreDataViewController<LoginViewControllerDelegate, CardTableViewControllerDelegate> {
    UIImageView *_backgroundImageView;
    UIImageView *_pushBoxHDImageView;
    
	UIView *_bottomStateFrameView;
    UIView *_bottomStateView;
	UIImageView *_bottomStateInvisibleView;
	UIButton *_bottomBackButton;
    
	UILabel *_bottomStateLabel;
    UITextField *_bottomStateTextField;
    
    UIImageView *_holeImageView;
	
	UIView *_notificationView;
	UILabel *_notiNewCommentLabel;
	UILabel *_notiNewFollowerLabel;
	UILabel *_notiNewAtLabel;
	
	UIButton *_notiCloseButton;
	UIButton *_notiDisplayNewFollowersButton;
	UIButton *_notiDisplayNewMentionsButton;
	UIButton *_notiDisplayNewCommentsButton;
	
    LoginViewController *_loginViewController;
    DockViewController *_dockViewController;
    MessagesViewController *_messagesViewController;
    CardTableViewController *_cardTableViewController;
    
    NSTimer *_playTimer;
	
	BOOL _commandCenterFlag;
	BOOL _refreshFlag;
	NSInteger preNewFollowerCount;
	NSInteger preNewCommentCount;
	NSInteger preNewMentionCount;
	
	UIImage *_tmpImage;
}

@property(nonatomic, retain) IBOutlet UIImageView* backgroundImageView;
@property(nonatomic, retain) IBOutlet UIImageView* pushBoxHDImageView;
@property(nonatomic, retain) IBOutlet UIView* bottomStateFrameView;
@property(nonatomic, retain) IBOutlet UIView* bottomStateView;
@property(nonatomic, retain) IBOutlet UIImageView* bottomStateInvisibleView;
@property(nonatomic, retain) IBOutlet UIButton* bottomBackButton;;
@property(nonatomic, retain) IBOutlet UILabel* bottomStateLabel;
@property(nonatomic, retain) IBOutlet UITextField* bottomStateTextField;

@property(nonatomic, retain) IBOutlet UIView *notificationView;
@property(nonatomic, retain) IBOutlet UILabel *notiNewCommentLabel;
@property(nonatomic, retain) IBOutlet UILabel *notiNewFollowerLabel;
@property(nonatomic, retain) IBOutlet UILabel *notiNewAtLabel;

@property(nonatomic, retain) IBOutlet UIButton *notiCloseButton;
@property(nonatomic, retain) IBOutlet UIButton *notiDisplayNewFollowersButton;
@property(nonatomic, retain) IBOutlet UIButton *notiDisplayNewMentionsButton;
@property(nonatomic, retain) IBOutlet UIButton *notiDisplayNewCommentsButton;

@property(nonatomic, retain) LoginViewController* loginViewController;
@property(nonatomic, retain) DockViewController *dockViewController;
@property(nonatomic, retain) MessagesViewController *messagesViewController;
@property(nonatomic, retain) CardTableViewController* cardTableViewController;

- (IBAction)showFriendsTimeline:(id)sender;
- (IBAction)refreshAndShowCommentCenter:(id)sender;
- (IBAction)closeNotificationPop:(id)sender;

@end
