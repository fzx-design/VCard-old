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

@interface RootViewController : CoreDataViewController<LoginViewControllerDelegate, CardTableViewControllerDelegate> {
    UIImageView *_backgroundImageView;
    UIImageView *_pushBoxHDImageView;
    
    UIView *_bottomStateView;
    UILabel *_bottomStateLabel;
    
    UIImageView *_holeImageView;
    
    LoginViewController *_loginViewController;
    DockViewController *_dockViewController;
    CardTableViewController *_cardTableViewController;
    
    NSTimer *_playTimer;
}

@property(nonatomic, retain) IBOutlet UIImageView* backgroundImageView;
@property(nonatomic, retain) IBOutlet UIImageView* pushBoxHDImageView;
@property(nonatomic, retain) IBOutlet UIView* bottomStateView;
@property(nonatomic, retain) IBOutlet UILabel* bottomStateLabel;

@property(nonatomic, retain) LoginViewController* loginViewController;
@property(nonatomic, retain) DockViewController *dockViewController;
@property(nonatomic, retain) CardTableViewController* cardTableViewController;

- (IBAction)showFriendsTimeline:(id)sender;

@end
