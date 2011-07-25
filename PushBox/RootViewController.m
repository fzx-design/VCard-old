//
//  RootViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "RootViewController.h"
#import "WeiboClient.h"

#define kLoginViewCenter CGPointMake(512.0, 370.0)
#define kDockViewFrameOriginY 625.0

@interface RootViewController(private)
- (void)showLoginView;
- (void)showDockView;
@end

@implementation RootViewController

@synthesize backgroundImageView = _backgroundImageView;
@synthesize pushBoxHDImageView = _pushBoxHDImageView;
@synthesize loadingImageView = _loadingImageView;
@synthesize loadingActivityIndicator = _loadingActivityIndicator;

@synthesize loginViewController = _loginViewController;
@synthesize dockViewController = _dockViewController;

#pragma mark - View lifecycle

- (void)dealloc
{
    [_backgroundImageView release];
    [_pushBoxHDImageView release];
    [_loadingImageView release];
    [_loadingActivityIndicator release];
    
    [_loginViewController release];
    [_dockViewController release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.backgroundImageView = nil;
    self.pushBoxHDImageView = nil;
    self.loadingImageView = nil;
    self.loadingActivityIndicator = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [WeiboClient signout];
    
    if ([WeiboClient authorized]) {
        //show table
    }
    else {
        [self showLoginView];
        [self showDockView];
    }
    
    
}

- (void)showDockView
{
    if (!_dockViewController) {
        _dockViewController = [[DockViewController alloc] init];
    }
    CGRect frame = self.dockViewController.view.frame;
    frame.origin.y = kDockViewFrameOriginY;
    self.dockViewController.view.frame = frame;
    
    //delegate
    [self.view addSubview:self.dockViewController.view];
    
    self.dockViewController.view.alpha = 0.0;
    
    [UIView animateWithDuration:1.0 animations:^{
        self.dockViewController.view.alpha = 1.0;
    }];
    
}

- (void)showLoginView
{
    if (!_loginViewController) {
        _loginViewController = [[LoginViewController alloc] init];
    }
    self.loginViewController.view.center = kLoginViewCenter;
    self.loginViewController.delegate = self;
    [self.view addSubview:self.loginViewController.view];
    
    self.loginViewController.view.alpha = 0.0;
    self.pushBoxHDImageView.alpha = 0.0;

    [UIView animateWithDuration:1.0 animations:^{
        self.pushBoxHDImageView.alpha = 1.0;
        self.loginViewController.view.alpha = 1.0;
    }];
}

- (void)loginViewControllerDidLogin:(UIViewController *)vc
{
    NSLog(@"login succ");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


@end
