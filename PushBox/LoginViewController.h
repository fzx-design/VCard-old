//
//  LoginViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-25.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate
@required
- (void)loginViewControllerDidLogin:(UIViewController *)vc;
@end

@interface LoginViewController : UIViewController<UITextFieldDelegate> {
    UITextField *_usernameTextField;
    UITextField *_passwordTextField;
    UISwitch *_autoSaveSwitch;
    UILabel *_providerLabel;

    id<LoginViewControllerDelegate> _delegate;    
}

@property(nonatomic, retain) IBOutlet UITextField* usernameTextField;
@property(nonatomic, retain) IBOutlet UITextField* passwordTextField;
@property(nonatomic, retain) IBOutlet UISwitch* autoSaveSwitch;
@property(nonatomic, retain) IBOutlet UILabel* providerLabel;
@property(nonatomic, assign) id<LoginViewControllerDelegate> delegate;

- (IBAction)openRegisterURL:(id)sender;
- (IBAction)autoSaveSwitchChanged:(id)sender;
- (IBAction)login:(id)sender;

@end
