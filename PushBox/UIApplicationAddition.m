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

static UIImageView *_loadingImageView;
static UIActivityIndicatorView *_loadingActivityIndicator;

static UIViewController *_modalViewController;
static UIView *_backView;

@implementation UIApplication (UIApplication_RootView)
//
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
//{
//    PushBoxAppDelegate *appDelegate = (PushBoxAppDelegate *)[[UIApplication sharedApplication] delegate];
//    return appDelegate.persistentStoreCoordinator;
//}

- (UIView *)rootView
{
    return [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
}

- (UIViewController *)rootViewController
{
    PushBoxAppDelegate *appDelegate = (PushBoxAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.rootViewController;
}

- (void)showLoadingView
{
    if (!_loadingImageView) {
        _loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"root_loading_bg"]];
        _loadingImageView.center = CGPointMake(512.0, 345.0);
    }
    
    if (!_loadingActivityIndicator) {
        _loadingActivityIndicator = [[UIActivityIndicatorView alloc] 
                                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loadingActivityIndicator.hidesWhenStopped = YES;
        _loadingActivityIndicator.center = CGPointMake(512.0, 332.0);
    }
    
    [[self rootView] addSubview:_loadingImageView];
	[[self rootView] addSubview:_loadingActivityIndicator];
	[_loadingActivityIndicator startAnimating];
	
}

- (void)hideLoadingView
{
    [_loadingActivityIndicator stopAnimating];
    [_loadingImageView removeFromSuperview];
    [_loadingActivityIndicator removeFromSuperview];
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
