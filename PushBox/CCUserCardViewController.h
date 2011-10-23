//
//  CCUserCardViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-8-5.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "UserCardBaseViewController.h"

@interface CCUserCardViewController : UserCardBaseViewController {
	UILabel *_theNewFollowersCountLabel;
}

@property(nonatomic, retain) IBOutlet UILabel *theNewFollowersCountLabel;

@end
