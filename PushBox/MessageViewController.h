//
//  MessageViewController.h
//  PushBox
//
//  Created by Ren Kelvin on 10/10/11.
//  Copyright 2011 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIApplicationAddition.h"

@interface MessageViewController : UIViewController<UIActionSheetDelegate, UIAlertViewDelegate> 

- (IBAction)cancelButtonClicked:(UIButton *)sender;
- (IBAction)sendButtonClicked:(UIButton *)sender;

@property (nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *lastUpdateLabel;
@property (nonatomic, retain) IBOutlet UILabel *countLabel;
@property (nonatomic, retain) IBOutlet UITextView *textView;

@end
