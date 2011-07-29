//
//  UserCardViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-29.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "UserCardViewController.h"
#import "UIImageViewAddition.h"
#import "User.h"
#import "WeiboClient.h"

@implementation UserCardViewController

@synthesize profileImageView = _profileImageView;
@synthesize followButton = _followButton;
@synthesize unFollowButton = _unFollowButton;
@synthesize backButton = _backButton;
@synthesize screenNameLabel = _screenNameLabel;
@synthesize relationshipStateLabel = _relationshipStateLabel;
@synthesize locationLabel = _locationLabel;
@synthesize homePageLabel = _homePageLabel;
@synthesize emailLabel = _emailLabel;
@synthesize friendsCountLabel = _friendsCountLabel;
@synthesize followersCountLabel = _followersCountLabel;
@synthesize statusesCountLabel = _statusesCountLabel;
@synthesize descriptionTextView = _descriptionTextView;
@synthesize user = _user;

- (void)dealloc
{
    NSLog(@"UserCardViewController dealloc");
    
    [_profileImageView release];
    [_followButton release];
    [_unFollowButton release];
    [_backButton release];
    [_screenNameLabel release];
    [_relationshipStateLabel release];
    [_locationLabel release];
    [_homePageLabel release];
    [_emailLabel release];
    [_friendsCountLabel release];
    [_followersCountLabel release];
    [_statusesCountLabel release];
    [_descriptionTextView release];
    [_user release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.profileImageView = nil;
    self.followButton = nil;
    self.unFollowButton = nil;
    self.backButton = nil;
    self.screenNameLabel = nil;
    self.relationshipStateLabel = nil;
    self.locationLabel = nil;
    self.homePageLabel = nil;
    self.emailLabel = nil;
    self.friendsCountLabel = nil;
    self.followersCountLabel = nil;
    self.statusesCountLabel = nil;
    self.descriptionTextView = nil;
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
            self.followButton.hidden = NO;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.profileImageView loadImageFromURL:self.user.profileImageURL completion:NULL];
    
    self.followButton.hidden = YES;
    self.unFollowButton.hidden = YES;
    self.relationshipStateLabel.text = @"";
    
    self.screenNameLabel.text = self.user.screenName;
    self.locationLabel.text = self.user.location;
    self.homePageLabel.text = self.user.blogURL;
    self.emailLabel.text = @"无";
    self.descriptionTextView.text = self.user.selfDescription;
    
    self.friendsCountLabel.text = self.user.friendsCount;
    self.followersCountLabel.text = self.user.followersCount;
    self.statusesCountLabel.text = self.user.statusesCount;
    
    [self setRelationshipState];
}

- (IBAction)followButtonClicked:(id)sender {
}

- (IBAction)unfollowButtonClicked:(id)sender {
}

- (IBAction)backButtonClicked:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)showFriendsButtonClicked:(id)sender {
}

- (IBAction)showFollowersButtonClicked:(id)sender {
}

- (IBAction)showStatusesButtonClicked:(id)sender {
}





@end
