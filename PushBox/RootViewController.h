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
    
    LoginViewController *_loginViewController;
    DockViewController *_dockViewController;
    MessagesViewController *_messagesViewController;
    CardTableViewController *_cardTableViewController;
    
    NSTimer *_playTimer;
	
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

@property(nonatomic, retain) LoginViewController* loginViewController;
@property(nonatomic, retain) DockViewController *dockViewController;
@property(nonatomic, retain) MessagesViewController *messagesViewController;
@property(nonatomic, retain) CardTableViewController* cardTableViewController;

- (IBAction)showFriendsTimeline:(id)sender;

@end
