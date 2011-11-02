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

- (IBAction)feedback:(UIButton *)sender
{
    MFMailComposeViewController *picker = nil;
    picker = [[MFMailComposeViewController alloc] init];
    if (!picker) {
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"未设置邮件帐户", nil)
        //                                                        message:NSLocalizedString(@"可以在Mail中添加您的邮件帐户", nil)
        //                                                       delegate:self
        //                                              cancelButtonTitle:NSLocalizedString(@"好", nil)
        //                                              otherButtonTitles:nil];
        //        [alert show];
        //        [alert release];
    }
    else {
        picker.mailComposeDelegate = self;
        picker.modalPresentationStyle = UIModalPresentationPageSheet;
        
        NSString *subject = [NSString stringWithFormat:@"VCard HD 新浪微博用户反馈"];
        
        NSString *receiver = [NSString stringWithFormat:@"evanfun.work@gmail.com"];
        [picker setToRecipients:[NSArray arrayWithObject:receiver]];
        
        [picker setSubject:subject];
        NSString *emailBody = [NSString stringWithFormat:@"反馈类型（功能建议 / 程序漏洞）：\n\n描述："];
        [picker setMessageBody:emailBody isHTML:NO];
        
        [[[UIApplication sharedApplication] rootViewController] presentModalViewController:picker animated:YES];
        [picker release];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error
{
    NSString *message = nil;
    switch (result)
    {
        case MFMailComposeResultSaved: {
            message = NSLocalizedString(@"保存成功", nil);
            [[[UIApplication sharedApplication] rootViewController] dismissModalViewControllerAnimated:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message 
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            break;
        }
        case MFMailComposeResultSent: {
            message = NSLocalizedString(@"发送成功", nil);
            [[[UIApplication sharedApplication] rootViewController] dismissModalViewControllerAnimated:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message 
                                                                message:NSLocalizedString(@"感谢您的反馈，我们会阅读所有内容，但不会回复每一封邮件", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            break;
        }
        case MFMailComposeResultFailed: {
            message = NSLocalizedString(@"发送失败", nil);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message 
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            break;
        }
        default: {
            [[[UIApplication sharedApplication] rootViewController] dismissModalViewControllerAnimated:YES];
            return;
        }
    }
}

@end
