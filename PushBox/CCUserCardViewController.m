//
//  CCUserCardViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-8-5.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CCUserCardViewController.h"
#import "WeiboClient.h"

@implementation CCUserCardViewController

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

@end
