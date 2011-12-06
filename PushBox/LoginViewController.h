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
- (void)loginViewControllerDidLogin:(UIViewController *)vc shouldClearData:(BOOL)differentUser;
@end

@interface LoginViewController : UIViewController<UITextFieldDelegate> {
    UITextField *_usernameTextField;
    UITextField *_passwordTextField;
    UISwitch *_autoSaveSwitch;
    UILabel *_providerLabel;
	
	UIButton *_autoSaveButton;
    UIButton *_confirmButton;
	
	UIActivityIndicatorView *_loadingIndicator;

    id<LoginViewControllerDelegate> _delegate;    
}

@property(nonatomic, retain) IBOutlet UITextField* usernameTextField;
@property(nonatomic, retain) IBOutlet UITextField* passwordTextField;
@property(nonatomic, retain) IBOutlet UILabel* providerLabel;
@property(nonatomic, retain) IBOutlet UIButton* autoSaveButton;
@property(nonatomic, retain) IBOutlet UIButton* confirmButton;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView* loadingIndicator;
@property(nonatomic, assign) id<LoginViewControllerDelegate> delegate;

- (IBAction)openRegisterURL:(id)sender;
- (IBAction)autoSaveSwitchChanged:(id)sender;
- (IBAction)login:(id)sender;



@end
