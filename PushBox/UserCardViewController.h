//
//  UserCardViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-29.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataViewController.h"
#import "RelationshipTableViewController.h"

@class User;

@interface UserCardViewController : CoreDataViewController
{
    UIImageView *_profileImageView;
	UIButton *_followButton;
	UIButton *_unFollowButton;
    UIButton *_backButton;
    UILabel *_screenNameLabel;
    UILabel *_relationshipStateLabel;
	UILabel *_locationLabel;
	UILabel *_homePageLabel;
	UILabel *_emailLabel;
    UILabel *_friendsCountLabel;
	UILabel *_followersCountLabel;
	UILabel *_statusesCountLabel;
	UITextView *_descriptionTextView;
	
    User *_user;
}

@property(nonatomic, retain) IBOutlet UIImageView* profileImageView;
@property(nonatomic, retain) IBOutlet UIButton* followButton;
@property(nonatomic, retain) IBOutlet UIButton* unFollowButton;
@property(nonatomic, retain) IBOutlet UIButton* backButton;
@property(nonatomic, retain) IBOutlet UILabel* screenNameLabel;
@property(nonatomic, retain) IBOutlet UILabel* relationshipStateLabel;
@property(nonatomic, retain) IBOutlet UILabel* locationLabel;
@property(nonatomic, retain) IBOutlet UILabel* homePageLabel;
@property(nonatomic, retain) IBOutlet UILabel* emailLabel;
@property(nonatomic, retain) IBOutlet UILabel* friendsCountLabel;
@property(nonatomic, retain) IBOutlet UILabel* followersCountLabel;
@property(nonatomic, retain) IBOutlet UILabel* statusesCountLabel;
@property(nonatomic, retain) IBOutlet UITextView* descriptionTextView;
@property(nonatomic, retain) User* user;

- (id)initWithUsr:(User *)user;

- (IBAction)followButtonClicked:(id)sender;
- (IBAction)unfollowButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)showFriendsButtonClicked:(id)sender;
- (IBAction)showFollowersButtonClicked:(id)sender;
- (IBAction)showStatusesButtonClicked:(id)sender;


@end
