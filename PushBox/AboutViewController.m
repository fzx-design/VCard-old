    //
//  AboutViewController.m
//  VCard HD
//
//  Created by Hasky on 11-3-1.
//  Copyright 2011 同济大学. All rights reserved.
//

#import "AboutViewController.h"
#import "WeiboClient.h"
#import "PostViewController.h"
#import "UIApplicationAddition.h"

@implementation AboutViewController

@synthesize followButton = _followButton;

- (void)dealloc
{
    NSLog(@"AboutViewController dealloc");
	[_followButton release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"关于", nil);
	WeiboClient *client = [WeiboClient client];
    
    [client setCompletionBlock:^(WeiboClient *client) {
        NSDictionary *dict = client.responseJSONObject;
        dict = [dict objectForKey:@"target"];
        
        BOOL followedByMe = [[dict objectForKey:@"followed_by"] boolValue];
        
        if (followedByMe) {
            self.followButton.enabled = NO;
        }
        else {
            self.followButton.enabled = YES;
        }
    }];
    
    [client getRelationshipWithUser:@"2478499604"];
}

- (IBAction)rate:(UIButton *)sender
{
	NSString *urlString = @"http://itunes.apple.com/cn/app/id420598288?mt=8";
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (IBAction)followAuthor:(UIButton *)sender
{
    WeiboClient *client = [WeiboClient client];
    [client setCompletionBlock:^(WeiboClient *client){
        if (!client.hasError) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"完成", nil) 
															message:NSLocalizedString(@"您可以在 VCard 官方微博中找到使用窍门和最新信息。", nil)
														   delegate:nil
												  cancelButtonTitle:NSLocalizedString(@"好", nil)
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
        } else {
			[ErrorNotification showLoadingError];
		}
    }];
    [client follow:@"2478499604"];
}

- (IBAction)tellFriends:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldDismissPopoverView object:self];
    
	PostViewController *vc = [[PostViewController alloc] initWithType:PostViewTypePost];
    [[UIApplication sharedApplication] presentModalViewController:vc atHeight:kModalViewHeight];
	vc.textView.text = @"我正在用 @VCard微博（创新而精美的新浪微博 iPad 客户端），下载地址http://itunes.apple.com/cn/app/id420598288?mt=8";
	[vc release];
}

- (IBAction)otherApps:(UIButton *)sender
{
	NSString *urlString = @"http://itunes.apple.com/cn/artist/mondev-tongji-u/id420593934";
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

@end
