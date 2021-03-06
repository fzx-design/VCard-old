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
#import "AnimationProvider.h"

#define LabelRedColor [UIColor colorWithRed:143/255.0 green:63/255.0 blue:63/255.0 alpha:1.0]
#define LabelBlackColor [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0]

@implementation CommentViewController

@synthesize textView = _textView;
@synthesize titleLabel = _titleLabel;
@synthesize postingRoundImageView = _postingRoundImageView;
@synthesize postingCircleImageView = _postingCircleImageView;
@synthesize targetStatus = _targetStatus;
@synthesize targetComment = _targetComment;
@synthesize repostButton = _repostButton;
@synthesize doneButton = _doneButton;
@synthesize wordsCountLabel = _wordsCountLabel;
@synthesize delegate = _delegate;
@synthesize atView = _atView;
@synthesize atScreenNames = _atScreenNames;
@synthesize atTableView = _atTableView;
@synthesize atTextField = _atTextField;
@synthesize emotionsView = _emotionsView;
@synthesize alsoRepostLabel = _alsoRepostLabel;
@synthesize repostSwitchView = _repostSwitchView;

- (void)dealloc
{
    [_textView release];
    [_titleLabel release];
    [_targetStatus release];
    [_targetComment release];
	[_repostButton release];
	[_doneButton release];
	[_wordsCountLabel release];
	[_repostSwitchView release];
	[_postingRoundImageView release];
	[_postingCircleImageView release];
    [_atView release];
    [_atScreenNames release];
    [_emotionsView release];
    [_alsoRepostLabel release];
    [_repostSwitchView release];
    [super dealloc];
}

- (void)dismissEmotionsView
{
    if (self.emotionsView.superview) {
        [UIView animateWithDuration:0.3 
                         animations:^(){
                             self.emotionsView.alpha = 0.0;
                         } 
                         completion:^(BOOL finished) {
                             [self.emotionsView removeFromSuperview];
                             self.emotionsView.alpha = 1.0;
                         }];
    }
    
    [_emotionBgButton removeFromSuperview];
    
    [self.textView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.textView = nil;
    self.titleLabel = nil;
	self.repostButton = nil;
	self.doneButton = nil;
	self.wordsCountLabel = nil;
	self.repostSwitchView = nil;
	self.postingRoundImageView = nil;
	self.postingCircleImageView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.repostSwitchView setType:SwitchTypeNormal];
	self.repostSwitchView.delegate = self;
	
    self.titleLabel.text = NSLocalizedString(@"发表评论", nil);
    self.textView.text = @"";
    [self.textView becomeFirstResponder];
    if (self.targetComment) {
        self.textView.text = [NSString stringWithFormat:@"回复@%@:", self.targetComment.author.screenName];
    }
	
	[self textViewDidChange:self.textView];
	
    _emotionsViewController = [[EmotionsViewController alloc] init];
    self.emotionsView = _emotionsViewController.view;
    self.emotionsView.layer.anchorPoint = CGPointMake(0.5, 0);
    _emotionsViewController.delegate = self;

	self.textView.delegate = self;
	self.atView.layer.anchorPoint = CGPointMake(0.5, 0);
}

- (void)dismissView
{
	[self.textView resignFirstResponder];
    [[UIApplication sharedApplication] dismissModalViewController];
}

- (IBAction)emotionsButtonClicked:(id)sender {    
    UIView *superView = [self.view superview];
    
    if (!_emotionBgButton)
        _emotionBgButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)];
    
    [_emotionBgButton addTarget:self action:@selector(dismissEmotionsView) forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:_emotionBgButton];
    
    [superView addSubview:self.emotionsView];
    CGRect frame = self.emotionsView.frame;
    frame.origin = CGPointMake(228, 103);
    self.emotionsView.frame = frame;
    [_emotionsViewController.scrollView scrollRectToVisible:CGRectMake(0, 0, 204, 144) animated:NO];
    
    [self.emotionsView.layer addAnimation:[AnimationProvider popoverAnimation] forKey:nil];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.emotionsView.alpha = 1.0;
    }];
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
        [self.atScreenNames addObject:[[NSString alloc] initWithFormat:@"@"]];
    }
    
    // text
    else {        
        // TODO
        [self.atScreenNames insertObject:[[NSString alloc] initWithFormat:@"@%@", text] atIndex:0];
        
        NSManagedObjectContext* context = [(PushBoxAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription                                                  entityForName:@"User" inManagedObjectContext:context];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entityDescription];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[[NSString alloc] initWithFormat:@"screenName like[c] \"*%@*\"", text]];
        [request setPredicate:predicate];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]                                                                      initWithKey:@"screenName" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [sortDescriptor release];
        NSError *error;
        NSArray *array = [context executeFetchRequest:request error:&error];
        
        for (int i = 0; i < [array count]; i++) {
            [self.atScreenNames addObject:[[NSString alloc] initWithFormat:@"@%@", [[array objectAtIndex:i] screenName]]];
        }
    }
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
    
    self.doneButton.enabled = words >= 0;
	
	if (words >= 0) {
		self.wordsCountLabel.text = [NSString stringWithFormat:@"%d", words];
		self.wordsCountLabel.textColor = LabelBlackColor;
	} else {
		self.wordsCountLabel.text = [NSString stringWithFormat:@"超出 %d", -words];
		self.wordsCountLabel.textColor = LabelRedColor;
	}
    
    //REMAIN_TO_BE_CHECKED!
    if (_lastChar && [_lastChar compare:@"@"] == NSOrderedSame) {
        [self atButtonClicked:nil];
    }
}

- (IBAction)doneButtonClicked:(UIButton *)sender {
    NSString *comment = self.textView.text;
    
	WeiboClient *client = [WeiboClient client];
	
	[self showPostingView];
    [client setCompletionBlock:^(WeiboClient *client) {
        if (!client.hasError) {
			
			if (_repostFlag) {
				WeiboClient *client2 = [WeiboClient client];
				
				NSString *content;
				
				if (self.targetStatus.repostStatus) {
					NSString *first = [@"//@" stringByAppendingString:self.targetStatus.author.screenName];
					NSString *second = [first stringByAppendingString:@": "];
					NSString *third = [second stringByAppendingString:self.targetStatus.text];
					content = [comment stringByAppendingString:third];
				}
				else {
					content = comment;
				}
				
				[client2 setCompletionBlock:^(WeiboClient *client) {
					[self hidePostingView];
					if (!client.hasError) {
						[self dismissView];
						if ([self.delegate respondsToSelector:@selector(commentFinished)]) {
							[self.delegate commentFinished];
						}
						[[UIApplication sharedApplication] showOperationDoneView];
					} else {
						[ErrorNotification showPostError];
					}
				}];
				[client2 repost:self.targetStatus.statusID text:content commentStatus:NO commentOrigin:NO];
			} else {			
				[self dismissView];
				if ([self.delegate respondsToSelector:@selector(commentFinished)]) {
					[self.delegate commentFinished];
				}
				[[UIApplication sharedApplication] showOperationDoneView];
			}
        } else {
			[self hidePostingView];
			[ErrorNotification showPostError];
		}
    }];
    
	if (self.targetComment)
	{
		[client reply:self.targetStatus.statusID cid:self.targetComment.commentID text:comment withOutMention:YES];
	} else {
		[client comment:self.targetStatus.statusID cid:nil text:comment withOutMention:YES];
	}
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self dismissView];
}

- (IBAction)backButtonClicked:(UIButton *)sender {
    if ([self.textView.text length] == 0) {
        [self dismissView];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                                 delegate:self 
                                                        cancelButtonTitle:nil 
                                                   destructiveButtonTitle:NSLocalizedString(@"取消", nil)
                                                        otherButtonTitles:nil];
        [actionSheet showFromRect:sender.bounds inView:sender animated:YES];
        [actionSheet release];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		[self dismissView];
	}
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

- (void)didSelectEmotion:(NSString*)phrase
{
    int location = self.textView.selectedRange.location;
    NSString *content = self.textView.text;
    NSString *result = [NSString stringWithFormat:@"%@%@%@",[content substringToIndex:location], phrase, [content substringFromIndex:location]];
    self.textView.text = result;
    
    NSRange range = self.textView.selectedRange;
    range.location = location + [phrase length];
    self.textView.selectedRange = range;
    
    [self dismissEmotionsView];
    
}

- (IBAction)repostButtonClicked:(id)sender
{
	_repostFlag = !self.repostButton.selected;
	self.repostButton.selected = _repostFlag;
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
        self.atScreenNames = [[NSMutableArray alloc] initWithObjects:[[NSString alloc] initWithFormat:@"@%@", textField.text], nil];
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

- (IBAction)atButtonClicked:(id)sender {
    if (sender) {
        int location = self.textView.selectedRange.location;
        NSString *content = self.textView.text;
        NSString *result = [NSString stringWithFormat:@"%@@%@",[content substringToIndex:location], [content substringFromIndex:location]];
        self.textView.text = result;
        
        NSRange range = self.textView.selectedRange;
        range.location = location + 1;
        self.textView.selectedRange = range;
    }
    
    UIView *superView = [self.view superview];
    
    if (!_atBgButton)
        _atBgButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)];
    [_atBgButton addTarget:self action:@selector(dismissAtView) forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:_atBgButton];
    
	[superView addSubview:self.atView];
    CGRect frame = self.atView.frame;
    frame.origin = CGPointMake(195, 100);
    self.atView.frame = frame;
    
	[self.atView.layer addAnimation:[AnimationProvider popoverAnimation] forKey:nil];
	
    self.atTextField.text = @"";
    [self.atTextField becomeFirstResponder];
    
	[UIView animateWithDuration:1.0 animations:^{
		self.atView.alpha = 1.0;
	}];
    
    [self atTextFieldEditingBegan];
}


- (void)switchedOn
{
	_repostFlag = YES;
	self.alsoRepostLabel.textColor = LabelHilightColor2;
	self.alsoRepostLabel.shadowColor = LabelHilightShadowColor2;
}

- (void)switchedOff
{
	_repostFlag = NO;
	self.alsoRepostLabel.textColor = LabelNormalColor2;
	self.alsoRepostLabel.shadowColor = LabelNormalShadowColor2;
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
    
    int location = self.textView.selectedRange.location;
    NSString *content = self.textView.text;
    NSString *result = [NSString stringWithFormat:@"%@%@%@",[content substringToIndex:location], ([[[self.atScreenNames objectAtIndex:[indexPath row]] substringFromIndex:1] stringByAppendingString:@" "]), [content substringFromIndex:location]];
    
    self.textView.text = result;
    NSRange range = self.textView.selectedRange;
    range.location = location + [([[[self.atScreenNames objectAtIndex:[indexPath row]] substringFromIndex:1] stringByAppendingString:@" "]) length];
    self.textView.selectedRange = range;
    
    [self dismissAtView];
}

#pragma - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    int location = self.textView.selectedRange.location;
    NSString *content = self.textView.text;
    NSString *result = [NSString stringWithFormat:@"%@%@%@",[content substringToIndex:location], ([[[self.atScreenNames objectAtIndex:0] substringFromIndex:1] stringByAppendingString:@" "]), [content substringFromIndex:location]];
    self.textView.text = result;
    
    NSRange range = self.textView.selectedRange;
    range.location = location + [([[[self.atScreenNames objectAtIndex:0] substringFromIndex:1] stringByAppendingString:@" "]) length];
    self.textView.selectedRange = range;
    
    [self dismissAtView];
    
    return NO;
}

#pragma - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    _lastChar = [text retain];
    return YES;
}

@end
