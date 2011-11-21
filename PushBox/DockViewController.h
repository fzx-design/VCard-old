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
#import "CCCommentsTableViewController.h"
#import "UserCardNaviViewController.h"
#import "CCUserInfoCardViewController.h"

#define kNotificationNameHideCommandCenter @"kNotificationNameHideCommandCenter"

@interface DockViewController : CoreDataViewController<UIPopoverControllerDelegate> {
    UIButton *_refreshButton;
    UIButton *_newTweetButton;
    UIButton *_playButton;
    UIButton *_commandCenterButton;
    UIButton *_messagesCenterButton;
    UIButton *_showFavoritesButton;
    UIButton *_optionsButton;
    UIButton *_searchButton;
    UISlider *_slider;
    UIView *_controlContainerView;
    UIImageView *_refreshNotiImageView;
    UIImageView *_commandCenterNotiImageView;
	
	UIImageView *_postingCircleImageView;
	UIImageView *_postingRoundImageView;
	
	
	UIView *_sliderPopoverView;
	UIView *_sliderUserImageView;
	UILabel *_sliderUserScreenNameLabel;

    UIPopoverController *_optionsPopoverController;
	
	UserCardNaviViewController *_userCardNaviViewController;
	CCUserInfoCardViewController *_ccUserInfoCardViewController;
	
	UserCardNaviViewController *_commentNaviViewController;
	CCCommentsTableViewController *_ccCommentTableViewController;
	
	BOOL refreshFlag;
	NSInteger refreshTime;
}

@property(nonatomic, assign) CGFloat currentSliderPositionX;

@property(nonatomic, retain) IBOutlet UIButton* refreshButton;
@property(nonatomic, retain) IBOutlet UIButton* postButton;
@property(nonatomic, retain) IBOutlet UIButton* playButton;
@property(nonatomic, retain) IBOutlet UIButton* commandCenterButton;
@property(nonatomic, retain) IBOutlet UIButton* messagesCenterButton;
@property(nonatomic, retain) IBOutlet UIButton* searchButton;
@property(nonatomic, retain) IBOutlet UIButton* showFavoritesButton;
@property(nonatomic, retain) IBOutlet UIButton* optionsButton;
@property(nonatomic, retain) IBOutlet UISlider* slider;
@property(nonatomic, retain) IBOutlet UIView* controlContainerView;
@property(nonatomic, retain) IBOutlet UIImageView* refreshNotiImageView;
@property(nonatomic, retain) IBOutlet UIImageView* commandCenterNotiImageView;
@property(nonatomic, retain) UIPopoverController* optionsPopoverController;

@property(nonatomic, retain) IBOutlet UIImageView* postingCircleImageView;
@property(nonatomic, retain) IBOutlet UIImageView* postingRoundImageView;

@property(nonatomic, retain) IBOutlet UIView* sliderPopoverView;
@property(nonatomic, retain) IBOutlet UIView* sliderUserImageView;
@property(nonatomic, retain) IBOutlet UILabel* sliderUserScreenNameLabel;

@property(nonatomic, assign) BOOL refreshNotiImageShown;

@property(nonatomic, retain) UserCardNaviViewController* commentNaviViewController;
@property(nonatomic, retain) CCCommentsTableViewController* ccCommentTableViewController;
@property(nonatomic, retain) UserCardNaviViewController* userCardNaviViewController;
@property(nonatomic, retain) CCUserInfoCardViewController* ccUserInfoCardViewController;

- (void)showControlsAnimated:(BOOL)animated;
- (void)hideControlsAnimated:(BOOL)animated;

- (IBAction)optionsButtonClicked:(id)sender;

- (IBAction)refreshButtonClicked:(id)sender;
- (IBAction)commandCenterButtonClicked:(id)sender;

- (IBAction)hideCommandCenterButtonClicked:(id)sender;

- (void)showLoadingView;
- (void)hideLoadingView;


@end
