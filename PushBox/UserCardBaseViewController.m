//
//  UserCardBaseViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-8-5.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "UserCardBaseViewController.h"
#import "UIImageViewAddition.h"
#import "User.h"
#import "RelationshipTableViewController.h"

@implementation UserCardBaseViewController

@synthesize profileImageView = _profileImageView;
@synthesize screenNameLabel = _screenNameLabel;
@synthesize locationLabel = _locationLabel;
@synthesize homePageLabel = _homePageLabel;
@synthesize emailLabel = _emailLabel;
@synthesize friendsCountLabel = _friendsCountLabel;
@synthesize followersCountLabel = _followersCountLabel;
@synthesize statusesCountLabel = _statusesCountLabel;
@synthesize descriptionTextView = _descriptionTextView;
@synthesize user = _user;

@synthesize genderLabel = _genderLabel;
@synthesize birthdayLabel = _birthdayLabel;
@synthesize careerInfoLabel = _careerInfoLabel;

- (void)dealloc
{
    [_profileImageView release];
    [_screenNameLabel release];
    [_locationLabel release];
    [_homePageLabel release];
    [_emailLabel release];
    [_friendsCountLabel release];
    [_followersCountLabel release];
    [_statusesCountLabel release];
    [_descriptionTextView release];
    [_user release];
	[_genderLabel release];
    [_birthdayLabel release];
    [_careerInfoLabel release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.profileImageView = nil;
    self.screenNameLabel = nil;
    self.locationLabel = nil;
    self.homePageLabel = nil;
    self.emailLabel = nil;
    self.friendsCountLabel = nil;
    self.followersCountLabel = nil;
    self.statusesCountLabel = nil;
    self.descriptionTextView = nil;
	self.genderLabel = nil;
    self.birthdayLabel = nil;
    self.careerInfoLabel = nil;
}

- (void)configureView
{
    [self.profileImageView loadImageFromURL:self.user.profileImageURL 
                                 completion:NULL
                             cacheInContext:self.managedObjectContext];
    
    self.screenNameLabel.text = self.user.screenName;
    self.locationLabel.text = self.user.location;
    self.homePageLabel.text = self.user.blogURL;
    self.emailLabel.text = @"无";
    self.descriptionTextView.text = self.user.selfDescription;
    
    self.friendsCountLabel.text = self.user.friendsCount;
    self.followersCountLabel.text = self.user.followersCount;
    self.statusesCountLabel.text = self.user.statusesCount;
	
	self.genderLabel.text = self.user.gender;
//	self.birthdayLabel.text = self.user.
}

- (IBAction)showFriendsButtonClicked:(id)sender {
    RelationshipTableViewController *vc = [[RelationshipTableViewController alloc] initWithType:RelationshipViewTypeFriends];
    vc.currentUser = self.currentUser;
    vc.user = self.user;
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    vc.modalTransitionStyle = self.modalTransitionStyle;
//    [self presentModalViewController:vc animated:YES];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

- (IBAction)showFollowersButtonClicked:(id)sender {
    RelationshipTableViewController *vc = [[RelationshipTableViewController alloc] initWithType:RelationshipViewTypeFollowers];
    vc.currentUser = self.currentUser;
    vc.user = self.user;
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    vc.modalTransitionStyle = self.modalTransitionStyle;
//    [self presentModalViewController:vc animated:YES];
	[self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (IBAction)showStatusesButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldDismissUserCard object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowUserTimeline object:self.user];
}



@end
