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

- (void)dealloc
{
    [super dealloc];
}

- (void)viewDidUnload
{
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
}

@end
