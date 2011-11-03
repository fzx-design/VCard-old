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
    [super dealloc];
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
	
	self.textView.delegate = self;
	self.atView.layer.anchorPoint = CGPointMake(0.5, 0);
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
- (Boolean)isAtEndChar:(unichar)c
{
    NSArray* atEndCharArray = [[NSArray alloc] initWithObjects:
                               [[NSNumber alloc] initWithInt:44],   // ' '
                               [[NSNumber alloc] initWithInt:46],   // ' '
                               [[NSNumber alloc] initWithInt:32],   // ' '
                               [[NSNumber alloc] initWithInt:64],   // '@'
                               [[NSNumber alloc] initWithInt:58],   // ':'
                               [[NSNumber alloc] initWithInt:59],   // ';'
                               [[NSNumber alloc] initWithInt:35],   // '#'
                               [[NSNumber alloc] initWithInt:39],   // '''
                               [[NSNumber alloc] initWithInt:34],   // '"'
                               [[NSNumber alloc] initWithInt:40],   // '('
                               [[NSNumber alloc] initWithInt:41],   // ')'
                               [[NSNumber alloc] initWithInt:91],   // '['
                               [[NSNumber alloc] initWithInt:93],   // ']'
                               [[NSNumber alloc] initWithInt:123],   // '{'
                               [[NSNumber alloc] initWithInt:125],   // '}'
                               [[NSNumber alloc] initWithInt:126],   // '~'
                               [[NSNumber alloc] initWithInt:33],   // '!'
                               [[NSNumber alloc] initWithInt:36],   // '$'
                               [[NSNumber alloc] initWithInt:37],   // '%'
                               [[NSNumber alloc] initWithInt:94],   // '^'
                               [[NSNumber alloc] initWithInt:38],   // '&'
                               [[NSNumber alloc] initWithInt:42],   // '*'
                               [[NSNumber alloc] initWithInt:43],   // '+'
                               [[NSNumber alloc] initWithInt:61],   // '='
                               [[NSNumber alloc] initWithInt:124],   // '|'
                               [[NSNumber alloc] initWithInt:60],   // '<'
                               [[NSNumber alloc] initWithInt:62],   // '>'
                               [[NSNumber alloc] initWithInt:92],   // '\'
                               [[NSNumber alloc] initWithInt:47],   // '/'
                               [[NSNumber alloc] initWithInt:63],   // '?'
                               [[NSNumber alloc] initWithInt:65306],   // '"'
                               [[NSNumber alloc] initWithInt:65307],   // '"'
                               [[NSNumber alloc] initWithInt:8216],   // '"'
                               [[NSNumber alloc] initWithInt:8217],   // '"'
                               [[NSNumber alloc] initWithInt:8220],   // '"'
                               [[NSNumber alloc] initWithInt:8221],   // '"'
                               [[NSNumber alloc] initWithInt:65288],   // '"'
                               [[NSNumber alloc] initWithInt:65289],   // '"'
                               [[NSNumber alloc] initWithInt:65339],   // '"'
                               [[NSNumber alloc] initWithInt:12290],   // '"'
                               [[NSNumber alloc] initWithInt:65341],   // '"'
                               [[NSNumber alloc] initWithInt:65292],   // '，'
                               [[NSNumber alloc] initWithInt:12289],   // '、'
                               [[NSNumber alloc] initWithInt:65371],   // '"'
                               [[NSNumber alloc] initWithInt:65373],   // '"'
                               [[NSNumber alloc] initWithInt:65374],   // '"'
                               [[NSNumber alloc] initWithInt:65281],   // '"'
                               [[NSNumber alloc] initWithInt:65283],   // '"'
                               [[NSNumber alloc] initWithInt:65509],   // '"'
                               [[NSNumber alloc] initWithInt:65285],   // '"'
                               [[NSNumber alloc] initWithInt:8212],   // '"'
                               [[NSNumber alloc] initWithInt:65290],   // '"'
                               [[NSNumber alloc] initWithInt:65291],   // '"'
                               [[NSNumber alloc] initWithInt:65309],   // '"'
                               [[NSNumber alloc] initWithInt:65372],   // '"'
                               [[NSNumber alloc] initWithInt:12298],   // '"'
                               [[NSNumber alloc] initWithInt:65295],   // '"'
                               [[NSNumber alloc] initWithInt:65311],   // '"'
                               [[NSNumber alloc] initWithInt:8230],   // '"'
                               nil];
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
        self.atScreenNames = [[NSMutableArray alloc] initWithCapacity:1];
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
	
	if (words > 0) {
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
    if (sender)
        self.textView.text = [self.textView.text stringByAppendingFormat:@"@"];
    
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
}

- (void)switchedOff
{
	_repostFlag = NO;
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
