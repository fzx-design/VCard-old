//
//  UIApplicationAddition.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-26.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kModalViewHeight 25
#define kNotificationNameDisableRefresh @"kNotificationNameDisableRefresh"
#define kNotificationNameEnableRefresh @"kNotificationNameEnableRefresh"

@interface UIApplication(UIApplicationAddition)

//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

- (UIView *)rootView;
- (UIViewController *)rootViewController;

- (BOOL)waitingForRefreshing;

- (void)showLoadingView;
- (void)hideLoadingView;

- (void)showRefreshView;
- (void)hideRefreshView;

- (void)showOperationDoneView;

- (void)presentModalViewController:(UIViewController *)vc atHeight:(CGFloat)height;
- (void)dismissModalViewController;

@end
