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

#define kCardTableViewFrameOriginY 37.0


@interface RootViewController(private)
- (void)showLoginView;
- (void)hideLoginView;
- (void)showDockView;
- (void)hideDockView;
- (void)showCardTableView;
- (void)hideCardTableView;
- (void)updateBackgroundImageAnimated:(BOOL)animated;
@end

@implementation RootViewController

@synthesize backgroundImageView = _backgroundImageView;
@synthesize pushBoxHDImageView = _pushBoxHDImageView;

@synthesize loginViewController = _loginViewController;
@synthesize dockViewController = _dockViewController;
@synthesize cardTableViewController = _cardTableViewController;

#pragma mark - View lifecycle

- (void)dealloc
{
    [_backgroundImageView release];
    [_pushBoxHDImageView release];
    
    [_loginViewController release];
    [_dockViewController release];
    [_cardTableViewController release];
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

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(backgroundChangedNotification:) 
				   name:kNotificationNameBackgroundChanged 
				 object:nil];
    
    if ([WeiboClient authorized]) {
        self.pushBoxHDImageView.alpha = 0.0;
        [self showDockView];
        [self showCardTableView];
        [self.cardTableViewController refresh];
    }
    else {
        [self showLoginView];
    }
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

- (void)refresh
{
    [self.cardTableViewController refresh];
}

- (void)post
{
    PostViewController *vc = [[PostViewController alloc] init];
    [[UIApplication sharedApplication] presentModalViewController:vc atHeight:kModalViewHeight];
    [vc release];
}

- (void)showDockView
{
    if (!_dockViewController) {
        _dockViewController = [[DockViewController alloc] init];
        CGRect frame = self.dockViewController.view.frame;
        frame.origin.y = kDockViewFrameOriginY;
        self.dockViewController.view.frame = frame;
        self.dockViewController.view.alpha = 0.0;
        
        [self.dockViewController.refreshButton addTarget:self 
                                                  action:@selector(refresh) 
                                        forControlEvents:UIControlEventTouchUpInside];
        
        [self.dockViewController.newTweetButton addTarget:self
                                                   action:@selector(post)
                                         forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    [self.view addSubview:self.dockViewController.view];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.dockViewController.view.alpha = 1.0;
    }];
}

- (void)hideDockView
{
    [UIView animateWithDuration:1.0 animations:^{
        self.dockViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.dockViewController.view removeFromSuperview];
            self.dockViewController = nil;
        }
    }];
}

- (void)showLoginView
{
    if (!_loginViewController) {
        _loginViewController = [[LoginViewController alloc] init];
        self.loginViewController.view.center = kLoginViewCenter;
        self.loginViewController.delegate = self;
        self.loginViewController.view.alpha = 0.0;
        self.pushBoxHDImageView.alpha = 0.0;
    }

    [self.view addSubview:self.loginViewController.view];

    [UIView animateWithDuration:1.0 animations:^{
        self.pushBoxHDImageView.alpha = 1.0;
        self.loginViewController.view.alpha = 1.0;
    }];
}

- (void)hideLoginView
{
    [UIView animateWithDuration:1.0 animations:^{
        self.pushBoxHDImageView.alpha = 0.0;
        self.loginViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.loginViewController.view removeFromSuperview];
            self.loginViewController = nil;
        }
    }];
}

- (void)showCardTableView
{
    if (!_cardTableViewController) {
        _cardTableViewController = [[CardTableViewController alloc] init];
        self.cardTableViewController.managedObjectContext = self.managedObjectContext;
        CGRect frame = self.cardTableViewController.view.frame;
        frame.origin.y = kCardTableViewFrameOriginY;
        self.cardTableViewController.view.frame = frame;
        self.cardTableViewController.view.alpha = 0.0;
    }
    
    [self.view addSubview:self.cardTableViewController.view];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.cardTableViewController.view.alpha = 1.0;
    }];
}

- (void)hideCardTableView
{
    [UIView animateWithDuration:1.0 animations:^{
        self.cardTableViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.cardTableViewController.view removeFromSuperview];
            self.cardTableViewController = nil;
        }
    }];
}

- (void)loginViewControllerDidLogin:(UIViewController *)vc
{
    [self hideLoginView];
    [self showDockView];
    [self showCardTableView];
    [self.cardTableViewController refresh];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


@end
