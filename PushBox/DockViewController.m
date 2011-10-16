//
//  DockViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-25.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "DockViewController.h"
#import "CardTableViewController.h" //to get notification defines

@implementation DockViewController

@synthesize refreshButton = _refreshButton;
@synthesize newTweetButton = _newTweetButton;
@synthesize playButton = _playButton;
@synthesize commandCenterButton = _commandCenterButton;
@synthesize messagesCenterButton = _messagesCenterButton;
@synthesize showFavoritesButton = _showFavoritesButton;
@synthesize optionsButton = _optionsButton;
@synthesize searchButton = _searchButton;
@synthesize slider = _slider;
@synthesize refreshNotiImageView = _refreshNotiImageView;
@synthesize commandCenterNotiImageView = _commandCenterNotiImageView;
@synthesize optionsPopoverController = _optionsPopoverController;
@synthesize controlContainerView = _controlContainerView;
@synthesize commentsTableViewController = _commentsTableViewController;
@synthesize userCardNaviViewController = _userCardNaviViewController;
@synthesize ccUserInfoCardViewController = _ccUserInfoCardViewController;

#pragma mark - View lifecycle

- (void)dealloc
{
    [_refreshButton release];
    [_newTweetButton release];
    [_playButton release];
    [_commandCenterButton release];
    [_messagesCenterButton release];
    [_showFavoritesButton release];
    [_optionsButton release];
    [_slider release];
    [_controlContainerView release];
    [_refreshNotiImageView release];
    [_commandCenterNotiImageView release];
    [_optionsPopoverController release];
    [_commentsTableViewController release];
	[_userCardNaviViewController release];
	[_ccUserInfoCardViewController release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.refreshButton = nil;
    self.newTweetButton = nil;
    self.playButton = nil;
    self.commandCenterButton = nil;
    self.messagesCenterButton = nil;
    self.showFavoritesButton = nil;
    self.optionsButton = nil;
    self.slider = nil;
    self.refreshNotiImageView = nil;
    self.commandCenterNotiImageView = nil;
    self.controlContainerView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.slider setThumbImage:[UIImage imageNamed:@"dock_slider_thumb.png"] forState:UIControlStateNormal];
	[self.slider setThumbImage:[UIImage imageNamed:@"dock_slider_thumb_HL.png"] forState:UIControlStateHighlighted];
	[self.slider setMinimumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
	[self.slider setMaximumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(dismissPopoverNotification:) 
                   name:kNotificationNameShouldDismissPopoverView 
                 object:nil];
    
    [center addObserver:self
               selector:@selector(newCommentsToMeNotification:)
                   name:kNotificationNameNewCommentsToMe object:nil];
    
    [center addObserver:self
               selector:@selector(newStatusesNotification:)
                   name:kNotificationNameNewStatuses object:nil];
    
    [center addObserver:self
               selector:@selector(newFollowersNotification:) 
                   name:kNotificationNameNewFollowers object:nil];
    
    self.refreshNotiImageView.hidden = YES;
    self.commandCenterNotiImageView.hidden = YES;

	self.ccUserInfoCardViewController = [[CCUserInfoCardViewController alloc] init];
	self.ccUserInfoCardViewController.currentUser = self.currentUser;
	self.userCardNaviViewController = [[UserCardNaviViewController alloc] initWithRootViewController:self.ccUserInfoCardViewController];
	self.userCardNaviViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
	CGRect frame = CGRectMake(-16, 121, self.userCardNaviViewController.view.frame.size.width, self.userCardNaviViewController.view.frame.size.height);
	self.userCardNaviViewController.view.frame = frame;
	[self.view addSubview:self.userCardNaviViewController.view];
	
	
    self.commentsTableViewController.dataSource = CommentsTableViewDataSourceCommentsToMe;
    self.commentsTableViewController.currentUser = self.currentUser;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self.ccUserInfoCardViewController viewWillAppear:YES];
    [self.commentsTableViewController viewWillAppear:YES];
}

- (void)newCommentsToMeNotification:(id)sender
{
    self.commentsTableViewController.newCommentsImageView.hidden = NO;
    if (!self.commandCenterButton.selected) {
        self.commandCenterNotiImageView.hidden = NO;
    }
}

- (void)newStatusesNotification:(id)sender
{
    self.refreshNotiImageView.hidden = NO;
}

- (void)newFollowersNotification:(id)sender
{
	self.ccUserInfoCardViewController.newFriendsImageView.hidden = NO;
    if (!self.commandCenterButton.selected) {
        self.commandCenterNotiImageView.hidden = NO;
    }
}

- (void)dismissPopoverNotification:(id)sender
{
    [self.optionsPopoverController dismissPopoverAnimated:YES];
}

- (void)showControlsAnimated:(BOOL)animated;
{
    [UIView animateWithDuration:animated animations:^{
        self.controlContainerView.alpha = 1.0;
    }];
}

- (void)hideControlsAnimated:(BOOL)animated;
{
    [UIView animateWithDuration:animated animations:^{
        self.controlContainerView.alpha = 0.0;
    }];
}

- (IBAction)optionsButtonClicked:(id)sender {
    OptionsTableViewController *otvc = [[OptionsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:otvc];
    
    _optionsPopoverController = [[UIPopoverController alloc] initWithContentViewController:nc];
    self.optionsPopoverController.delegate = self;
    
	CGRect rect = self.optionsButton.bounds;
	rect.origin.x += 7;
	rect.origin.y += 10;
	rect.size.width -= 30;
	rect.size.height -= 30;
    [self.optionsPopoverController presentPopoverFromRect:rect
                                                   inView:self.optionsButton
                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                 animated:YES];
    [otvc release];
    [nc release];
}

- (IBAction)refreshButtonClicked:(id)sender {
    self.refreshNotiImageView.hidden = YES;
}

- (IBAction)commandCenterButtonClicked:(id)sender {
    self.commandCenterNotiImageView.hidden = YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.optionsPopoverController = nil;
}


@end
