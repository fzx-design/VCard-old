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
#import "RCSwitchClone.h"

@class UserCardViewController;
@protocol UserCardViewControllerDelegate
- (void)userCardViewControllerDidDismiss:(UserCardViewController *)vc;
@end

@interface UserCardViewController: UserCardBaseViewController <SwitchValueChanged>
{
    UIButton *_backButton;
    UILabel *_relationshipStateLabel;

    UIButton *_atButton;
    UIButton *_messageButton;
    
	RCSwitchClone *_switchView;
	
    id<UserCardViewControllerDelegate> _delegate;
}

@property(nonatomic, retain) IBOutlet UIButton* backButton;
@property(nonatomic, retain) IBOutlet UIButton* atButton;
@property(nonatomic, retain) IBOutlet UIButton* messagesButton;
@property(nonatomic, retain) IBOutlet UILabel* relationshipStateLabel;
@property(nonatomic, retain) IBOutlet RCSwitchClone* switchView;
@property(nonatomic, assign) id<UserCardViewControllerDelegate> delegate;



- (id)initWithUsr:(User *)user;

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)atButtonClicked:(id)sender;

- (void)setRelationshipState;

@end
