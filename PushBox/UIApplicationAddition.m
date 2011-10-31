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

#define kAnimationRefresh @"kAnimationRefresh"
#define kAnimationLoad @"kAnimationLoad"

static NSTimer *_timer;
static UIImageView *_loadingImageView;
static UIImageView *_loadingCircleImageView;
static UIImageView *_loadingRoundImageView;

static UIImageView *_refreshCircleImageView;
static UIImageView *_refreshRoundImageView;

static UIImageView *_operationDoneImageView;

static UIViewController *_modalViewController;
static UIView *_backView;

static CGFloat refreshTime;
static BOOL refreshFlag = NO;

@implementation UIApplication (UIApplication_RootView)
//
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
//{
//    PushBoxAppDelegate *appDelegate = (PushBoxAppDelegate *)[[UIApplication sharedApplication] delegate];
//    return appDelegate.persistentStoreCoordinator;
//}

- (BOOL)waitingForRefreshing
{
	return !refreshFlag;
}

- (UIView *)rootView
{
    return [[self rootViewController] view];
}

- (UIViewController *)rootViewController
{
    PushBoxAppDelegate *appDelegate = (PushBoxAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.rootViewController;
}

- (void)hideRefreshView
{
	refreshFlag = NO;
	refreshTime = 0;
    
	[UIView animateWithDuration:1.0 animations:^{
		_refreshCircleImageView.alpha = 0.0;
		_refreshRoundImageView.alpha = 0.0;
    } completion:nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameEnableRefresh
														object:nil];
}

- (void)calculateRefreshTime
{
	if (!refreshFlag) {
		return;
	}
	
	refreshTime += 1;
	if (refreshTime >= 5) {
		[self hideRefreshView];
	}
}

- (void)showLoadingView
{
    if (!_loadingImageView) {
        _loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"root_loading_bg"]];
        _loadingImageView.center = CGPointMake(512.0, 345.0);
    }
	if (!_loadingRoundImageView) {
        _loadingRoundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refreshing_bg.png"]];
        _loadingRoundImageView.center = CGPointMake(512.0, 338.0);
    }
	
    if (!_loadingCircleImageView) {
        _loadingCircleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_circle.png"]];
        _loadingCircleImageView.center = CGPointMake(512.0, 338.0);
    }
	
	_loadingImageView.alpha = 1.0;
	_loadingRoundImageView.alpha = 1.0;
	_loadingCircleImageView.alpha = 1.0;
	
	[[self rootView] addSubview:_loadingImageView];
	[[self rootView] addSubview:_loadingRoundImageView];
	[[self rootView] addSubview:_loadingCircleImageView];

	CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	rotationAnimation.duration = 1.0;
	rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
	rotationAnimation.toValue = [NSNumber numberWithFloat:-2.0 * M_PI];
	rotationAnimation.repeatCount = 65535;
	[_loadingCircleImageView.layer addAnimation:rotationAnimation forKey:kAnimationLoad];
}


- (void)showRefreshView
{
	refreshFlag = YES;
	
	if (!_refreshRoundImageView) {
        _refreshRoundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refreshing_bg.png"]];
        _refreshRoundImageView.center = CGPointMake(45, 712);
		_refreshRoundImageView.userInteractionEnabled = NO;
		[[self rootView] addSubview:_refreshRoundImageView];
    }
	
	if (!_refreshCircleImageView) {
        _refreshCircleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_circle.png"]];
        _refreshCircleImageView.center = CGPointMake(45.0, 711);
		_refreshCircleImageView.userInteractionEnabled = NO;
		[[self rootView] addSubview:_refreshCircleImageView];
    }

	if (!_timer) {
		_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calculateRefreshTime) userInfo:nil repeats:YES];
	}
    
	_refreshCircleImageView.alpha = 1.0;
	_refreshRoundImageView.alpha = 1.0;
	
	if ([_refreshRoundImageView.layer animationForKey:kAnimationRefresh] == nil) {
		CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
		rotationAnimation.duration = 1.0;
		rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
		rotationAnimation.toValue = [NSNumber numberWithFloat:-2.0 * M_PI];
		rotationAnimation.repeatCount = 65535;
		[_refreshCircleImageView.layer addAnimation:rotationAnimation forKey:kAnimationRefresh];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameDisableRefresh
														object:nil];
}

- (void)showOperationDoneView
{
	_operationDoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_save_done.png"]];_operationDoneImageView.frame = CGRectMake(461, 295, 101, 101);
	[[self rootView] addSubview:_operationDoneImageView];
	[UIView animateWithDuration:2.0 delay:1.0 options:0 animations:^{
		_operationDoneImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[_operationDoneImageView removeFromSuperview];
	}];
}

- (void)hideLoadingView
{
    [UIView animateWithDuration:1.0 animations:^{
		_loadingCircleImageView.alpha = 0.0;
		_loadingRoundImageView.alpha = 0.0;
		_loadingImageView.alpha = 0.0;
    } completion:^(BOOL finished) {
		[_loadingCircleImageView.layer removeAnimationForKey:kAnimationLoad];
		[_loadingCircleImageView removeFromSuperview];
		[_loadingImageView removeFromSuperview];
		[_loadingRoundImageView removeFromSuperview];
	}];
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
