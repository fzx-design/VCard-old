//
//  SmartCardViewController.m
//  PushBox
//
//  Created by Ren Kelvin on 10/18/11.
//  Copyright 2011 同济大学. All rights reserved.
//

#import "SmartCardViewController.h"
#import "Status.h"
#import "User.h"
#import "Emotion.h"
#import "UIImageViewAddition.h"
#import "NSDateAddition.h"
#import "OptionsTableViewController.h"
#import "UIApplicationAddition.h"
#import "PushBoxAppDelegate.h"
#import "WeiboClient.h"

#define kLoadDelay 1.5
#define kPlayButtonFrameTopRight CGRectMake(399, 306, 68, 68)
#define kPlayButtonFrameCenter CGRectMake(251, 373, 68, 68)
#define kPlayButtonFrameBottom CGRectMake(251, 413, 68, 68)
#define kRepostViewFrameTop CGRectMake(57, 275, 451, 134)
#define kRepostWebViewFrameTop CGRectMake(57, 275, 451, 134)
#define kRepostViewFrameBottom CGRectMake(57, 275+125, 451, 134)
#define kRepostWebViewFrameBottom CGRectMake(57, 275+125, 451, 134)

@implementation SmartCardViewController

@synthesize profileImageView = _profileImageView;
@synthesize screenNameLabel = _screenNameLabel;
@synthesize gifIcon = _gifIcon;
@synthesize dateLabel = _dateLabel;
@synthesize actionsButton = _actionsButton;
@synthesize repostCountLabel = _repostCountLabel;
@synthesize commentCountLabel = _commentCountLabel;
@synthesize addFavourateButton = _addFavourateButton;
@synthesize tweetScrollView = _tweetScrollView;
@synthesize tweetImageView = _tweetImageView;
@synthesize tweetTextView = _tweetTextView;
@synthesize postWebView = _postWebView;
@synthesize repostWebView = _repostWebView;
@synthesize repostTextView = _repostTextView;
@synthesize repostView = _repostView;
@synthesize trackLabel = _trackLabel;
@synthesize trackView = _trackView;
@synthesize imageCoverImageView = _imageCoverImageView;
@synthesize musicBackgroundImageView = _musicBackgroundImageView;
@synthesize musicCoverImageView = _musicCoverImageView;
@synthesize playButton = _playButton;
@synthesize recentActNotifyLabel = _recentActNotifyLabel;

@synthesize status = _status;
@synthesize musicLink = _musicLink;


- (void)dealloc
{    
    [_postWebView release];
    [_repostWebView release];
    [_profileImageView release];
    [_screenNameLabel release];
    [_dateLabel release];
    [_actionsButton release];
    [_repostCountLabel release];
    [_commentCountLabel release];
    [_addFavourateButton release];
    [_tweetScrollView release];
    [_tweetImageView release];
    [_tweetTextView release];
    [_repostTextView release];
    [_repostView release];
    [_status release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.profileImageView = nil;
    self.screenNameLabel = nil;
    self.dateLabel = nil;
    self.actionsButton = nil;
    self.repostCountLabel = nil;
    self.commentCountLabel = nil;
    self.addFavourateButton = nil;
    self.tweetScrollView = nil;
    self.tweetImageView = nil;
    self.tweetTextView = nil;
    self.repostTextView = nil;
    self.repostView = nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"smartcard" ofType:@"js"];  
    //    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath];  
    //    [self.postWebView stringByEvaluatingJavaScriptFromString:jsString];  
    //    [self.repostWebView stringByEvaluatingJavaScriptFromString:jsString];  
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
	tapGesture.numberOfTapsRequired = 1;
	tapGesture.numberOfTouchesRequired = 1;
	[self.tweetImageView addGestureRecognizer:tapGesture];
	[tapGesture release];
    
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
    tapGesture2.numberOfTapsRequired = 1;
    tapGesture2.numberOfTouchesRequired = 1;
    [self.musicCoverImageView addGestureRecognizer:tapGesture2];
    [tapGesture2 release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shouldDismissUserCardNotification:)
                                                 name:kNotificationNameShouldDismissUserCard
                                               object:nil];
}

- (void)clear
{
    // 	self.profileImageView = nil;
    //    self.screenNameLabel = nil;
    //    self.dateLabel = nil;
    //    self.actionsButton = nil;
    //    self.repostCountLabel = nil;
    //    self.commentCountLabel = nil;
    //    self.addFavourateButton = nil;
    //    self.tweetScrollView = nil;
    //    self.tweetImageView = nil;
    //    self.tweetTextView = nil;
    //    self.repostTextView = nil;
    //    self.repostView = nil;
}

- (BOOL)checkGif:(NSString*)url
{
    if (url == nil) {
        return NO;
    }
    
    NSString* extName = [url substringFromIndex:([url length] - 3)];
    
    if ([extName compare:@"gif"] == NSOrderedSame) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)imageViewClicked:(UIGestureRecognizer *)ges
{
	UIView *mainView = [[UIApplication sharedApplication] rootView];
    
    //    UIImageView *imageView = (UIImageView *)ges.view;
    //    DetailImageViewController *dvc = [[DetailImageViewController alloc] initWithImage:imageView.image];
    NSString* url = self.status.originalPicURL ? self.status.originalPicURL : self.status.repostStatus.originalPicURL;
    DetailImageViewController *dvc = [[DetailImageViewController alloc] initWithUrl:url];
    
    if ([self checkGif:self.status.originalPicURL])
        dvc.gifUrl = self.status.originalPicURL;
    if ([self checkGif:self.status.repostStatus.originalPicURL])
        dvc.gifUrl = self.status.repostStatus.originalPicURL;
    
    dvc.delegate = self;
    [mainView addSubview:dvc.view];
    dvc.view.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        dvc.view.alpha = 1.0;
    }];
}

- (void)detailImageViewControllerShouldDismiss:(UIViewController *)vc
{
	[UIView animateWithDuration:0.5 animations:^{
		vc.view.alpha = 0.0;
	} completion:^(BOOL fin){
		[vc.view removeFromSuperview];
		[vc release];
	}];
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

- (Boolean)isLinkEndChar:(unichar)c
{
    if (c > 127) {
        return YES;
    }
    
    NSArray* atEndCharArray = [[[NSArray alloc] initWithObjects:
                                [[[NSNumber alloc] initWithInt:44] autorelease],   // ' '
                                [[[NSNumber alloc] initWithInt:32] autorelease],   // ' '
                                [[[NSNumber alloc] initWithInt:64] autorelease],   // '@'
                                [[[NSNumber alloc] initWithInt:59] autorelease],   // ';'
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
                                [[[NSNumber alloc] initWithInt:94] autorelease],   // '^'
                                [[[NSNumber alloc] initWithInt:42] autorelease],   // '*'
                                [[[NSNumber alloc] initWithInt:43] autorelease],   // '+'
                                [[[NSNumber alloc] initWithInt:124] autorelease],   // '|'
                                [[[NSNumber alloc] initWithInt:60] autorelease],   // '<'
                                [[[NSNumber alloc] initWithInt:62] autorelease],   // '>'
                                [[[NSNumber alloc] initWithInt:65306] autorelease],   // '"'
                                [[[NSNumber alloc] initWithInt:65307] autorelease],   // '"'
                                [[[NSNumber alloc] initWithInt:8216] autorelease],   // '"'
                                [[[NSNumber alloc] initWithInt:8217] autorelease],   // '"'
                                [[[NSNumber alloc] initWithInt:8220] autorelease],   // '"'
                                [[[NSNumber alloc] initWithInt:8221] autorelease],   // '"'
                                [[[NSNumber alloc] initWithInt:65288] autorelease],   // '"'
                                [[[NSNumber alloc] initWithInt:65289] autorelease],   // '"'
                                [[[NSNumber alloc] initWithInt:65339] autorelease],   // '"'
                                [[[NSNumber alloc] initWithInt:65341] autorelease],   // '"'
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
                                [[[NSNumber alloc] initWithInt:65292] autorelease],   // '，'
                                [[[NSNumber alloc] initWithInt:12289] autorelease],   // '、'
                                nil] autorelease];
    for (int i = 0; i < [atEndCharArray count]; i++)
    {
        if (c == [[atEndCharArray objectAtIndex:i] intValue])
            return YES;
    }    
    return NO;
}

- (void)prepare
{		
    b = YES;
    isTrack = YES;
    
    self.profileImageView.alpha = 0.0;
    self.musicLink = nil;
    
    self.musicCoverImageView.hidden = YES;
    
    self.musicBackgroundImageView.hidden = YES;
    
	self.tweetImageView.image = nil;
	self.tweetImageView.alpha = 0.0;
    
    self.tweetImageView.hidden = YES;
    
    self.imageCoverImageView.alpha = 0.0;
    
    self.gifIcon.hidden = YES;
    
    self.repostView.alpha = 0.0;
    
    self.postWebView.alpha = 0.0;
    self.repostWebView.alpha = 0.0;
    
    for (id subview in self.postWebView.subviews){
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).scrollEnabled = NO;
    }
    for (id subview in self.repostWebView.subviews){
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).scrollEnabled = NO;
    }
    
    self.repostView.frame = kRepostViewFrameTop;
    self.repostWebView.frame = kRepostWebViewFrameTop;
    
    self.musicCoverImageView.hidden = YES;
    self.musicCoverImageView.alpha = 0;
    
    self.trackLabel.alpha = 0.0;
    self.trackView.alpha = 0.0;
    self.recentActNotifyLabel.alpha = 0.0;    
    self.trackLabel.text = @"";
    
    self.playButton.hidden = YES;
    self.musicBackgroundImageView.alpha = 0.0;
    //    self.playButton.frame = kPlayButtonFrameCenter;
    
	self.profileImageView.image = nil;
	self.screenNameLabel.text = self.status.author.screenName;
    self.dateLabel.text = [self.status.createdAt customString];
	
    self.commentCountLabel.text = self.status.commentsCount ? self.status.commentsCount : @"0";
    self.repostCountLabel.text = self.status.repostsCount ? self.status.repostsCount : @"0";
    
	self.tweetTextView.text = @"";
    self.repostTextView.text = @"";
    
    //
    [[self.tweetImageView layer] setCornerRadius:20.0];
}

- (void)loadStatusImage
{
    self.tweetImageView.hidden = NO;
    self.imageCoverImageView.hidden = NO;
    [self.tweetImageView loadImageFromURL:self.status.bmiddlePicURL
                               completion:^(void) 
     {
         [UIView animateWithDuration:0.5 delay:0.3 options:0 animations:^{
             self.tweetImageView.alpha = 1.0;
             self.imageCoverImageView.alpha = 1.0;
         } completion:^(BOOL fin) {
         }];
     } 
                           cacheInContext:self.managedObjectContext];
    
    if ([self checkGif:self.status.originalPicURL])
    {
        [self.gifIcon setHidden:NO];
    }
}

- (void)loadRepostStautsImage
{
    self.tweetImageView.hidden = NO;
    self.imageCoverImageView.hidden = NO;
    Status *repostStatus = self.status.repostStatus;
    [self.tweetImageView loadImageFromURL:repostStatus.bmiddlePicURL 
                               completion:^(void) 
     {
         [UIView animateWithDuration:0.5 delay:1.0 options:0 animations:^{
             if (b) {
                 self.tweetImageView.alpha = 1.0;
                 self.imageCoverImageView.alpha = 1.0;
             }
         } completion:^(BOOL fin) {
         }];
     }
                           cacheInContext:self.managedObjectContext];
    if ([self checkGif:self.status.repostStatus.originalPicURL])
    {
        [self.gifIcon setHidden:NO];
    }
}

- (void)loadRepostStautsImageV2
{
    self.tweetImageView.hidden = NO;
    self.imageCoverImageView.hidden = NO;
    Status *repostStatus = self.status.repostStatus;
    [self.tweetImageView loadImageFromURL:repostStatus.bmiddlePicURL 
                               completion:^(void) 
     {
         [UIView animateWithDuration:0.5 delay:0.3 options:0 animations:^{
             self.tweetImageView.alpha = 1.0;
             self.imageCoverImageView.alpha = 1.0;
         } completion:^(BOOL fin) {
         }];
     }
                           cacheInContext:self.managedObjectContext];
    
    if ([self checkGif:self.status.repostStatus.originalPicURL])
    {
        [self.gifIcon setHidden:NO];
    }
}

- (void)loadPostWebView
{
    NSString* originStatus = self.status.text;
    NSString* phasedStatus = self.status.text;
    
    // phase
    for (int i = 0; i < originStatus.length; i++) {
        int startIndex = i;
        int endIndex = i;
        
        switch ([originStatus characterAtIndex:i]) {
            case '@':
            {
                int j;
                for (j = i + 1; j < originStatus.length; j++) {
                    if ([self isAtEndChar:[originStatus characterAtIndex:j]]) {
                        NSLog(@"%d", [originStatus characterAtIndex:j]);
                        break;
                    }
                };
                endIndex = j;
                {
                    NSRange range = NSMakeRange(startIndex, endIndex-startIndex);
                    NSString* subStr = [originStatus substringWithRange:range];
                    if (endIndex > startIndex + 1)
                        phasedStatus = [phasedStatus stringByReplacingOccurrencesOfString:subStr withString:[[[NSString alloc] initWithFormat:@"<span class='posthighlight'><a href='javascript:void(0);' onclick='atClicked(\"%@\")'>%@</a></span>", [subStr substringFromIndex:1], subStr] autorelease]];
                }
                break;
            }
            case 65283:
            case '#':
            {
                for (int j = i + 1; j < originStatus.length; j++) {
                    if ([originStatus characterAtIndex:j] == '#'||[originStatus characterAtIndex:j] == 65283) {
                        endIndex = j;
                        break;
                    }
                }
                if(startIndex < endIndex)
                {
                    NSRange range = NSMakeRange(startIndex, endIndex+1-startIndex);
                    NSString* subStr = [originStatus substringWithRange:range];
                    phasedStatus = [phasedStatus stringByReplacingOccurrencesOfString:subStr withString:[[[NSString alloc] initWithFormat:@"<span class='posthighlight'><a href='javascript:void(0);' onclick='spClicked(\"%@\")'>%@</a></span>", [subStr substringFromIndex:1], subStr] autorelease]];
                }
                
                break;
            }
            case 'h':
            {
                if ([originStatus length] - 1 < i + 6 ) {
                    break;
                }
                NSRange range = NSMakeRange(i, 7);
                NSString* subStr = [originStatus substringWithRange:range];
                if ([subStr compare:@"http://"] == NSOrderedSame) {
                    int j;
                    for (j = i + 1; j < originStatus.length; j++) {
                        if ([self isLinkEndChar:[originStatus characterAtIndex:j]]) {
                            break;
                        }
                    }
                    endIndex = j;
                    range = NSMakeRange(startIndex, endIndex-startIndex);
                    subStr = [originStatus substringWithRange:range];
                    phasedStatus = [phasedStatus stringByReplacingOccurrencesOfString:subStr withString:[[[NSString alloc] initWithFormat:@"<span class='posthighlight'><a href='javascript:void(0);' onclick='lkClicked(\"%@\")'>%@</a></span>", subStr, subStr] autorelease]];
                }
                break;
            }
            case '[':
            {
                int j = i + 1;
                for (j = i + 1; j < originStatus.length; j++) {
                    if ([originStatus characterAtIndex:j] == ']') {
                        break;
                    }
                }
                endIndex = j;
                
                NSRange range = NSMakeRange(startIndex, endIndex-startIndex+1);
                NSString* subStr = [originStatus substringWithRange:range];                
                
                NSManagedObjectContext* context = [(PushBoxAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
                NSEntityDescription *entityDescription = [NSEntityDescription                                                  entityForName:@"Emotion" inManagedObjectContext:context];
                NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
                [request setEntity:entityDescription];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:[[[NSString alloc] initWithFormat:@"phrase == \"%@\"", subStr] autorelease]];
                [request setPredicate:predicate];
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]                                                                      initWithKey:@"phrase" ascending:YES];
                [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                [sortDescriptor release];
                NSError *error;
                NSArray *array = [context executeFetchRequest:request error:&error];
                NSString* url = [(Emotion*)[array lastObject] url];
                
                if (url) {
                    phasedStatus = [phasedStatus stringByReplacingOccurrencesOfString:subStr withString:[[[NSString alloc] initWithFormat:@"<span><img src=\"%@\"></span>", url] autorelease]];
                }
            }
            default:
                break;
        }
    }
    
    NSString* htmlText = [[[NSString alloc] initWithFormat:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\" /><link href=\"smartcard.css\" rel=\"stylesheet\" type=\"text/css\" /><script type='text/javascript' src='smartcard.js'></script></head><body><div id=\"post\">%@</div></body></html>", phasedStatus] autorelease];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"smartcard" ofType:@"html"]; 
    [self.postWebView loadHTMLString:htmlText baseURL:[NSURL fileURLWithPath: path]];    
    
    [UIView animateWithDuration:0.5 delay:0.3 options:0 animations:^{
        self.postWebView.alpha = 1.0;
        self.imageCoverImageView.alpha = 1.0;
    } completion:^(BOOL fin) {
    }];
}

- (void)loadRepostWebView
{
    self.repostView.hidden = NO;
    
    NSString* originStatus = self.status.repostStatus.text;
    NSString* phasedStatus = self.status.repostStatus.text;
    //    NSString* originStatus = @"fdsjkl@jffa@";
    //    NSString* phasedStatus = @"fdsjkl@jffa@";
    
    NSLog(@"%@", originStatus);
    
    // phase
    for (int i = 0; i < originStatus.length; i++) {
        int startIndex = i;
        int endIndex = i;
        
        switch ([originStatus characterAtIndex:i]) {
            case '@':
            {
                int j;
                for (j = i + 1; j < originStatus.length; j++) {
                    if ([self isAtEndChar:[originStatus characterAtIndex:j]]) {
                        break;
                    }
                };
                endIndex = j;
                if(startIndex < endIndex)
                {
                    NSRange range = NSMakeRange(startIndex, endIndex-startIndex);
                    NSString* subStr = [originStatus substringWithRange:range];
                    if (endIndex > startIndex + 1)
                        phasedStatus = [phasedStatus stringByReplacingOccurrencesOfString:subStr withString:[[[NSString alloc] initWithFormat:@"<span class='highlight'><a href='javascript:void(0);' onclick='atClicked(\"%@\")'>%@</a></span>", [subStr substringFromIndex:1], subStr] autorelease]];
                }
                break;
            }
            case 65283:
            case '#':
            {
                for (int j = i + 1; j < originStatus.length; j++) {
                    if ([originStatus characterAtIndex:j] == '#'||[originStatus characterAtIndex:j] == 65283) {
                        endIndex = j;
                        break;
                    }
                }
                if(startIndex < endIndex)
                {
                    NSRange range = NSMakeRange(startIndex, endIndex+1-startIndex);
                    NSString* subStr = [originStatus substringWithRange:range];
                    phasedStatus = [phasedStatus stringByReplacingOccurrencesOfString:subStr withString:[[[NSString alloc] initWithFormat:@"<span class='highlight'><a href='javascript:void(0);' onclick='spClicked(\"%@\")'>%@</a></span>", [subStr substringFromIndex:1], subStr] autorelease]];
                }
                break;
            }
            case 'h':
            {
                if ([originStatus length] - 1 < i + 6 ) {
                    break;
                }
                NSRange range = NSMakeRange(i, 7);
                NSString* subStr = [originStatus substringWithRange:range];
                if ([subStr compare:@"http://"] == NSOrderedSame) {
                    int j;
                    for (j = i + 1; j < originStatus.length; j++) {
                        if ([self isLinkEndChar:[originStatus characterAtIndex:j]]) {
                            break;
                        }
                    }
                    endIndex = j;
                    range = NSMakeRange(startIndex, endIndex-startIndex);
                    subStr = [originStatus substringWithRange:range];
                    phasedStatus = [phasedStatus stringByReplacingOccurrencesOfString:subStr withString:[[[NSString alloc] initWithFormat:@"<span class='highlight'><a href='javascript:void(0);' onclick='lkClicked(\"%@\")'>%@</a></span>", subStr, subStr] autorelease]];
                }
                break;
            }
            case '[':
            {
                int j = i + 1;
                for (j = i + 1; j < originStatus.length; j++) {
                    if ([originStatus characterAtIndex:j] == ']') {
                        break;
                    }
                }
                endIndex = j;
                
                NSRange range = NSMakeRange(startIndex, endIndex-startIndex+1);
                NSString* subStr = [originStatus substringWithRange:range];                
                
                NSManagedObjectContext* context = [(PushBoxAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
                NSEntityDescription *entityDescription = [NSEntityDescription                                                  entityForName:@"Emotion" inManagedObjectContext:context];
                NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
                [request setEntity:entityDescription];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:[[[NSString alloc] initWithFormat:@"phrase == \"%@\"", subStr] autorelease]];
                [request setPredicate:predicate];
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]                                                                      initWithKey:@"phrase" ascending:YES];
                [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                [sortDescriptor release];
                NSError *error;
                NSArray *array = [context executeFetchRequest:request error:&error];
                NSString* url = [(Emotion*)[array lastObject] url];
                
                if (url) {
                    phasedStatus = [phasedStatus stringByReplacingOccurrencesOfString:subStr withString:[[[NSString alloc] initWithFormat:@"<span><img src=\"%@\"></span>", url] autorelease]];
                }
            }
            default:
                break;
        }
    }
    
    //    NSString* htmlText = [[NSString alloc] initWithFormat:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\" /><style type=\"text/css\">@import url(\"smartcard.css\");</style></head><body><div id=\"post\">%@</div></body></html>", phasedStatus];
    NSString* htmlText = [[[NSString alloc] initWithFormat:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\" /><link href=\"smartcard.css\" rel=\"stylesheet\" type=\"text/css\" /><script type='text/javascript' src='smartcard.js'></script></head><body style=\"background-color:transparent\"><div id=\"repost\"><span class='highlight'><a href='javascript:void(0);' onclick='atClicked(\"%@\")'>@%@</a></span>: %@</div></body></html>", self.status.repostStatus.author.screenName, self.status.repostStatus.author.screenName, phasedStatus] autorelease];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"smartcard" ofType:@"html"]; 
    [self.repostWebView loadHTMLString:htmlText baseURL:[NSURL fileURLWithPath: path]];
    
    [UIView animateWithDuration:0.5 delay:0.3 options:0 animations:^{
        self.repostView.alpha = 1.0;
        self.repostWebView.alpha = 1.0;
        self.imageCoverImageView.alpha = 1.0;
    } completion:^(BOOL fin) {
    }];
    
}

- (void)loadMusicCoverImage
{
    self.musicCoverImageView.hidden = NO;
    [self.musicCoverImageView loadImageFromURL:self.status.repostStatus.thumbnailPicURL 
                                    completion:^(void) 
     {
         [UIView animateWithDuration:0.5 delay:0.1 options:0 animations:^{
             self.musicCoverImageView.alpha = 1.0;
         } completion:^(BOOL fin) {
         }];
     } 
                                cacheInContext:self.managedObjectContext];
}

- (void)openLinkInSafari:(NSString*)link
{
    if (link) {
        NSURL* url = [[[NSURL alloc] initWithString:link] autorelease];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)openLinkInInnerBroswer:(NSString*)link
{
    if (link) {
        InnerBroswerViewController* browser = [[InnerBroswerViewController alloc] init];
        [[UIApplication sharedApplication] presentModalViewController:browser atHeight:0];
        [browser loadLink:link];
        [browser release];
    }
}

- (IBAction)playButtonClicked:(id)sender
{
    [self openLinkInInnerBroswer:self.musicLink];
}

- (void)loadPostMusicVideo:(NSString*)postMusicVideoLink
{    
    if (!self.status.repostStatus) {
        self.playButton.hidden = NO;
        //        self.playButton.frame = kPlayButtonFrameCenter;
        self.musicLink = postMusicVideoLink;
        [UIView animateWithDuration:0.5 delay:0.3 options:0 animations:^{
            self.playButton.alpha = 1.0;
        } completion:^(BOOL fin) {
        }];
    }
}

- (void)loadRepostMusicVideo:(NSString*)repostMusicVideoLink
{
    self.playButton.hidden = NO;
    //    self.playButton.frame = kPlayButtonFrameTopRight;
    self.repostView.frame = kRepostViewFrameBottom;
    self.repostWebView.frame = kRepostWebViewFrameBottom;
    self.musicLink = repostMusicVideoLink;
    self.tweetImageView.hidden = YES;
    self.musicBackgroundImageView.hidden = NO;
    [UIView animateWithDuration:0.5 delay:0.3 options:0 animations:^{
        self.musicBackgroundImageView.alpha = 1.0;
        self.tweetImageView.alpha = 0.0;
        self.imageCoverImageView.alpha = 1.0;
    } completion:^(BOOL fin) {
    }];
    
    [self loadMusicCoverImage];
}

- (void)loadRepostMusicVideoV2:(NSString*)repostMusicVideoLink
{
    self.playButton.hidden = NO;
    //    self.playButton.frame = kPlayButtonFrameBottom;
}

- (void)getPostMusicVideoLink:(NSString*)statusText
{
    NSString* shortUrl = nil;
    
    for (int i = 0; i < statusText.length; i++) {
        int startIndex = i;
        int endIndex = i;
        
        if ([statusText characterAtIndex:i] == 'h') {
            
            if ([statusText length] - 1 < i + 6 ) {
                break;
            }
            
            NSRange range = NSMakeRange(i, 7);
            shortUrl = [statusText substringWithRange:range];
            if ([shortUrl compare:@"http://"] == NSOrderedSame) {
                int j;
                for (j = i + 1; j < statusText.length; j++) {
                    if ([statusText characterAtIndex:j] == ' ') {
                        break;
                    }
                }
                endIndex = j;
                range = NSMakeRange(startIndex, endIndex-startIndex);
                shortUrl = [statusText substringWithRange:range];            
                
                
                WeiboClient *client = [WeiboClient client];
                [client setCompletionBlock:^(WeiboClient *client) {
                    if (!client.hasError) {
                        NSArray *dictsArray = client.responseJSONObject;
                        NSDictionary *dict = [dictsArray objectAtIndex:0];
                        if ([dict objectForKey:@"url_long"]) {
                            NSString* longUrl = [dict objectForKey:@"url_long"];
                            
                            
                            if ([longUrl rangeOfString:@"http://v.youku.com"].location != NSNotFound || [longUrl rangeOfString:@"http://video.sina.com"].location != NSNotFound || [longUrl rangeOfString:@"http://www.tudou.com"].location != NSNotFound || [longUrl rangeOfString:@"http://v.ku6.com"].location != NSNotFound || [longUrl rangeOfString:@"http://www.56.com"].location != NSNotFound || [longUrl rangeOfString:@"http://music.sina.com"].location != NSNotFound || [longUrl rangeOfString:@"http://www.xiami.com"].location != NSNotFound || [longUrl rangeOfString:@"songtaste.com"].location != NSNotFound) {
                                isTrack = NO;
                                [self loadPostMusicVideo:longUrl];
                            }
                        }
                    }
                }];
                
                if (shortUrl)
                    [client getShortUrlExpand:shortUrl];
            }
        }
    }
    
}

- (void)getRepostMusicVideoLink:(NSString*)statusText
{
    
    NSString* shortUrl = nil;
    
    for (int i = 0; i < statusText.length; i++) {
        int startIndex = i;
        int endIndex = i;
        
        if ([statusText characterAtIndex:i] == 'h') {
            
            if ([statusText length] - 1 < i + 6 ) {
                break;
            }
            
            NSRange range = NSMakeRange(i, 7);
            shortUrl = [statusText substringWithRange:range];
            if ([shortUrl compare:@"http://"] == NSOrderedSame) {
                int j;
                for (j = i + 1; j < statusText.length; j++) {
                    if ([statusText characterAtIndex:j] == ' ') {
                        break;
                    }
                }
                endIndex = j;
                range = NSMakeRange(startIndex, endIndex-startIndex);
                shortUrl = [statusText substringWithRange:range];            
                
                
                WeiboClient *client = [WeiboClient client];
                [client setCompletionBlock:^(WeiboClient *client) {
                    if (!client.hasError) {
                        NSArray *dictsArray = client.responseJSONObject;
                        NSDictionary *dict = [dictsArray objectAtIndex:0];
                        if ([dict objectForKey:@"url_long"]) {
                            NSString* longUrl = [dict objectForKey:@"url_long"];
                            
                            
                            if ([longUrl rangeOfString:@"http://v.youku.com"].location != NSNotFound || [longUrl rangeOfString:@"http://video.sina.com"].location != NSNotFound || [longUrl rangeOfString:@"http://www.tudou.com"].location != NSNotFound || [longUrl rangeOfString:@"http://v.ku6.com"].location != NSNotFound || [longUrl rangeOfString:@"http://www.56.com"].location != NSNotFound || [longUrl rangeOfString:@"http://music.sina.com"].location != NSNotFound|| [longUrl rangeOfString:@"http://www.xiami.com"].location != NSNotFound || [longUrl rangeOfString:@"songtaste.com"].location != NSNotFound) {
                                b = NO;
                                [self loadRepostMusicVideoV2:longUrl];
                            } 
                        }
                    }
                }];
                
                if (shortUrl) {
                    [client getShortUrlExpand:shortUrl];
                }
            }
        }
    }
}

- (void)update
{	
	BOOL imageLoadingEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultKeyImageDownloadingEnabled];
    
    Status *status = self.status;
    
    isTrack = YES;
    
    NSString *profileImageString = self.status.author.profileImageURL;
    [self.profileImageView loadImageFromURL:profileImageString 
                                 completion:   ^(void)     {
                                     [UIView animateWithDuration:0.5 delay:0.3 options:0 animations:^{
                                         self.profileImageView.alpha = 1.0;
                                     } completion:^(BOOL fin) {
                                     }];
                                 }                                                                           cacheInContext:self.managedObjectContext];
    
    // post text
    [self loadPostWebView];
    
    // post image
    if (imageLoadingEnabled && self.status.originalPicURL) {
        [self performSelector:@selector(loadStatusImage) withObject:nil afterDelay:kLoadDelay];
        isTrack = NO;
    }
    
    // post music or video
    if (YES) {
        [self getPostMusicVideoLink:status.text];
    }
    
    if (self.status.repostStatus) {
        Status *repostStatus = self.status.repostStatus;
        
        isTrack = NO;
        
        // repost text
        [self loadRepostWebView];
        
        // repost image
        if (imageLoadingEnabled && repostStatus.originalPicURL.length) {
            [self performSelector:@selector(loadRepostStautsImageV2) withObject:nil afterDelay:kLoadDelay];
        }
        
        // repost music or video
        if (YES) {
            [self getRepostMusicVideoLink:repostStatus.text];
        }
    }
    
    // Track
    if (isTrack) {
        NSString* actNotiString = [[[NSString alloc] initWithFormat:@"%@ 关于此微博的最新进展", status.author.screenName] autorelease];
        self.recentActNotifyLabel.text = actNotiString;
        
        // 
        NSString* trackString = [[[NSString alloc] initWithFormat:@"询问 %@", status.author.screenName] autorelease];
        self.trackLabel.text = trackString;
        
        self.trackLabel.alpha = 0.0;
        self.trackView.alpha = 0.0;
        self.recentActNotifyLabel.alpha = 0.0;
        
        [UIView animateWithDuration:0.5 delay:0.3 options:0 animations:^{
            self.trackLabel.alpha = 1.0;
            self.trackView.alpha = 1.0;
            //            self.recentActNotifyLabel.alpha = 1.0;
        } completion:^(BOOL fin) {
            
        }];
        
    }
    
}

- (void)setStatus:(Status *)status
{
    if ([self.status isEqualToStatus:status]) {
        return;
    }
    
    [_status release];
    _status = [status retain];
    //    _status = status;
    
    [self prepare];
    [self performSelector:@selector(update) withObject:nil afterDelay:0.3];
}

- (IBAction)actionsButtonClicked:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                             delegate:self 
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil 
                                                    otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"转发", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"发表评论", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"查看评论", nil)];
    if (![self.currentUser.favorites containsObject:self.status]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"收藏", nil)];
    } else {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"取消收藏", nil)];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"邮件分享", nil)];
    if ([self.status.author.userID isEqualToString:self.currentUser.userID]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"删除微博", nil)];
        actionSheet.destructiveButtonIndex = 5;
    }
    
    [actionSheet showFromRect:sender.bounds inView:sender animated:YES];
    [actionSheet release];
}

- (void)newComment
{
    CommentViewController *vc = [[CommentViewController alloc] init];
    vc.targetStatus = self.status;
    [[UIApplication sharedApplication] presentModalViewController:vc atHeight:kModalViewHeight];
    [vc release];
}

- (IBAction)askOwnerButtonClicked:(UIButton *)sender
{
    [self performSelector:@selector(newComment)];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UIAlertView *alert = nil;
    MFMailComposeViewController *picker = nil;
    switch (buttonIndex) {
        case 0:
            [self repostButtonClicked:nil];
            break;
        case 1:
            [self newComment];
            break;
        case 2:
            [self commentButtonClicked:nil];
            break;
        case 3:
            [self addFavButtonClicked:self.addFavourateButton];
            break;
        case 4:
            picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            picker.modalPresentationStyle = UIModalPresentationPageSheet;
            
            NSString *subject = [NSString stringWithFormat:@"分享一条来自新浪的微博，作者：%@", self.status.author.screenName];
            
            [picker setSubject:subject];
            NSString *emailBody = [NSString stringWithFormat:@"%@ %@", self.status.text, self.status.repostStatus.text];
            [picker setMessageBody:emailBody isHTML:NO];
            
            UIImage *img = nil;
            if (self.tweetImageView.image) {
                img = self.tweetImageView.image;
            }
            
            if (img) {
                NSData *imageData = UIImageJPEGRepresentation(img, 0.8);
                [picker addAttachmentData:imageData mimeType:@"image/jpeg" fileName:NSLocalizedString(@"微博图片", nil)];
            }
            
            [[[UIApplication sharedApplication] rootViewController] presentModalViewController:picker animated:YES];
            [picker release];
            
            break;
        case 5:
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"删除此条微博", nil)
                                               message:nil
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                     otherButtonTitles:NSLocalizedString(@"删除", nil), nil];
            alert.tag = -2;
            [alert show];
            [alert release];
            break;
        default:
            break;
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error
{
    NSString *message = nil;
    switch (result)
    {
        case MFMailComposeResultSaved:
            message = NSLocalizedString(@"保存成功", nil);
            [[[UIApplication sharedApplication] rootViewController] dismissModalViewControllerAnimated:YES];
            break;
        case MFMailComposeResultSent:
            message = NSLocalizedString(@"发送成功", nil);
            [[[UIApplication sharedApplication] rootViewController] dismissModalViewControllerAnimated:YES];
            break;
        case MFMailComposeResultFailed:
            message = NSLocalizedString(@"发送失败", nil);
            break;
        default:
            [[[UIApplication sharedApplication] rootViewController] dismissModalViewControllerAnimated:YES];
            return;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message 
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}


- (void)deleteCardFromCoreData
{
	NSManagedObjectContext *managedContext = [self.status managedObjectContext];
	[managedContext deleteObject:self.status];
	[managedContext processPendingChanges];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        WeiboClient *client = [WeiboClient client];
        [client setCompletionBlock:^(WeiboClient *client) {
            if (!client.hasError) {
                
                //remain to be solved;
               	NSManagedObjectContext *managedContext = [self.status managedObjectContext];
				[managedContext deleteObject:self.status];
				[managedContext processPendingChanges];
				
                //				 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameCardShouldDeleteCard object:self];
                //				
                //				[self performSelector:@selector(deleteCardFromCoreData) withObject:nil afterDelay:5.0];
				
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameCardDeleted object:self];
            } else {
                [ErrorNotification showOperationError];
            }
        }];
        [client destroyStatus:self.status.statusID];
    }
}


- (IBAction)profileImageButtonClicked:(id)sender {
    UserCardViewController *vc = [[UserCardViewController alloc] initWithUsr:self.status.author];
    vc.currentUser = self.currentUser;
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    vc.delegate = self;
    
    UserCardNaviViewController* navi = [[UserCardNaviViewController alloc] initWithRootViewController:vc];
    [UserCardNaviViewController setSharedUserCardNaviViewController:navi];
    
    navi.modalPresentationStyle = UIModalPresentationCurrentContext;
    navi.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameModalCardPresented object:self];
    
    [self presentModalViewController:navi animated:YES];
    [navi release];
    [vc release];
}

- (void)atUserClicked:(NSString*)screenName {
    WeiboClient *client = [WeiboClient client];
    
    [client setCompletionBlock:^(WeiboClient *client) {
        if (!client.hasError) {
            NSDictionary *userDict = client.responseJSONObject;
            User* atUser = [User insertUser:userDict inManagedObjectContext:self.managedObjectContext];
			
            UserCardViewController *vc = [[UserCardViewController alloc] initWithUsr:atUser];
            [vc setRelationshipState];
            vc.currentUser = self.currentUser;
            vc.modalPresentationStyle = UIModalPresentationCurrentContext;
            vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            vc.delegate = self;
            
            UserCardNaviViewController* navi = [[UserCardNaviViewController alloc] initWithRootViewController:vc];
            [UserCardNaviViewController setSharedUserCardNaviViewController:navi];
            
            navi.modalPresentationStyle = UIModalPresentationCurrentContext;
            navi.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameModalCardPresented object:self];
            
            [self presentViewController:navi animated:YES completion:nil];
            [navi release];
            [vc release];
        }
        else
        {
            // alert
            NSString *msg = [[[NSString alloc] initWithFormat:@"VCard 无法找到名为 \"%@\" 的新浪微博用户", screenName] autorelease];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"未找到此用户", nil)
                                  message:NSLocalizedString(msg, nil)
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"关闭", nil)
                                  otherButtonTitles:nil];
            
            [alert show];
            [alert release];
        }
    }];
    
    [client getUserByScreenName:screenName];    
}

- (void)userCardViewControllerDidDismiss:(UserCardViewController *)vc
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameModalCardDismissed object:self];    
}

- (void)shouldDismissUserCardNotification:(id)sender 
{
    [UserCardNaviViewController sharedUserCardDismiss];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameModalCardDismissed object:self];
}

- (IBAction)commentButtonClicked:(id)sender {
    CommentsTableViewController *vc = [[CommentsTableViewController alloc] init];
    vc.dataSource = CommentsTableViewDataSourceCommentsOfStatus;
    vc.currentUser = self.currentUser;
    vc.delegate = self;
    vc.status = self.status;
    vc.commentsTableViewModel = CommentsTableViewNormalModel;
    
    
    UserCardNaviViewController* navi = [[UserCardNaviViewController alloc] initWithRootViewController:vc];
    [UserCardNaviViewController setSharedUserCardNaviViewController:navi];
    
    navi.modalPresentationStyle = UIModalPresentationCurrentContext;
    navi.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameModalCardPresented object:self];
    
    //    [self presentModalViewController:navi animated:YES];
	[self presentViewController:navi animated:YES completion:nil];
    [navi release];
    [vc release];
    
    //    [self presentModalViewController:vc animated:YES];
    //    [vc release];
}

- (void)postWithContent:(NSString* )content
{
    PostViewController *vc = [[PostViewController alloc] initWithType:PostViewTypePost];
    [[UIApplication sharedApplication] presentModalViewController:vc atHeight:kModalViewHeight];
    vc.textView.text = content;
    
    [vc release];
}

- (void)commentsTableViewControllerDidDismiss:(CommentsTableViewController *)vc
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameModalCardDismissed object:self];
}

- (IBAction)repostButtonClicked:(id)sender {
    PostViewController *vc = [[PostViewController alloc] initWithType:PostViewTypeRepost];
    vc.targetStatus = self.status;
    [[UIApplication sharedApplication] presentModalViewController:vc atHeight:kModalViewHeight];
    [vc release];
}

- (IBAction)addFavButtonClicked:(UIButton *)sender {
    if ([self.currentUser.favorites containsObject:self.status]) {
        WeiboClient *client = [WeiboClient client];
        [client setCompletionBlock:^(WeiboClient *client) {
            if (!client.hasError) {
                [self.currentUser removeFavoritesObject:self.status];
                sender.selected = NO;
            } else {
                [ErrorNotification showOperationError];
            }
        }];
        [client unFavorite:self.status.statusID];
    }
    else {
        WeiboClient *client = [WeiboClient client];
        [client setCompletionBlock:^(WeiboClient *client) {
            if (!client.hasError) {
                //remain to be solved;
                [self.currentUser addFavoritesObject:self.status];
                
                sender.selected = YES;
				
				[[UIApplication sharedApplication] showOperationDoneView];
                
            } else {
                [ErrorNotification showOperationError];
            }
        }];
        [client favorite:self.status.statusID];
    }
    
}

#pragma mark – 
#pragma mark UIWebViewDelegate 

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType { 
    
    NSString* s = request.mainDocumentURL.relativePath;
    NSLog(@"%@", s);
    
    NSString* type = [s substringToIndex:4];
    NSString* para = [s substringFromIndex:4];
    
    if ([type compare:@"/at/"] == NSOrderedSame) {
        //        NSLog(@"at %@", para);
        //        NSString* content = [[NSString alloc] initWithFormat:@"@%@ ", para];
        //        [self postWithContent:content];
        [self atUserClicked:para];
    }
    else if ([type compare:@"/sp/"] == NSOrderedSame) {
        //        NSLog(@"sp %@", para);
		
		//REMAIN_TO
        NSString* content = [[[NSString alloc] initWithFormat:@"#%@# ", para] autorelease];
        [self postWithContent:content];
    }
    else if ([type compare:@"/lk/"] == NSOrderedSame) {
        //        NSLog(@"lk %@", para);
        [self openLinkInInnerBroswer:para];
    }
    
    return true; 
}

@end
