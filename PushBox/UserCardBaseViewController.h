//
//  UserCardBaseViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-8-5.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataViewController.h"

#define kNotificationNameShouldShowUserTimeline @"kNotificationNameShouldShowUserTimeline"
#define kNotificationNameShouldDismissUserCard @"kNotificationNameShouldDismissUserCard"

@class User;

@interface UserCardBaseViewController : CoreDataViewController {
    UIImageView *_profileImageView;
    UIImageView *_verifiedImageView;
    UILabel *_screenNameLabel;
	UILabel *_locationLabel;
	UILabel *_homePageLabel;
	UILabel *_emailLabel;
    UILabel *_friendsCountLabel;
	UILabel *_followersCountLabel;
	UILabel *_statusesCountLabel;
	
	UILabel *_genderLabel;
	UILabel *blogURLLabel;
	UILabel *_careerInfoLabel;
	
	UITextView *_descriptionTextView;
    
    User *_user;
}

@property(nonatomic, retain) IBOutlet UIImageView* profileImageView;
@property(nonatomic, retain) IBOutlet UIImageView* verifiedImageView;
@property(nonatomic, retain) IBOutlet UILabel* screenNameLabel;
@property(nonatomic, retain) IBOutlet UILabel* locationLabel;
@property(nonatomic, retain) IBOutlet UILabel* homePageLabel;
@property(nonatomic, retain) IBOutlet UILabel* emailLabel;
@property(nonatomic, retain) IBOutlet UILabel* friendsCountLabel;
@property(nonatomic, retain) IBOutlet UILabel* followersCountLabel;
@property(nonatomic, retain) IBOutlet UILabel* statusesCountLabel;
@property(nonatomic, retain) IBOutlet UITextView* descriptionTextView;

@property (nonatomic, retain) IBOutlet UILabel *genderLabel;
@property (nonatomic, retain) IBOutlet UILabel *blogURLLabel;
@property (nonatomic, retain) IBOutlet UILabel *careerInfoLabel;

@property(nonatomic, retain) User* user;

- (void)configureView;

- (IBAction)showFriendsButtonClicked:(id)sender;
- (IBAction)showFollowersButtonClicked:(id)sender;
- (IBAction)showStatusesButtonClicked:(id)sender;

@end
