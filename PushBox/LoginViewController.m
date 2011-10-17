//
//  LoginViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-25.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "LoginViewController.h"
#import "WeiboClient.h"

#define kUserDefaultKeyAutoSave @"kUserDefaultKeyAutoSave"
#define kUserDefaultName @"kUserDefaultName"

@implementation LoginViewController

@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize autoSaveSwitch = _autoSaveSwitch;
@synthesize autoSaveButton = _autoSaveButton;
@synthesize providerLabel = _providerLabel;
@synthesize delegate = _delegate;

#pragma mark - View lifecycle

+ (void)initialize
{
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:kUserDefaultKeyAutoSave];
	[userDefault registerDefaults:dict];
}

- (void)dealloc
{
    NSLog(@"LoginViewController dealloc");
    [_usernameTextField release];
    [_passwordTextField release];
    [_autoSaveSwitch release];
	[_autoSaveButton release];
    [_providerLabel release];
    _delegate = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.providerLabel.text = NSLocalizedString(@"新浪微博", nil);
	BOOL autoSave = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultKeyAutoSave];
	self.autoSaveButton.selected = autoSave;
//	self.autoSaveSwitch.on = autoSave;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.usernameTextField = nil;
    self.passwordTextField = nil;
//	self.autoSaveSwitch = nil;
    self.autoSaveButton = nil;
	self.providerLabel = nil;
}

- (IBAction)login:(id)sender {
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;

    WeiboClient *client = [WeiboClient client];
    
    [client setCompletionBlock:^(WeiboClient *client) {
        if (client.hasError || ![WeiboClient authorized]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"验证失败", nil)
                                                            message:NSLocalizedString(@"请检查用户名或网络设置", nil)
                                                            delegate:nil 
                                                  cancelButtonTitle:NSLocalizedString(@"关闭", nil)
                                                   otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else {
            [self.passwordTextField resignFirstResponder];
            [self.usernameTextField resignFirstResponder];
            [self.delegate loginViewControllerDidLogin:self];
        }
    }];
    
//    [client authWithUsername:username password:password autosave:self.autoSaveSwitch.on];
	[client authWithUsername:username password:password autosave:self.autoSaveButton.selected];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.usernameTextField) {
		[self.passwordTextField becomeFirstResponder];
	}
	else {
		[self login:nil];
	}
	return YES;
}


- (IBAction)openRegisterURL:(id)sender {
    NSString *urlString = @"http://t.sina.com.cn/reg.php?ps=u3&lang=zh";
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (IBAction)autoSaveSwitchChanged:(id)sender {
//    BOOL on = self.autoSaveSwitch.on;
	BOOL on = !self.autoSaveButton.selected;
	self.autoSaveButton.selected = on;
	[[NSUserDefaults standardUserDefaults] setBool:on forKey:kUserDefaultKeyAutoSave];
}


@end
