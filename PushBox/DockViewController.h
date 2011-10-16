//
//  DockViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-25.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataViewController.h"
#import "OptionsTableViewController.h"
#import "CCUserCardViewController.h"
#import "CommentsTableViewController.h"
#import "UserCardNaviViewController.h"
#import "CCUserInfoCardViewController.h"

@interface DockViewController : CoreDataViewController<UIPopoverControllerDelegate> {
    UIButton *_refreshButton;
    UIButton *_newTweetButton;
    UIButton *_playButton;
    UIButton *_commandCenterButton;
    UIButton *_messagesCenterButton;
    UIButton *_showFavoritesButton;
    UIButton *_optionsButton;
    UISlider *_slider;
    UIView *_controlContainerView;
    UIImageView *_refreshNotiImageView;
    UIImageView *_commandCenterNotiImageView;

    UIPopoverController *_optionsPopoverController;
    CommentsTableViewController *_commentsTableViewController;
	
	UserCardNaviViewController *_userCardNaviViewController;
	CCUserInfoCardViewController *_ccUserInfoCardViewController;
}

@property(nonatomic, retain) IBOutlet UIButton* refreshButton;
@property(nonatomic, retain) IBOutlet UIButton* newTweetButton;
@property(nonatomic, retain) IBOutlet UIButton* playButton;
@property(nonatomic, retain) IBOutlet UIButton* commandCenterButton;
@property(nonatomic, retain) IBOutlet UIButton* messagesCenterButton;
@property(nonatomic, retain) IBOutlet UIButton* showFavoritesButton;
@property(nonatomic, retain) IBOutlet UIButton* optionsButton;
@property(nonatomic, retain) IBOutlet UISlider* slider;
@property(nonatomic, retain) IBOutlet UIView* controlContainerView;
@property(nonatomic, retain) IBOutlet UIImageView* refreshNotiImageView;
@property(nonatomic, retain) IBOutlet UIImageView* commandCenterNotiImageView;
@property(nonatomic, retain) UIPopoverController* optionsPopoverController;
@property(nonatomic, retain) IBOutlet CommentsTableViewController* commentsTableViewController;

@property(nonatomic, retain) UserCardNaviViewController* userCardNaviViewController;
@property(nonatomic, retain) CCUserInfoCardViewController* ccUserInfoCardViewController;

- (void)showControlsAnimated:(BOOL)animated;
- (void)hideControlsAnimated:(BOOL)animated;

- (IBAction)optionsButtonClicked:(id)sender;

- (IBAction)refreshButtonClicked:(id)sender;
- (IBAction)commandCenterButtonClicked:(id)sender;


@end
