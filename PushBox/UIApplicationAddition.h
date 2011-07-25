//
//  UIApplicationAddition.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-26.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication(UIApplicationAddition)

- (UIView *)rootView;

- (void)showLoadingView;
- (void)hideLoadingView;

- (void)presentModalViewController:(UIViewController *)vc atHeight:(CGFloat)height;
- (void)dismissModalViewController;

@end
