//
//  UserCardViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-29.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "UserCardViewController.h"
#import "User.h"
#import "WeiboClient.h"

@implementation UserCardViewController

@synthesize followButton = _followButton;
@synthesize unFollowButton = _unFollowButton;
@synthesize backButton = _backButton;
@synthesize relationshipStateLabel = _relationshipStateLabel;
@synthesize delegate = _delegate;

- (void)dealloc
{
    NSLog(@"UserCardViewController dealloc");
    
    [_followButton release];
    [_unFollowButton release];
    [_backButton release];
    [_relationshipStateLabel release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.followButton = nil;
    self.unFollowButton = nil;
    self.backButton = nil;
    self.relationshipStateLabel = nil;
}

- (id)initWithUsr:(User *)user
{
    self = [super init];
    self.user = user;
    return self;
}

- (void)setRelationshipState
{
    WeiboClient *client = [WeiboClient client];
    
    [client setCompletionBlock:^(WeiboClient *client) {
        NSDictionary *dict = client.responseJSONObject;
        dict = [dict objectForKey:@"target"];
        
        BOOL followedByMe = [[dict objectForKey:@"followed_by"] boolValue];
        BOOL followingMe = [[dict objectForKey:@"following"] boolValue];
        
        if (followedByMe) {
            self.unFollowButton.hidden = NO;
        }
        else {
            if (![self.user isEqualToUser:self.currentUser]) {
                self.followButton.hidden = NO;
            }
        }
        
        NSString *state = nil;
        if (followingMe) {
            state = [NSString stringWithFormat:NSLocalizedString(@"%@ 正关注你", nil), self.user.screenName];
        }
        else {
            state = [NSString stringWithFormat:NSLocalizedString(@"%@ 未关注你", nil), self.user.screenName];
        }
        self.relationshipStateLabel.text = state;
    }];
    
    [client getRelationshipWithUser:self.user.userID];
}

- (void)configureView
{
    [super configureView];
    self.followButton.hidden = YES;
    self.unFollowButton.hidden = YES;
    self.relationshipStateLabel.text = @"";
    [self setRelationshipState];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

- (IBAction)followButtonClicked:(id)sender {
    WeiboClient *client = [WeiboClient client];
    [client setCompletionBlock:^(WeiboClient *client) {
        if (!client.hasError) {
            self.unFollowButton.hidden = NO;
            self.followButton.hidden = YES;
        }
    }];
    [client follow:self.user.userID];
}

- (IBAction)unfollowButtonClicked:(id)sender {
    WeiboClient *client = [WeiboClient client];
    [client setCompletionBlock:^(WeiboClient *client) {
        if (!client.hasError) {
            self.unFollowButton.hidden = YES;
            self.followButton.hidden = NO;
        }
    }];
    [client unfollow:self.user.userID];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [self.delegate userCardViewControllerDidDismiss:self];
}

@end