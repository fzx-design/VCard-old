//
//  PostViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-30.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "PostViewController.h"
#import "UIApplicationAddition.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "WeiboClient.h"
#import "Status.h"
#import "User.h"

@implementation PostViewController

@synthesize titleLabel = _titleLabel;
@synthesize wordsCountLabel = _wordsCountLabel;
@synthesize cancelButton = _cancelButton;
@synthesize doneButton = _doneButton;
@synthesize referButton = _referButton;
@synthesize topicButton = _topicButton;
@synthesize camaraButton = _camaraButton;
@synthesize textView = _textView;
@synthesize postDoneImage = _postDoneImage;
@synthesize rightView = _rightView;
@synthesize rightImageView = _rightImageView;
@synthesize pc = _pc;
@synthesize targetStatus = _targetStatus;

- (void)dealloc
{
    NSLog(@"PostViewController dealloc");
    
    [_titleLabel release];
    [_wordsCountLabel release];
    [_cancelButton release];
    [_doneButton release];
    [_referButton release];
    [_topicButton release];
    [_camaraButton release];
    [_textView release];
    [_rightView release];
    [_rightImageView release];
    [_pc release];
    [_targetStatus release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.titleLabel = nil;
    self.wordsCountLabel = nil;
    self.cancelButton = nil;
    self.doneButton = nil;
    self.referButton = nil;
    self.topicButton = nil;
    self.camaraButton = nil;
    self.textView = nil;
    self.rightView = nil;
    self.rightImageView = nil;
}

- (id)initWithType:(PostViewType)type
{
    self = [super init];
    _type = type;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.text = nil;
    [self.textView becomeFirstResponder];
    
    if (_type == PostViewTypeRepost) {
        [self.camaraButton removeFromSuperview];
        self.titleLabel.text = NSLocalizedString(@"转发微博", nil);
        self.camaraButton = nil;
        
        if (self.targetStatus.repostStatus) {
			self.textView.text = [NSString stringWithFormat:NSLocalizedString(@" //@%@:%@", nil), 
                                  self.targetStatus.author.screenName,
                                  self.targetStatus.text];
		}
		else {
			self.textView.text = NSLocalizedString(@"转发微博。", nil);
		}
		NSRange range;
		range.location = 0;
		range.length = 0;
		self.textView.selectedRange = range;
    }
    
    self.textView.delegate = self;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = self.textView.text;
//    int leng = [text length];
    int bytes = [text lengthOfBytesUsingEncoding:NSUTF16StringEncoding];
    const char *ptr = [text cStringUsingEncoding:NSUTF16StringEncoding];
    int words = 0;
    for (int i = 0; i < bytes; i++) {
        if (*ptr) {
            words++;
        }
        ptr++;
    }
    words += 1;
    words /= 2;
    words = 140 - words;
    self.wordsCountLabel.text = [NSString stringWithFormat:@"%d", words];
    self.doneButton.enabled = words >= 0;
    
}

- (IBAction)cancelButtonClicked:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self 
													cancelButtonTitle:nil 
											   destructiveButtonTitle:NSLocalizedString(@"取消" , nil)
													otherButtonTitles:nil];
	[actionSheet showFromRect:sender.bounds inView:sender animated:YES];
	[actionSheet release];
}

- (void)dismissView
{
	if (self.rightView.superview) {
		[self.rightView removeFromSuperview];
	}
	[self.textView resignFirstResponder];
    [[UIApplication sharedApplication] dismissModalViewController];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self dismissView];
	}
}

- (IBAction)doneButtonClicked:(id)sender {
    NSString *status = self.textView.text;
    
	if (!status.length) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"错误", nil)
                                                         message:NSLocalizedString(@"微博内容不能为空", nil)
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                               otherButtonTitles:nil];
		[alert show];
        [alert release];
		return;
	}
	
    
	WeiboClient *client = [WeiboClient client];
	
	[[UIApplication sharedApplication] showLoadingView];
    [client setCompletionBlock:^(WeiboClient *client) {
		[[UIApplication sharedApplication] hideLoadingView];
        if (!client.hasError) {
			
			self.postDoneImage.alpha = 1.0;
			[UIView animateWithDuration:1.0 delay:1.0 options:0 animations:^{
				self.postDoneImage.alpha = 0.0;
			} completion:^(BOOL finished) {
				[self dismissView];
			}];
			
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                            message:NSLocalizedString(@"发表成功", nil)
//                                                           delegate:nil
//                                                  cancelButtonTitle:NSLocalizedString(@"确定", nil)
//                                                  otherButtonTitles:nil];
//            [alert show];
//            [alert release];
        } else {
			[ErrorNotification showPostError];
		}
    }];
    
    if (_type == PostViewTypeRepost) {
        [client repost:self.targetStatus.statusID 
                  text:status 
         commentStatus:NO 
         commentOrigin:NO];
    }
    else {
        if (self.rightImageView.image) {
            [client post:status withImage:self.rightImageView.image];
        }
        else {
            [client post:status];
        }
    }
    
}

- (IBAction)referButtonClicked:(id)sender {
    NSString *text = self.textView.text;
	text = [text stringByAppendingString:@"@"];
	self.textView.text = text;
}

- (IBAction)topicButtonClicked:(id)sender {
    NSString *text = self.textView.text;
	text = [text stringByAppendingString:@"##"];
	self.textView.text = text;
	int length = text.length;
	NSRange range;
	range.location = length-1;
	range.length = 0;
	self.textView.selectedRange = range;
}

- (IBAction)camaraButtonClicked:(id)sender {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	ipc.delegate = self;
	ipc.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    
	_pc = [[UIPopoverController alloc] initWithContentViewController:ipc];
	[ipc release];
	
	self.pc.delegate = self;
	
	[self.textView resignFirstResponder];
	[self.pc presentPopoverFromRect:self.camaraButton.bounds inView:self.camaraButton
            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)removeImageButtonClicked:(id)sender {
    self.camaraButton.hidden = NO;
	[UIView animateWithDuration:1.0 animations:^{
		self.rightView.alpha = 0.0;
	} completion:^(BOOL fin) {
		if (fin) {
            [self.rightView removeFromSuperview];
        }
	}];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.pc = nil;
	[self.textView becomeFirstResponder];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
	[self.pc dismissPopoverAnimated:YES];
	self.pc = nil;
	
    CGRect frame = self.rightView.frame;
    frame.origin = CGPointMake(737, 42);
    self.rightView.frame = frame;
    
    self.rightImageView.image = img;
    self.rightView.alpha = 0;
    
    self.camaraButton.hidden = YES;
    
	UIView *superView = [self.view superview];
	[superView addSubview:self.rightView];
	[UIView animateWithDuration:1.0 animations:^{
		self.rightView.alpha = 1.0;
	}];
}

@end
