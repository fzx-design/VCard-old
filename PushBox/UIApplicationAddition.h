//
//  UIApplicationAddition.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-26.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kModalViewHeight 25

@interface UIApplication(UIApplicationAddition)

//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

- (UIView *)rootView;
- (UIViewController *)rootViewController;

- (void)showLoadingView;
- (void)hideLoadingView;

- (void)presentModalViewController:(UIViewController *)vc atHeight:(CGFloat)height;
- (void)dismissModalViewController;

@end
