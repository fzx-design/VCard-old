//
//  CommentViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-8-1.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CommentViewController.h"
#import "WeiboClient.h"
#import "UIApplicationAddition.h"
#import "PushBoxAppDelegate.h"
#import "Status.h"
#import "User.h"
#import "Comment.h"

@implementation CommentViewController

@synthesize textView = _textView;
@synthesize titleLabel = _titleLabel;
@synthesize postingRoundImageView = _postingRoundImageView;
@synthesize postingCircleImageView = _postingCircleImageView;
@synthesize targetStatus = _targetStatus;
@synthesize targetComment = _targetComment;


- (void)dealloc
{
    [_textView release];
    [_titleLabel release];
    [_targetStatus release];
    [_targetComment release];
	[_postingRoundImageView release];
	[_postingCircleImageView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.textView = nil;
    self.titleLabel = nil;
	self.postingRoundImageView = nil;
	self.postingCircleImageView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = NSLocalizedString(@"发表评论", nil);
    self.textView.text = @"";
    [self.textView becomeFirstResponder];
    if (self.targetComment) {
        self.textView.text = [NSString stringWithFormat:@"回复@%@:", self.targetComment.author.screenName];
    }
}

- (void)dismissView
{
	[self.textView resignFirstResponder];
    [[UIApplication sharedApplication] dismissModalViewController];
}

- (void)showPostingView
{
	_postingCircleImageView.alpha = 1.0;
	_postingRoundImageView.alpha = 1.0;
	
	CABasicAnimation *rotationAnimation =[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	rotationAnimation.duration = 1.0;
	rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
	rotationAnimation.toValue = [NSNumber numberWithFloat:-2.0 * M_PI];
	rotationAnimation.repeatCount = 65535;
	[_postingCircleImageView.layer addAnimation:rotationAnimation forKey:@"kAnimationLoad"];
}

- (void)hidePostingView
{
	[UIView animateWithDuration:1.0 animations:^{
		_postingRoundImageView.alpha = 0.0;
		_postingCircleImageView.alpha = 0.0;
    } completion:^(BOOL finished) {
		[_postingCircleImageView.layer removeAnimationForKey:@"kAnimationLoad"];
	}];
}

- (IBAction)doneButtonClicked:(UIButton *)sender {
    NSString *comment = self.textView.text;

	WeiboClient *client = [WeiboClient client];
	
	[self showPostingView];
    [client setCompletionBlock:^(WeiboClient *client) {
		[self hidePostingView];
        if (!client.hasError) {
			[self dismissView];
			[[UIApplication sharedApplication] showOperationDoneView];
        } else {
			[ErrorNotification showPostError];
		}
    }];
    
    [client comment:self.targetStatus.statusID cid:self.targetComment.commentID text:comment commentOrigin:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self dismissView];
}

- (IBAction)backButtonClicked:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self 
													cancelButtonTitle:nil 
											   destructiveButtonTitle:NSLocalizedString(@"取消", nil)
													otherButtonTitles:nil];
	[actionSheet showFromRect:sender.bounds inView:sender animated:YES];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		[self dismissView];
	}
}
@end
