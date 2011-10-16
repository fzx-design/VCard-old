//
//  CCUserInfoCardViewController.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-16.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "CCUserInfoCardViewController.h"
#import "WeiboClient.h"

@implementation CCUserInfoCardViewController

@synthesize newFriendsImageView = _newFriendsImageView;

- (void)dealloc
{
    [_newFriendsImageView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.newFriendsImageView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.user = self.currentUser;
    [self configureView];
}

- (void)showFollowersButtonClicked:(id)sender
{
    [super showFollowersButtonClicked:sender];
    self.newFriendsImageView.hidden = YES;
    WeiboClient *client = [WeiboClient client];
    [client resetUnreadCount:ResetUnreadCountTypeFollowers];
}

@end
