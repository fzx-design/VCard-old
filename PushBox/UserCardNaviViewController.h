//
//  UserCardNaviViewController.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-15.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCardContentViewController.h"

@interface UserCardNaviViewController : UIViewController

@property (nonatomic, retain) UserCardContentViewController* contentViewController;
@property (nonatomic, retain) UINavigationController* naviController;

+ (void)setSharedUserCardNaviViewController:(UserCardNaviViewController*)vc;
+ (void)sharedUserCardDismiss;
- (id)initWithRootViewController:(UIViewController*)vc;

@end
