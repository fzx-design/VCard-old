//
//  CommentViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-8-1.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorNotification.h"

@class Status;
@class Comment;

@protocol CommentseViewDelegates
- (void)commentFinished;
@end

@interface CommentViewController : UIViewController<UIActionSheetDelegate, UIAlertViewDelegate> {
    UITextView *_textView;
    UILabel *_titleLabel;
	UIImageView *_postingCircleImageView;
	UIImageView *_postingRoundImageView;
	UIButton *_repostButton;
	
    Status *_targetStatus;
    Comment *_targetComment;
	
	id<CommentseViewDelegates> _delegate;
	
	BOOL _repostFlag;
}

@property(nonatomic, retain) IBOutlet UITextView* textView;
@property(nonatomic, retain) IBOutlet UILabel* titleLabel;

@property(nonatomic, retain) IBOutlet UIImageView* postingCircleImageView;
@property(nonatomic, retain) IBOutlet UIImageView* postingRoundImageView;
@property(nonatomic, retain) IBOutlet UIButton* repostButton;

@property(nonatomic, retain) Status* targetStatus;
@property(nonatomic, retain) Comment* targetComment;

@property(nonatomic, assign) id delegate;

- (IBAction)doneButtonClicked:(UIButton *)sender;
- (IBAction)backButtonClicked:(UIButton *)sender;


@end
