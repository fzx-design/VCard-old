//
//  ErrorNotification.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-18.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "ErrorNotification.h"

@implementation ErrorNotification

+ (void)showLoadingError
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"离线模式", nil)
													message:NSLocalizedString(@"要获取最新消息，请检查网络设置并刷新", nil)
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"好", nil)
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

+ (void)showPostError
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"发布失败", nil)
													message:NSLocalizedString(@"请检查网络设置并刷新", nil)
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"取消", nil)
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

@end
