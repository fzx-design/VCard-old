    //
//  AboutViewController.m
//  PushBox
//
//  Created by Hasky on 11-3-1.
//  Copyright 2011 同济大学. All rights reserved.
//

#import "AboutViewController.h"
#import "WeiboClient.h"

@implementation AboutViewController

- (void)dealloc
{
    NSLog(@"AboutViewController dealloc");
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"关于", nil);
}

- (IBAction)rate:(UIButton *)sender
{
	NSString *urlString = @"http://itunes.apple.com/us/app/id420598288?mt=8";
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (IBAction)followAuthor:(UIButton *)sender
{
    WeiboClient *client1 = [WeiboClient client];
    [client1 setCompletionBlock:^(WeiboClient *client){
        if (!client.hasError) {
            WeiboClient *client2 = [WeiboClient client];
            [client setCompletionBlock:^(WeiboClient *client) {
                if (!client.hasError) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"已关注", nil) 
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                          otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }
            }];
            [client2 follow:@"1607786282"];
        }
    }];
    [client1 follow:@"1751197843"];
}

- (IBAction)tellFriends:(UIButton *)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameTellFriends
														object:self];
	
}

- (IBAction)otherApps:(UIButton *)sender
{
	NSString *urlString = @"http://itunes.apple.com/us/artist/mondev-tongji-u/id420593934";
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

@end
