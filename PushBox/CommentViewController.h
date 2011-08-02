//
//  CommentViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-8-1.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Status;
@class Comment;

@interface CommentViewController : UIViewController<UIActionSheetDelegate, UIAlertViewDelegate> {
    UITextView *_textView;
    UILabel *_titleLabel;
    
    Status *_targetStatus;
    Comment *_targetComment;
}

@property(nonatomic, retain) IBOutlet UITextView* textView;
@property(nonatomic, retain) IBOutlet UILabel* titleLabel;
@property(nonatomic, retain) Status* targetStatus;
@property(nonatomic, retain) Comment* targetComment;

- (IBAction)doneButtonClicked:(UIButton *)sender;
- (IBAction)backButtonClicked:(UIButton *)sender;


@end
