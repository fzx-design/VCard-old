//
//  RootViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataViewController.h"
#import "LoginViewController.h"

@interface RootViewController : CoreDataViewController<LoginViewControllerDelegate> {
    UIImageView *_backgroundImageView;
    UIImageView *_pushBoxHDImageView;
    
    UIImageView *_loadingImageView;
    UIActivityIndicatorView *_loadingActivityIndicator;
    
    LoginViewController *_loginViewController;
}

@property(nonatomic, retain) IBOutlet UIImageView* backgroundImageView;
@property(nonatomic, retain) IBOutlet UIImageView* pushBoxHDImageView;
@property(nonatomic, retain) IBOutlet UIImageView* loadingImageView;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView* loadingActivityIndicator;

@property(nonatomic, retain) LoginViewController* loginViewController;

@end
