//
//  CCUserInfoCardViewController.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-16.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "CCUserInfoCardViewController.h"
#import "User.h"
#import "WeiboClient.h"

@implementation CCUserInfoCardViewController

@synthesize theNewFollowersCountLabel = _theNewFollowersCountLabel;


- (void)dealloc
{
	[_theNewFollowersCountLabel release];
	
    [super dealloc];
}

- (void)viewDidUnload
{
	self.theNewFollowersCountLabel = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
	
	self.theNewFollowersCountLabel.hidden = YES;
	
    WeiboClient *client = [WeiboClient client];
    [client resetUnreadCount:ResetUnreadCountTypeFollowers];
}

- (void)updateUserInfo
{
	self.followersCountLabel.text = self.currentUser.followersCount;
	self.friendsCountLabel.text = self.currentUser.friendsCount;
}


@end
