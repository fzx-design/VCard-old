//
//  RootViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "RootViewController.h"
#import "WeiboClient.h"
#import "UIApplicationAddition.h"
#import <QuartzCore/QuartzCore.h>

#define kLoginViewCenter CGPointMake(512.0, 370.0)
#define kDockViewFrameOriginY 625.0

@interface RootViewController(private)
- (void)showLoginView;
- (void)showDockView;
- (void)updateBackgroundImageAnimated:(BOOL)animated;
@end

@implementation RootViewController

@synthesize backgroundImageView = _backgroundImageView;
@synthesize pushBoxHDImageView = _pushBoxHDImageView;

@synthesize loginViewController = _loginViewController;
@synthesize dockViewController = _dockViewController;

#pragma mark - View lifecycle

- (void)dealloc
{
    [_backgroundImageView release];
    [_pushBoxHDImageView release];
    
    [_loginViewController release];
    [_dockViewController release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.backgroundImageView = nil;
    self.pushBoxHDImageView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateBackgroundImageAnimated:NO];
//    WeiboClient *client = [WeiboClient client];
//    [client follow:@"1951041147"];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(backgroundChangedNotification:) 
				   name:kNotificationNameBackgroundChanged 
				 object:nil];
    
//    if ([WeiboClient authorized]) {
//        //show table
//    }
//    else {
        [self showLoginView];
        [self showDockView];
   //}
    
}

- (void)updateBackgroundImageAnimated:(BOOL)animated
{
    int enumValue = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyBackground];
    
	NSString *fileName = [BackgroundManViewController backgroundImageFilePathFromEnum:enumValue];
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"png"];
	UIImage *img = [UIImage imageWithContentsOfFile:path];
	
	if (animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = 1.0;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.backgroundImageView.layer addAnimation:transition forKey:nil];
    }
    
	self.backgroundImageView.image = img;
}


- (void)backgroundChangedNotification:(id)sender
{
	[self updateBackgroundImageAnimated:YES];
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

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


@end
