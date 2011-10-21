//
//  PostViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-30.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorNotification.h"

typedef enum {
    PostViewTypePost,
    PostViewTypeRepost,
} PostViewType;

@class Status;

@interface PostViewController : UIViewController<UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate> {
    UILabel *_titleLabel;
    UILabel *_wordsCountLabel;
    UIButton *_cancelButton;
    UIButton *_doneButton;
    UIButton *_referButton;
    UIButton *_topicButton;
    UIButton *_camaraButton;
    UITextView *_textView;
    UIImageView *_postDoneImage;
	
    UIView *_rightView;
    UIImageView *_rightImageView;
    
    UIPopoverController *_pc;
    
    PostViewType _type;
    
    Status* _targetStatus;
}

@property(nonatomic, retain) IBOutlet UILabel* titleLabel;
@property(nonatomic, retain) IBOutlet UILabel* wordsCountLabel;
@property(nonatomic, retain) IBOutlet UIButton* cancelButton;
@property(nonatomic, retain) IBOutlet UIButton* doneButton;
@property(nonatomic, retain) IBOutlet UIButton* referButton;
@property(nonatomic, retain) IBOutlet UIButton* topicButton;
@property(nonatomic, retain) IBOutlet UIButton* camaraButton;
@property(nonatomic, retain) IBOutlet UITextView* textView;
@property(nonatomic, retain) IBOutlet UIView* rightView;
@property(nonatomic, retain) IBOutlet UIImageView* postDoneImage;
@property(nonatomic, retain) IBOutlet UIImageView* rightImageView;
@property(nonatomic, retain) UIPopoverController* pc;
@property(nonatomic, retain) Status *targetStatus;

- (id)initWithType:(PostViewType)type;

- (IBAction)cancelButtonClicked:(UIButton *)sender;
- (IBAction)doneButtonClicked:(id)sender;
- (IBAction)referButtonClicked:(id)sender;
- (IBAction)topicButtonClicked:(id)sender;
- (IBAction)camaraButtonClicked:(id)sender;
- (IBAction)removeImageButtonClicked:(id)sender;


@end
