//
//  CCUserInfoCardViewController.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-16.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "UserCardBaseViewController.h"

@interface CCUserInfoCardViewController : UserCardBaseViewController{
	UILabel *_theNewFollowersCountLabel;
}

@property(nonatomic, retain) IBOutlet UILabel *theNewFollowersCountLabel;

- (void)updateUserInfo;

@end
