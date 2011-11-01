//
//  CommentReviewPopoverController.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-26.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "CommentReviewPopoverController.h"
#import "User.h"
#import "AnimationProvider.h"
#import "NSDateAddition.h"
#import "UIImageViewAddition.h"

@implementation CommentReviewPopoverController

static CommentReviewPopoverController* sharedCommentReviewPopoverController;

@synthesize profileImageView = _profileImageView;
@synthesize screenNameLabel = _screenNameLabel;
@synthesize dateLabel = _dateLabel;
@synthesize actionsButton = _actionsButton;
@synthesize tweetImageView = _tweetImageView;
@synthesize tweetTextLabel = _tweetTextLabel;
@synthesize repostTextLabel = _repostTextLabel;
@synthesize postTextView = _postTextView;
@synthesize repostTextView = _repostTextView;
@synthesize repostBackgroundImageView = _repostBackgroundImageView;
@synthesize scrollView = _scrollView;

@synthesize statusView = _statusView;

@synthesize commentsTableViewModel = _commentsTableViewModel;

@synthesize status = _status;

#pragma mark - View lifecycle

- (void)dealloc
{
	[_profileImageView release];
    [_screenNameLabel release];
    [_dateLabel release];
    [_actionsButton release];
    [_tweetImageView release];
    [_tweetTextLabel release];
	[_statusView release];
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
    self.tweetImageView = nil;
    self.tweetTextLabel = nil;
	self.statusView = nil;
}

+(CommentReviewPopoverController*)sharedCommentReviewPopoverControllerWithTableType:(CommentsTableViewModel)type
{
	if (sharedCommentReviewPopoverController != nil) {
		sharedCommentReviewPopoverController.commentsTableViewModel = type;
		return sharedCommentReviewPopoverController;
	}
	
	sharedCommentReviewPopoverController = [[CommentReviewPopoverController alloc] init];
	sharedCommentReviewPopoverController.commentsTableViewModel = type;
	return sharedCommentReviewPopoverController;
}

- (void)prepare
{
	NSManagedObjectContext* context = [(PushBoxAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSString *profileImageString = self.status.author.profileImageURL;
    [self.profileImageView loadImageFromURL:profileImageString 
                                 completion:NULL
                             cacheInContext:context];
    
	self.screenNameLabel.text = self.status.author.screenName;
	
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [components setHour:0];
    NSDate *today0am = [calendar dateFromComponents:components];  
    
    NSTimeInterval time = [today0am timeIntervalSinceDate:self.status.createdAt];
    int days = ((int)time)/(3600*24);
    if (time < 0) {
        days = -1;
    }
    days++;
    
    NSString* dateStr;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"HH:mm" options:0 locale:[NSLocale currentLocale]]];
    NSString* timeStr = [dateFormatter stringFromDate:self.status.createdAt];
    switch (days) {
        case 0:
            dateStr = [[NSString alloc] initWithFormat:@"%@ 今天",timeStr];
            break;
        case 1:
            dateStr = [[NSString alloc] initWithFormat:@"%@ 昨天",timeStr];
            break;
        case 2:
            dateStr = [[NSString alloc] initWithFormat:@"%@ 前天",timeStr];
            break;
        case 3:
        case 4:
        case 5:
            dateStr = [[NSString alloc] initWithFormat:@"%@ %d天前",timeStr, days];
        default:
            dateStr = [self.status.createdAt stringRepresentation];
            break;
    }
    self.dateLabel.text = dateStr;
    
	self.postTextView.text = self.status.text;
    [self.postTextView sizeToFit];
    self.scrollView.contentSize = CGSizeMake(289, self.postTextView.frame.origin.y + self.postTextView.frame.size.height + 10);
    if (self.status.bmiddlePicURL) {
        [self.tweetImageView loadImageFromURL:self.status.bmiddlePicURL 
                                   completion:^(void) {
                                       CGRect frame = self.tweetImageView.frame;
                                       //                                       frame.size = self.tweetImageView.image.size;
                                       frame.origin.y = self.postTextView.frame.origin.y + self.postTextView.frame.size.height + 8;
                                       self.tweetImageView.frame = frame;
                                       
                                       self.scrollView.contentSize = CGSizeMake(289, self.tweetImageView.frame.origin.y + self.tweetImageView.frame.size.height + 10);
                                   }
                               cacheInContext:context];
    }
    
    if (self.status.repostStatus) {
        self.repostTextView.text = self.status.repostStatus.text;
        [self.repostTextView sizeToFit];
        self.repostTextView.hidden = NO;
        
        CGRect frame = self.repostBackgroundImageView.frame;
        frame.origin.y = self.postTextView.frame.origin.y + self.postTextView.frame.size.height;
        self.repostBackgroundImageView.frame = frame;
        self.repostBackgroundImageView.hidden = NO;
        
        frame = self.repostTextView.frame;
        frame.origin.y = self.postTextView.frame.origin.y + self.postTextView.frame.size.height + 8;
        self.repostTextView.frame = frame;
        
        self.scrollView.contentSize = CGSizeMake(289, self.repostBackgroundImageView.frame.origin.y + self.repostBackgroundImageView.frame.size.height + 10);
        
        if (self.status.repostStatus.bmiddlePicURL) {
            [self.tweetImageView loadImageFromURL:self.status.repostStatus.bmiddlePicURL 
                                       completion:^(void) {
                                           CGRect frame = self.tweetImageView.frame;
                                           //                                           frame.size = self.tweetImageView.image.size;
                                           frame.origin.y = self.repostTextView.frame.origin.y + self.repostTextView.frame.size.height + 8;
                                           self.tweetImageView.frame = frame;
                                           
                                           self.scrollView.contentSize = CGSizeMake(289, self.tweetImageView.frame.origin.y + self.tweetImageView.frame.size.height + 10);
                                       }
                                   cacheInContext:context];
        }
    }    
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self prepare];
	[self.view addSubview:self.statusView];
    
	self.statusView.layer.anchorPoint = CGPointMake(0, 0.5);
	[self.statusView.layer addAnimation:[AnimationProvider popoverAnimation] forKey:nil];
	CGRect frame = self.statusView.frame;
	if (_commentsTableViewModel == CommentsTableViewNormalModel) {
		frame.origin.x = 680;
		frame.origin.y = -3;
	} else {
		frame.origin.x = 700;
		frame.origin.y = 85;
	}
	
    
	self.statusView.frame = frame;
}

- (void)commentFinished
{
	[self dismissButtonClicked:nil];
	
}

- (IBAction)commentButtonClicked:(id)sender
{
	CommentViewController *vc = [[CommentViewController alloc] init];
	vc.delegate = self;
	vc.targetStatus = self.status;
	
	[[UIApplication sharedApplication] presentModalViewController:vc atHeight:kModalViewHeight];
	[vc release];
}

- (IBAction)dismissButtonClicked:(id)sender
{
	[UIView animateWithDuration:0.3 animations:^(){
		sharedCommentReviewPopoverController.statusView.alpha = 0.0;
	}completion:^(BOOL finished) {
		[sharedCommentReviewPopoverController.view removeFromSuperview];
		[sharedCommentReviewPopoverController release];
		sharedCommentReviewPopoverController = nil;
	}];
}

@end
