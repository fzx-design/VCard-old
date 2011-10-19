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
@synthesize repostTextView = _repostTextView;
@synthesize repostView = _repostView;
@synthesize repostTweetImageView = _repostTweetImageView;
@synthesize trackLabel = _trackLabel;
@synthesize trackButton = _trackButton;

@synthesize status = _status;

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
    
    self.tweetTextView.font = [self.tweetTextView.font fontWithSize:18];
	self.repostTextView.font = [self.repostTextView.font fontWithSize:14];
    
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
	self.tweetImageView.image = nil;
	self.tweetImageView.hidden = YES;
	
	self.repostTweetImageView.hidden = YES;
	self.repostTweetImageView.image = nil;
    
    self.repostView.hidden = YES;
    
    self.trackButton.hidden = YES;
    self.trackLabel.text = @"";
    self.trackLabel.hidden = YES;
    
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
    [[self.tweetImageView layer] setCornerRadius:15.0];
    [[self.repostTweetImageView layer] setCornerRadius:15.0];
}

- (void)loadStatusImage
{
    [self.tweetImageView loadImageFromURL:self.status.originalPicURL 
                               completion:^(void) 
     {
         //////
     } 
                           cacheInContext:self.managedObjectContext];
}

- (void)loadRepostStautsImage
{
    Status *repostStatus = self.status.repostStatus;
    [self.repostTweetImageView loadImageFromURL:repostStatus.originalPicURL 
                                     completion:^(void) 
     {
         //////
     }
                                 cacheInContext:self.managedObjectContext];
}

- (void)update
{	
	BOOL imageLoadingEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultKeyImageDownloadingEnabled];
    
    Status *status = self.status;
    // post text
    self.tweetTextView.text = self.status.text;
    // post image
    if (imageLoadingEnabled && self.status.originalPicURL) {
		self.tweetImageView.hidden = NO;
        [self performSelector:@selector(loadStatusImage) withObject:nil afterDelay:kLoadDelay];
    }
    // post music or video
    else if (NO)
    {
        
    }
    // post no pmv
    else
    {
        if (self.status.repostStatus) {
            Status *repostStatus = self.status.repostStatus;
            
            // repost text
            self.repostTextView.text = [NSString stringWithFormat:@"@%@: %@", repostStatus.author.screenName, repostStatus.text];
            self.repostView.hidden = NO;
            // repost image
            if (imageLoadingEnabled && repostStatus.originalPicURL.length) {
                self.repostTweetImageView.hidden = NO;
                [self performSelector:@selector(loadRepostStautsImage) withObject:nil afterDelay:kLoadDelay];
            }
            // repost music or video
            else if (NO)
            {
                
            }
        }
        
        // no repost
        else
        {
            NSString* trackString = [[NSString alloc] initWithFormat:@"更多进展，请询问%@@", status.author.screenName];
            self.trackLabel.text = trackString;
            self.trackLabel.hidden = NO;
            self.trackButton.hidden = NO;
        }
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
@end
