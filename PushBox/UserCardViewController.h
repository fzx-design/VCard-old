//
//  UserCardViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-29.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "UserCardBaseViewController.h"

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
    
    id<UserCardViewControllerDelegate> _delegate;
}

@property(nonatomic, retain) IBOutlet UIButton* followButton;
@property(nonatomic, retain) IBOutlet UIButton* unFollowButton;
@property(nonatomic, retain) IBOutlet UIButton* backButton;
@property(nonatomic, retain) IBOutlet UILabel* relationshipStateLabel;
@property(nonatomic, assign) id<UserCardViewControllerDelegate> delegate;

- (id)initWithUsr:(User *)user;

- (IBAction)followButtonClicked:(id)sender;
- (IBAction)unfollowButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;


@end
