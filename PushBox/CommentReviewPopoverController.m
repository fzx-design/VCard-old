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

@synthesize statusView = _statusView;

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

+(CommentReviewPopoverController*)sharedCommentReviewPopoverController
{
	if (sharedCommentReviewPopoverController != nil) {
		return sharedCommentReviewPopoverController;
	}
	sharedCommentReviewPopoverController = [[CommentReviewPopoverController alloc] init];
	return sharedCommentReviewPopoverController;
}

- (void)prepare
{
	self.screenNameLabel.text = self.status.author.screenName;
	
    self.dateLabel.text = [self.status.createdAt stringRepresentation];
	
	self.tweetTextLabel.text = self.status.text;
	
	NSManagedObjectContext* context = [(PushBoxAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSString *profileImageString = self.status.author.profileImageURL;
    [self.profileImageView loadImageFromURL:profileImageString 
                                 completion:NULL
                             cacheInContext:context];
//	
//	NSString *tweetImageString = self.status.bmiddlePicURL;
//	[self.tweetImageView loadImageFromURL:tweetImageString
//							   completion:NULL 
//						   cacheInContext:self.managedObjectContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self prepare];
	[self.view addSubview:self.statusView];
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
	tapGesture.numberOfTapsRequired = 1;
	tapGesture.numberOfTouchesRequired = 1;
	[self.tweetImageView addGestureRecognizer:tapGesture];
	[tapGesture release];
	
	[self.statusView.layer addAnimation:[AnimationProvider popoverAnimation] forKey:nil];
	CGRect frame = self.statusView.frame;
	frame.origin.x = 690;
	frame.origin.y = 8;
	self.statusView.frame = frame;
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

- (IBAction)dismissButtonClicked:(id)sender
{
	[sharedCommentReviewPopoverController.view removeFromSuperview];
	[sharedCommentReviewPopoverController release];
	sharedCommentReviewPopoverController = nil;
}

@end
