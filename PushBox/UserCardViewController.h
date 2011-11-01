//
//  UserCardViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-29.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "UserCardBaseViewController.h"
#import "UserCardNaviViewController.h"
#import "PostViewController.h"
#import "UIApplicationAddition.h"
#import "UserTempData.h"

@class UserCardViewController;
@protocol UserCardViewControllerDelegate
- (void)userCardViewControllerDidDismiss:(UserCardViewController *)vc;
@end

@interface UserCardViewController : UserCardBaseViewController
{
	UIButton *_followButton;
	UIButton *_unFollowButton;
    UIButton *_backButton;
    UILabel *_relationshipStateLabel;
	
	UserTempData *_userTempData;
    
    id<UserCardViewControllerDelegate> _delegate;
}

@property(nonatomic, retain) IBOutlet UIButton* followButton;
@property(nonatomic, retain) IBOutlet UIButton* unFollowButton;
@property(nonatomic, retain) IBOutlet UIButton* backButton;
@property(nonatomic, retain) IBOutlet UILabel* relationshipStateLabel;
@property(nonatomic, retain) UserTempData* userTempData;
@property(nonatomic, assign) id<UserCardViewControllerDelegate> delegate;

- (id)initWithUsr:(User *)user;
- (id)initWithUsrTempData:(UserTempData *)user;

- (IBAction)followButtonClicked:(id)sender;
- (IBAction)unfollowButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)atButtonClicked:(id)sender;

- (void)setRelationshipState;

@end
