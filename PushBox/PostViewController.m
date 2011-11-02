//
//  PostViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-30.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "PostViewController.h"
#import "UIApplicationAddition.h"
#import "PushBoxAppDelegate.h"
#import "AnimationProvider.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "WeiboClient.h"
#import "Status.h"
#import "User.h"
#import "AnimationProvider.h"

@implementation PostViewController

@synthesize titleLabel = _titleLabel;
@synthesize wordsCountLabel = _wordsCountLabel;
@synthesize cancelButton = _cancelButton;
@synthesize doneButton = _doneButton;
@synthesize referButton = _referButton;
@synthesize topicButton = _topicButton;
@synthesize camaraButton = _camaraButton;
@synthesize textView = _textView;
@synthesize postingRoundImageView = _postingRoundImageView;
@synthesize postingCircleImageView = _postingCircleImageView;
@synthesize rightView = _rightView;
@synthesize rightImageView = _rightImageView;
@synthesize pc = _pc;
@synthesize targetStatus = _targetStatus;
@synthesize atView = _atView;
@synthesize atScreenNames = _atScreenNames;
@synthesize atTableView = _atTableView;
@synthesize atTextField = _atTextField;

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
    [_atView release];
    [_pc release];
    [_atScreenNames release];
    [_targetStatus release];
	[_postingCircleImageView release];
	[_postingRoundImageView release];
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
    self.atView = nil;
    self.rightImageView = nil;
	self.postingCircleImageView = nil;
	self.postingRoundImageView = nil;
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
	
	[self textViewDidChange:self.textView];
	
	self.rightView.layer.anchorPoint = CGPointMake(0, 0.4);
	self.atView.layer.anchorPoint = CGPointMake(0.5, 0);
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
    
    //
    if (_lastChar && [_lastChar compare:@"@"] == NSOrderedSame) {
        [self atButtonClicked:nil];
    }
}

- (IBAction)atButtonClicked:(id)sender {
    UIView *superView = [self.view superview];
    
    if (!_atBgButton)
        _atBgButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)];
    
    [_atBgButton addTarget:self action:@selector(dismissAtView) forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:_atBgButton];
    
	[superView addSubview:self.atView];
    CGRect frame = self.atView.frame;
    frame.origin = CGPointMake(200, 105);
    self.atView.frame = frame;
    
	[self.atView.layer addAnimation:[AnimationProvider popoverAnimation] forKey:nil];
	
    self.atTextField.text = @"";
    [self.atTextField becomeFirstResponder];
    
	[UIView animateWithDuration:1.0 animations:^{
		self.atView.alpha = 1.0;
	}];
    
    [self atTextFieldEditingBegan];
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
	if (self.atView.superview) {
		[self.atView removeFromSuperview];
	}
	[self.textView resignFirstResponder];
    [[UIApplication sharedApplication] dismissModalViewController];
}

- (void)dismissAtView
{
	if (self.atView.superview) {
		[UIView animateWithDuration:0.3 
						 animations:^(){
			self.atView.alpha = 0.0;
		} 
						 completion:^(BOOL finished) {
			[self.atView removeFromSuperview];
			self.atView.alpha = 1.0;
		}];
	}
    
    [_atBgButton removeFromSuperview];
    
	[self.textView becomeFirstResponder];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self dismissView];
	}
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

- (void)configureAtScreenNamesArray:(NSString*)text
{    
    if (self.atScreenNames) {
        [self.atScreenNames removeAllObjects];
    }
    else {
        self.atScreenNames = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    }
    
    // init
    if ([text compare:@"init"] == NSOrderedSame) {
        [self.atScreenNames addObject:[[[NSString alloc] initWithFormat:@"@"] autorelease]];
    }
    
    // text
    else {        
        // TODO
        [self.atScreenNames insertObject:[[[NSString alloc] initWithFormat:@"@%@", text] autorelease] atIndex:0];
        
        NSManagedObjectContext* context = [(PushBoxAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription                                                  entityForName:@"User" inManagedObjectContext:context];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entityDescription];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[[[NSString alloc] initWithFormat:@"screenName like[c] \"*%@*\"", text] autorelease]];
        [request setPredicate:predicate];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]                                                                      initWithKey:@"screenName" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [sortDescriptor release];
        NSError *error;
        NSArray *array = [context executeFetchRequest:request error:&error];
        
        for (int i = 0; i < [array count]; i++) {
            [self.atScreenNames addObject:[[[NSString alloc] initWithFormat:@"@%@", [[array objectAtIndex:i] screenName]] autorelease]];
        }
    }
}


- (Boolean)isAtEndChar:(unichar)c
{
    NSArray* atEndCharArray = [[[NSArray alloc] initWithObjects:
                               [[[NSNumber alloc] initWithInt:44] autorelease],   // ' '
                               [[[NSNumber alloc] initWithInt:46] autorelease],   // ' '
                               [[[NSNumber alloc] initWithInt:32] autorelease],   // ' '
                               [[[NSNumber alloc] initWithInt:64] autorelease],   // '@'
                               [[[NSNumber alloc] initWithInt:58] autorelease],   // ':'
                               [[[NSNumber alloc] initWithInt:59] autorelease],   // ';'
                               [[[NSNumber alloc] initWithInt:35] autorelease],   // '#'
                               [[[NSNumber alloc] initWithInt:39] autorelease],   // '''
                               [[[NSNumber alloc] initWithInt:34] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:40] autorelease],   // '('
                               [[[NSNumber alloc] initWithInt:41] autorelease],   // ')'
                               [[[NSNumber alloc] initWithInt:91] autorelease],   // '['
                               [[[NSNumber alloc] initWithInt:93] autorelease],   // ']'
                               [[[NSNumber alloc] initWithInt:123] autorelease],   // '{'
                               [[[NSNumber alloc] initWithInt:125] autorelease],   // '}'
                               [[[NSNumber alloc] initWithInt:126] autorelease],   // '~'
                               [[[NSNumber alloc] initWithInt:33] autorelease],   // '!'
                               [[[NSNumber alloc] initWithInt:36] autorelease],   // '$'
                               [[[NSNumber alloc] initWithInt:37] autorelease],   // '%'
                               [[[NSNumber alloc] initWithInt:94] autorelease],   // '^'
                               [[[NSNumber alloc] initWithInt:38] autorelease],   // '&'
                               [[[NSNumber alloc] initWithInt:42] autorelease],   // '*'
                               [[[NSNumber alloc] initWithInt:43] autorelease],   // '+'
                               [[[NSNumber alloc] initWithInt:61] autorelease],   // '='
                               [[[NSNumber alloc] initWithInt:124] autorelease],   // '|'
                               [[[NSNumber alloc] initWithInt:60] autorelease],   // '<'
                               [[[NSNumber alloc] initWithInt:62] autorelease],   // '>'
                               [[[NSNumber alloc] initWithInt:92] autorelease],   // '\'
                               [[[NSNumber alloc] initWithInt:47] autorelease],   // '/'
                               [[[NSNumber alloc] initWithInt:63] autorelease],   // '?'
                               [[[NSNumber alloc] initWithInt:65306] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65307] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:8216] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:8217] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:8220] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:8221] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65288] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65289] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65339] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:12290] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65341] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65292] autorelease],   // '，'
                               [[[NSNumber alloc] initWithInt:12289] autorelease],   // '、'
                               [[[NSNumber alloc] initWithInt:65371] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65373] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65374] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65281] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65283] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65509] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65285] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:8212] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65290] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65291] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65309] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65372] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:12298] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65295] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:65311] autorelease],   // '"'
                               [[[NSNumber alloc] initWithInt:8230] autorelease],   // '"'
                               nil] autorelease];
    for (int i = 0; i < [atEndCharArray count]; i++)
    {
        if (c == [[atEndCharArray objectAtIndex:i] intValue])
            return YES;
    }
    
    return NO;
}

- (BOOL)isAtStringValid:(NSString*)str {
    for (int i = 0; i < [str length]; i++) {
        if ([self isAtEndChar:[str characterAtIndex:i]]) {
            return NO;
        }
    }
    return YES;
}

- (IBAction)atTextFieldEditingChanged:(UITextField*)textField {
    
    if ([self isAtStringValid:textField.text]) {
        [self configureAtScreenNamesArray:textField.text];
        [self.atTableView reloadData];
    }
    else {
        if (self.atScreenNames) {
            [self.atScreenNames removeAllObjects];
        }
        self.atScreenNames = [[[NSMutableArray alloc] initWithObjects:[[[NSString alloc] initWithFormat:@"@%@", textField.text] autorelease], nil] autorelease];
        [self.atTableView reloadData];
    }
}

- (IBAction)atTextFieldEditingEnd {
    [self dismissAtView];
}

- (IBAction)atTextFieldEditingBegan {
    
    [self configureAtScreenNamesArray:self.atTextField.text];
    [self.atTableView reloadData];
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
	[UIView animateWithDuration:0.3 animations:^{
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
	self.rightView.alpha = 1.0;
	[self.rightView.layer addAnimation:[AnimationProvider popoverAnimation] forKey:nil];
	
	[self.textView becomeFirstResponder];
//	[UIView animateWithDuration:1.0 animations:^{
//		self.rightView.alpha = 1.0;
//	}];
}

#pragma - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.atScreenNames count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = @"PostViewAtTableViewCell";
    PostViewAtTableViewCell *cell = (PostViewAtTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostViewAtTableViewCell" owner:self options:nil];
        cell = [nib lastObject];
    }
    
    cell.screenNameLabel.text = [_atScreenNames objectAtIndex:[indexPath row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.textView.text = [self.textView.text stringByAppendingString:([[[self.atScreenNames objectAtIndex:[indexPath row]] substringFromIndex:1] stringByAppendingString:@" "])];
    [self dismissAtView];
}

#pragma - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.textView.text = [self.textView.text stringByAppendingString:([[[self.atScreenNames objectAtIndex:0] substringFromIndex:1] stringByAppendingString:@" "])];
    [self dismissAtView];
    
    return NO;
}

#pragma - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    _lastChar = text;
    return YES;
}

@end
