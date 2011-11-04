//
//  CommentViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-8-1.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorNotification.h"
#import "RCSwitchClone.h"

@class Status;
@class Comment;

@protocol CommentseViewDelegates
- (void)commentFinished;
@end

@interface CommentViewController : UIViewController<UITextViewDelegate,UIActionSheetDelegate, UIAlertViewDelegate, SwitchValueChanged> {
    UITextView *_textView;
    UILabel *_titleLabel;
	UILabel *_wordsCountLabel;
	UIImageView *_postingCircleImageView;
	UIImageView *_postingRoundImageView;
	UIButton *_repostButton;
	UIButton *_doneButton;
	
	RCSwitchClone *_repostSwitchView;
	
    UIView *_atView;
    UITableView *_atTableView;
    UITextField *_atTextField;
 
    UIButton* _atBgButton;
    
    NSMutableArray *_atScreenNames;

    Status *_targetStatus;
    Comment *_targetComment;
	
	id<CommentseViewDelegates> _delegate;
	
	BOOL _repostFlag;

    int textViewWordsCount;
    
    NSString* _lastChar;
}

@property(nonatomic, retain) IBOutlet UITextView* textView;
@property(nonatomic, retain) IBOutlet UILabel* titleLabel;
@property(nonatomic, retain) IBOutlet UILabel* wordsCountLabel;
@property(nonatomic, retain) IBOutlet UIImageView* postingCircleImageView;
@property(nonatomic, retain) IBOutlet UIImageView* postingRoundImageView;
@property(nonatomic, retain) IBOutlet UIButton* repostButton;
@property(nonatomic, retain) IBOutlet UIButton* doneButton;
@property(nonatomic, retain) IBOutlet UIView* atView;
@property(nonatomic, retain) IBOutlet UITableView* atTableView;
@property(nonatomic, retain) IBOutlet UITextField* atTextField;
@property(nonatomic, retain) NSMutableArray *atScreenNames;

@property(nonatomic, retain) IBOutlet RCSwitchClone* repostSwitchView;


@property(nonatomic, retain) Status* targetStatus;
@property(nonatomic, retain) Comment* targetComment;

@property(nonatomic, assign) id delegate;

- (IBAction)doneButtonClicked:(UIButton *)sender;
- (IBAction)backButtonClicked:(UIButton *)sender;
- (IBAction)atButtonClicked:(id)sender;
@end
