//
//  UIApplicationAddition.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-26.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "UIApplicationAddition.h"
#import "PushBoxAppDelegate.h"

#define kXModifier -4.0
#define kAnimationDuration 0.5
#define kBackViewAlpha 0.5

static NSTimer *_refreshTimer;
static NSTimer *_loadingTimer;
static UIImageView *_loadingImageView;
static UIImageView *_loadingCircleImageView;
static UIImageView *_loadingRoundImageView;

static UIImageView *_refreshCircleImageView;
static UIImageView *_refreshRoundImageView;
//static UIActivityIndicatorView *_loadingActivityIndicator;

static UIViewController *_modalViewController;
static UIView *_backView;

static CGFloat refreshTime;
static CGFloat offset;

@implementation UIApplication (UIApplication_RootView)
//
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
//{
//    PushBoxAppDelegate *appDelegate = (PushBoxAppDelegate *)[[UIApplication sharedApplication] delegate];
//    return appDelegate.persistentStoreCoordinator;
//}

- (UIView *)rootView
{
    return [[self rootViewController] view];
}

- (UIViewController *)rootViewController
{
    PushBoxAppDelegate *appDelegate = (PushBoxAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.rootViewController;
}

- (void)updateLoadingView
{
	offset -= 0.05;
	_loadingCircleImageView.transform = CGAffineTransformMakeRotation(offset);
}

- (void)updateRefreshView
{
	offset -= 0.05;
	_refreshCircleImageView.transform = CGAffineTransformMakeRotation(offset);
	
	refreshTime += 0.01;
	if (refreshTime > 3) {
		[self hideRefreshView];
	}
}

- (void)showLoadingView
{
    if (!_loadingImageView) {
        _loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"root_loading_bg"]];
        _loadingImageView.center = CGPointMake(512.0, 345.0);
    }
    
    if (!_loadingCircleImageView) {
        _loadingCircleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_circle.png"]];
        _loadingCircleImageView.center = CGPointMake(512.0, 338.0);
    }
	
	if (!_loadingRoundImageView) {
        _loadingRoundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refreshing_bg.png"]];
        _loadingRoundImageView.center = CGPointMake(512.0, 338.0);
    }
    
    [[self rootView] addSubview:_loadingImageView];
	[[self rootView] addSubview:_loadingRoundImageView];
	[[self rootView] addSubview:_loadingCircleImageView];
	
	offset = 0;
	
	_loadingTimer = [NSTimer scheduledTimerWithTimeInterval:(0.01) target:self selector:@selector(updateLoadingView) userInfo:nil repeats:YES];
}


- (void)showRefreshView
{
	if (!_refreshCircleImageView) {
        _refreshCircleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_circle.png"]];
        _refreshCircleImageView.center = CGPointMake(45.0, 711);
		_refreshCircleImageView.userInteractionEnabled = NO;
    }
	
	if (!_refreshRoundImageView) {
        _refreshRoundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refreshing_bg.png"]];
        _refreshRoundImageView.center = CGPointMake(45, 712);
		_refreshRoundImageView.userInteractionEnabled = NO;
    }
    
	[[self rootView] addSubview:_refreshRoundImageView];
	[[self rootView] addSubview:_refreshCircleImageView];
	
	offset = 0;
	refreshTime = 0;
	
	_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:(0.01) target:self selector:@selector(updateRefreshView) userInfo:nil repeats:YES];
}


- (void)hideLoadingView
{
	[_loadingTimer invalidate];
    [_loadingImageView removeFromSuperview];
	[_loadingCircleImageView removeFromSuperview];
	[_loadingRoundImageView removeFromSuperview];
}

- (void)hideRefreshView
{
	[_refreshTimer invalidate];
	[_refreshCircleImageView removeFromSuperview];
	[_refreshRoundImageView removeFromSuperview];
}

- (void)presentModalViewController:(UIViewController *)vc atHeight:(CGFloat)height
{
    if (_modalViewController) {
        return;
    }
    
	_modalViewController = [vc retain];
	
	_backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
	_backView.alpha = 0.0;
	_backView.backgroundColor = [UIColor blackColor];

    CGRect frame = vc.view.frame;
    frame.origin.x = 1024/2 - frame.size.width/2 - kXModifier;
    frame.origin.y = 768;
    vc.view.frame = frame;
    
	[[self rootView] addSubview:_backView];
	[[self rootView] addSubview:vc.view];
	
	[UIView animateWithDuration:kAnimationDuration animations:^{
		_backView.alpha = kBackViewAlpha;
        CGRect frame = vc.view.frame;
        frame.origin.y = height;
        vc.view.frame = frame;
	}];
}

- (void)dismissModalViewController
{
	[UIView animateWithDuration:kAnimationDuration animations:^{
		_backView.alpha = 0.0;
        CGRect frame = _modalViewController.view.frame;
        frame.origin.y = 768;
        _modalViewController.view.frame = frame;
	} completion:^(BOOL fin){
		if (fin) {
			[_backView removeFromSuperview];
            [_backView release];
            _backView = nil;
			[_modalViewController release];
            _modalViewController = nil;
		}
	}];
}

@end
