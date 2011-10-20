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
#import "UIImageViewAddition.h"
#import "NSDateAddition.h"
#import "OptionsTableViewController.h"
#import "UIApplicationAddition.h"
#import "WeiboClient.h"

#define kLoadDelay 1.5
#define kPlayButtonFrameTopRight CGRectMake(399, 306, 68, 68)
#define kPlayButtonFrameCenter CGRectMake(251, 373, 68, 68)
#define kRepostViewFrameTop CGRectMake(57, 275, 451, 129)
#define kRepostWebViewFrameTop CGRectMake(65, 287, 433, 106)
#define kRepostViewFrameBottom CGRectMake(57, 275+125, 451, 129)
#define kRepostWebViewFrameBottom CGRectMake(65, 287+125, 433, 106)

@implementation SmartCardViewController

@synthesize profileImageView = _profileImageView;
@synthesize screenNameLabel = _screenNameLabel;
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
@synthesize repostTweetImageView = _repostTweetImageView;
@synthesize trackLabel = _trackLabel;
@synthesize trackView = _trackView;
@synthesize imageCoverImageView = _imageCoverImageView;
@synthesize musicBackgroundImageView = _musicBackgroundImageView;
@synthesize musicCoverImageView = _musicCoverImageView;
@synthesize playButton = _playButton;

@synthesize status = _status;
@synthesize postMusicVideoLink;
@synthesize repostMusicVideoLink;

- (void)dealloc
{    
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
    [_repostTweetImageView release];
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
    self.repostTweetImageView = nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"smartcard" ofType:@"js"];  
    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath];  
    [self.postWebView stringByEvaluatingJavaScriptFromString:jsString];  
    [self.repostWebView stringByEvaluatingJavaScriptFromString:jsString];  
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
	tapGesture.numberOfTapsRequired = 1;
	tapGesture.numberOfTouchesRequired = 1;
	[self.tweetImageView addGestureRecognizer:tapGesture];
	[tapGesture release];
	
	tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
	tapGesture.numberOfTapsRequired = 1;
	tapGesture.numberOfTouchesRequired = 1;
	[self.repostTweetImageView addGestureRecognizer:tapGesture];
	[tapGesture release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shouldDismissUserCardNotification:)
                                                 name:kNotificationNameShouldDismissUserCard
                                               object:nil];
}

- (void)imageViewClicked:(UIGestureRecognizer *)ges
{
	UIView *mainView = [[UIApplication sharedApplication] rootView];
	
	UIImageView *imageView = (UIImageView *)ges.view;
	
	DetailImageViewController *dvc = [[DetailImageViewController alloc] initWithImage:imageView.image];
	dvc.delegate = self;
	dvc.view.alpha = 0.0;
	[mainView addSubview:dvc.view];
	
	[UIView animateWithDuration:0.5 animations:^{
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


- (void)prepare
{		
    self.postMusicVideoLink = nil;
    self.repostMusicVideoLink = nil;
    
	self.tweetImageView.image = nil;
	self.tweetImageView.alpha = 0.0;
	
	self.repostTweetImageView.alpha = 0.0;
	self.repostTweetImageView.image = nil;
    
    self.imageCoverImageView.alpha = 0.0;
    
    self.repostView.alpha = 0.0;
    
    self.postWebView.alpha = 0.0;
    self.repostWebView.alpha = 0.0;
    
    self.repostView.frame = kRepostViewFrameTop;
    self.repostWebView.frame = kRepostWebViewFrameTop;
    
    self.trackView.hidden = YES;
    self.trackLabel.text = @"";
    self.trackView.alpha = 0.0;
    self.trackLabel.alpha = 0.0;
    
    self.playButton.hidden = YES;
    self.musicBackgroundImageView.alpha = 0.0;
    self.playButton.frame = kPlayButtonFrameCenter;
    
	self.profileImageView.image = nil;
	self.screenNameLabel.text = self.status.author.screenName;
    self.dateLabel.text = [self.status.createdAt stringRepresentation];
	
    self.commentCountLabel.text = self.status.commentsCount;
    self.repostCountLabel.text = self.status.repostsCount;
	
	self.tweetTextView.text = @"";
    self.repostTextView.text = @"";
    
    NSString *profileImageString = self.status.author.profileImageURL;
    [self.profileImageView loadImageFromURL:profileImageString 
                                 completion:NULL
                             cacheInContext:self.managedObjectContext];
    
    //
    [[self.tweetImageView layer] setCornerRadius:20.0];
    [[self.repostTweetImageView layer] setCornerRadius:20.0];
}

- (void)loadStatusImage
{
    self.tweetImageView.hidden = NO;
    self.imageCoverImageView.hidden = NO;
    [self.tweetImageView loadImageFromURL:self.status.originalPicURL 
                               completion:^(void) 
     {
         self.tweetImageView.alpha = 0.0;
         self.imageCoverImageView.alpha = 0.0;
         [UIView animateWithDuration:0.5 delay:0.3 options:0 animations:^{
             self.tweetImageView.alpha = 1.0;
             self.imageCoverImageView.alpha = 1.0;
         } completion:^(BOOL fin) {
         }];
     } 
                           cacheInContext:self.managedObjectContext];
}

- (void)loadRepostStautsImage
{
    self.repostTweetImageView.hidden = NO;
    self.imageCoverImageView.hidden = NO;
    Status *repostStatus = self.status.repostStatus;
    [self.repostTweetImageView loadImageFromURL:repostStatus.originalPicURL 
                                     completion:^(void) 
     {
         self.repostTweetImageView.alpha = 0.0;
         [UIView animateWithDuration:0.5 delay:0.3 options:0 animations:^{
             self.repostTweetImageView.alpha = 1.0;
         } completion:^(BOOL fin) {
         }];
     }
                                 cacheInContext:self.managedObjectContext];
}

- (void)loadPostWebView
{
    NSString* originStatus = self.status.text;
    NSString* phasedStatus = self.status.text;
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
                int j = i + 1;
                for (j = i + 1; j < originStatus.length; j++) {
                    if ([originStatus characterAtIndex:j] == ' '|| [originStatus characterAtIndex:j] == ':') {
                        break;
                    }
                };
                endIndex = j;
                if(startIndex < endIndex)
                {
                    NSRange range = NSMakeRange(startIndex, endIndex-startIndex);
                    NSString* subStr = [originStatus substringWithRange:range];
                    phasedStatus = [phasedStatus stringByReplacingOccurrencesOfString:subStr withString:[[NSString alloc] initWithFormat:@"<span class='highlight'><a href='#'>%@</a></span>", subStr]];
                }
                break;
            }
            case '#':
            {
                for (int j = i + 1; j < originStatus.length; j++) {
                    if ([originStatus characterAtIndex:j] == '#') {
                        endIndex = j;
                        break;
                    }
                }
                if(startIndex < endIndex)
                {
                    NSRange range = NSMakeRange(startIndex, endIndex+1-startIndex);
                    NSString* subStr = [originStatus substringWithRange:range];
                    phasedStatus = [phasedStatus stringByReplacingOccurrencesOfString:subStr withString:[[NSString alloc] initWithFormat:@"<span class='highlight'><a href='#'>%@</a></span>", subStr]];
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
                    int j = i + 1;
                    for (j = i + 1; j < originStatus.length; j++) {
                        if ([originStatus characterAtIndex:j] == ' ') {
                            break;
                        }
                    }
                    endIndex = j;
                    range = NSMakeRange(startIndex, endIndex-startIndex);
                    subStr = [originStatus substringWithRange:range];
                    phasedStatus = [phasedStatus stringByReplacingOccurrencesOfString:subStr withString:[[NSString alloc] initWithFormat:@"<span class='highlight'><a href='linkClicked()' onClick='linkClicked()'>%@</a></span>", subStr]];
                }
                break;
            }
            default:
                break;
        }
    }
    
    //    NSString* htmlText = [[NSString alloc] initWithFormat:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\" /><style type=\"text/css\">@import url(\"smartcard.css\");</style></head><body><div id=\"post\">%@</div></body></html>", phasedStatus];
    NSString* htmlText = [[NSString alloc] initWithFormat:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\" /><link href=\"smartcard.css\" rel=\"stylesheet\" type=\"text/css\" /></head><body><div id=\"post\">%@</div></body></html>", phasedStatus];
    //    NSLog(htmlText);
    NSString *path = [[NSBundle mainBundle] pathForResource:@"smartcard" ofType:@"html"]; 
    [self.postWebView loadHTMLString:htmlText baseURL:[NSURL fileURLWithPath: path]];
    
    self.postWebView.alpha = 0.0;
    [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
        self.postWebView.alpha = 1.0;
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
                int j = i + 1;
                for (j = i + 1; j < originStatus.length; j++) {
                    if ([originStatus characterAtIndex:j] == ' '|| [originStatus characterAtIndex:j] == ':') {
                        break;
                    }
                };
                endIndex = j;
                if(startIndex < endIndex)
                {
                    NSRange range = NSMakeRange(startIndex, endIndex-startIndex);
                    NSString* subStr = [originStatus substringWithRange:range];
                    phasedStatus = [phasedStatus stringByReplacingOccurrencesOfString:subStr withString:[[NSString alloc] initWithFormat:@"<span class='highlight'><a href='#'>%@</a></span>", subStr]];
                }
                break;
            }
            case '#':
            {
                for (int j = i + 1; j < originStatus.length; j++) {
                    if ([originStatus characterAtIndex:j] == '#') {
                        endIndex = j;
                        break;
                    }
                }
                if(startIndex < endIndex)
                {
                    NSRange range = NSMakeRange(startIndex, endIndex+1-startIndex);
                    NSString* subStr = [originStatus substringWithRange:range];
                    phasedStatus = [phasedStatus stringByReplacingOccurrencesOfString:subStr withString:[[NSString alloc] initWithFormat:@"<span class='highlight'><a href='#'>%@</a></span>", subStr]];
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
                    int j = i + 1;
                    for (j = i + 1; j < originStatus.length; j++) {
                        if ([originStatus characterAtIndex:j] == ' ') {
                            break;
                        }
                    }
                    endIndex = j;
                    range = NSMakeRange(startIndex, endIndex-startIndex);
                    subStr = [originStatus substringWithRange:range];
                    phasedStatus = [phasedStatus stringByReplacingOccurrencesOfString:subStr withString:[[NSString alloc] initWithFormat:@"<span class='highlight'><a href='linkClicked()' onClick='linkClicked()'>%@</a></span>", subStr]];
                }
                break;
            }
            default:
                break;
        }
    }
    
    //    NSString* htmlText = [[NSString alloc] initWithFormat:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\" /><style type=\"text/css\">@import url(\"smartcard.css\");</style></head><body><div id=\"post\">%@</div></body></html>", phasedStatus];
    NSString* htmlText = [[NSString alloc] initWithFormat:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\" /><link href=\"smartcard.css\" rel=\"stylesheet\" type=\"text/css\" /><script type='text/javascript' src='smartcard.js'></script></head><body><div id=\"repost\"><span class='highlight'><a href='#'>@%@</a></span>: %@</div></body></html>", self.status.repostStatus.author.screenName, phasedStatus];
    //    NSLog(htmlText);
    NSString *path = [[NSBundle mainBundle] pathForResource:@"smartcard" ofType:@"html"]; 
    [self.repostWebView loadHTMLString:htmlText baseURL:[NSURL fileURLWithPath: path]];
    
    self.repostWebView.alpha = 0.0;
    self.repostView.alpha = 0.0;
    self.imageCoverImageView.alpha = 0.0;
    [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
        self.repostWebView.alpha = 1.0;
        self.repostView.alpha = 1.0;
        self.imageCoverImageView.alpha = 1.0;
    } completion:^(BOOL fin) {
    }];
    
}

- (void)loadPostMusicVideo:(NSString*)postMusicVideoLink
{    
    self.playButton.hidden = NO;
    isTrack = NO;
    self.playButton.frame = kPlayButtonFrameCenter;
}

- (void)loadRepostMusicVideo:(NSString*)repostMusicVideoLink
{
    self.playButton.hidden = NO;
    self.playButton.frame = kPlayButtonFrameTopRight;
    self.repostView.frame = kRepostViewFrameBottom;
    self.repostWebView.frame = kRepostWebViewFrameBottom;
    self.imageCoverImageView.alpha = 0.0;
    self.musicBackgroundImageView.alpha = 0.0;
    self.repostTweetImageView.alpha = 1.0;
    [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
        self.imageCoverImageView.alpha = 1.0;
        self.musicBackgroundImageView.alpha = 1.0;
        self.repostTweetImageView.alpha = 0.0;
    } completion:^(BOOL fin) {
    }];
    
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
                int j = i + 1;
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
                            
                            
                            if ([longUrl rangeOfString:@"http://v.youku.com"].location != NSNotFound || [longUrl rangeOfString:@"http://video.sina.com"].location != NSNotFound || [longUrl rangeOfString:@"http://www.tudou.com"].location != NSNotFound || [longUrl rangeOfString:@"http://v.ku6.com"].location != NSNotFound || [longUrl rangeOfString:@"http://www.56.com"].location != NSNotFound || [longUrl rangeOfString:@"http://music.sina.com"].location != NSNotFound || [longUrl rangeOfString:@"xiami.com"].location != NSNotFound || [longUrl rangeOfString:@"songtaste.com"].location != NSNotFound)
                            {
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
                int j = i + 1;
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
                            
                            
                            if ([longUrl rangeOfString:@"http://v.youku.com"].location != NSNotFound || [longUrl rangeOfString:@"http://video.sina.com"].location != NSNotFound || [longUrl rangeOfString:@"http://www.tudou.com"].location != NSNotFound || [longUrl rangeOfString:@"http://v.ku6.com"].location != NSNotFound || [longUrl rangeOfString:@"http://www.56.com"].location != NSNotFound || [longUrl rangeOfString:@"http://music.sina.com"].location != NSNotFound|| [longUrl rangeOfString:@"xiami.com"].location != NSNotFound || [longUrl rangeOfString:@"songtaste.com"].location != NSNotFound)
                            {
                                isTrack = NO;
                                [self loadRepostMusicVideo:longUrl];
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

- (void)update
{	
	BOOL imageLoadingEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultKeyImageDownloadingEnabled];
    
    Status *status = self.status;
    isTrack = YES;
    // post text
    [self loadPostWebView];
    // post image
    if (imageLoadingEnabled && self.status.originalPicURL) {
        [self performSelector:@selector(loadStatusImage) withObject:nil afterDelay:kLoadDelay];
        isTrack = NO;
    }
    // post music or video
    if (YES)
    {
        [self getPostMusicVideoLink:status.text];
    }
    
    if (self.status.repostStatus) {
        Status *repostStatus = self.status.repostStatus;
        self.imageCoverImageView.hidden = NO;
        isTrack = NO;
        // repost text
        [self loadRepostWebView];
        // repost image
        if (imageLoadingEnabled && repostStatus.originalPicURL.length) {
            [self performSelector:@selector(loadRepostStautsImage) withObject:nil afterDelay:kLoadDelay];
        }
        // repost music or video
        if (YES)
        {
            [self getRepostMusicVideoLink:repostStatus.text];
        }
    }
    
    // Track
    if (isTrack)
        //    if (NO)
    {
        NSString* trackString = [[NSString alloc] initWithFormat:@"询问 %@", status.author.screenName];
        self.trackLabel.text = trackString;
        self.trackLabel.hidden = NO;
        self.trackView.hidden = NO;
        self.imageCoverImageView.hidden = YES;
        [UIView animateWithDuration:0.5 delay:1.0 options:0 animations:^{
            self.trackLabel.alpha = 1.0;
            self.trackView.alpha = 1.0;
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
    
    [self prepare];
    [self performSelector:@selector(update) withObject:nil afterDelay:0.5];
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
		actionSheet.destructiveButtonIndex = 3;
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
			else if (self.repostTweetImageView.image) {
				img = self.repostTweetImageView.image;
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        WeiboClient *client = [WeiboClient client];
        [client setCompletionBlock:^(WeiboClient *client) {
            if (!client.hasError) {
                [self.managedObjectContext deleteObject:self.status];
                [self.managedObjectContext processPendingChanges];
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
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameModalCardPresented object:self];
    
    [self presentModalViewController:vc animated:YES];
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
            }
        }];
        [client unFavorite:self.status.statusID];
    }
    else {
        WeiboClient *client = [WeiboClient client];
        [client setCompletionBlock:^(WeiboClient *client) {
            if (!client.hasError) {
                [self.currentUser addFavoritesObject:self.status];
                sender.selected = YES;
                
                UIImage *img = [UIImage imageNamed:@"status_msg_addfav"];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
                imageView.center = self.view.center;
                [self.view addSubview:imageView];
                [imageView release];
                [imageView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2.0];
            }
        }];
        [client favorite:self.status.statusID];
    }
    
}

#pragma mark – 
#pragma mark UIWebViewDelegate 
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType { 
    if ( [request.mainDocumentURL.relativePath isEqualToString:@"/click/false"] ) {    
        NSLog( @"not clicked" ); 
        return false; 
    } 
    if ( [request.mainDocumentURL.relativePath isEqualToString:@"/click/true"] ) {        //the image is clicked, variable click is true 
        NSLog( @"image clicked" ); 
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"JavaScript called" 
                                                     message:@"You’ve called iPhone provided control from javascript!!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil]; 
        [alert show]; 
        [alert release]; 
        return false; 
    } 
    return true; 
} 

@end
