//
//  RootViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataViewController.h"
#import "LoginViewController.h"
#import "DockViewController.h"

@interface RootViewController : CoreDataViewController<LoginViewControllerDelegate> {
    UIImageView *_backgroundImageView;
    UIImageView *_pushBoxHDImageView;
    
    LoginViewController *_loginViewController;
    DockViewController *_dockViewController;
}

@property(nonatomic, retain) IBOutlet UIImageView* backgroundImageView;
@property(nonatomic, retain) IBOutlet UIImageView* pushBoxHDImageView;

@property(nonatomic, retain) LoginViewController* loginViewController;
@property(nonatomic, retain) DockViewController *dockViewController;

@end
