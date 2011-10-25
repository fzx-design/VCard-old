//
//  RootViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RootViewController.h"
#import "WeiboClient.h"
#import "UIApplicationAddition.h"
#import "AnimationProvider.h"
#import "Status.h"
#import "User.h"

#define kLoginViewCenter CGPointMake(512.0, 370.0)

#define kDockViewFrameOriginY 625.0

#define kDockViewOffsetY 635.0
#define kDockAnimationInterval 0.3

#define kCardTableViewFrameOriginY 37.0
#define kCardTableViewOffsetY 650.0

#define kMessagesViewCenter CGPointMake(512.0 - 1024.0, 350.0)
#define kMessagesViewOffsetx 1024.0

#define kUserDefaultKeyFirstTime @"kUserDefaultKeyFirstTime"


@interface RootViewController(private)
- (void)showBottomStateView;
- (void)hideBottomStateView;
- (void)showLoginView;
- (void)hideLoginView;
- (void)showDockView;
- (void)hideDockView;
- (void)moveCardIntoView;
- (void)showMessagesView;
- (void)hideMessagesView;
- (void)showMessagesCenter;
- (void)hideMessagesCenter;
- (void)showCommandCenter;
- (void)hideCommandCenter;
- (void)showCardTableView;
- (void)hideCardTableView;
- (void)showNotificationView:(id)sender;
- (void)setDefaultBackgroundImage:(BOOL)animated;
- (void)updateBackgroundImageAnimated:(BOOL)animated;
@end

@implementation RootViewController

@synthesize backgroundImageView = _backgroundImageView;
@synthesize pushBoxHDImageView = _pushBoxHDImageView;
@synthesize bottomStateFrameView = _bottomStateFrameView;
@synthesize bottomStateView = _bottomStateView;
@synthesize bottomStateInvisibleView = _bottomStateInvisibleView;
@synthesize bottomBackButton = _bottomBackButton;
@synthesize bottomStateLabel = _bottomStateLabel;
@synthesize bottomStateTextField = _bottomStateTextField;
@synthesize loginViewController = _loginViewController;
@synthesize dockViewController = _dockViewController;
@synthesize messagesViewController = _messagesViewController;
@synthesize cardTableViewController = _cardTableViewController;

@synthesize notificationView = _notificationView;
@synthesize notiNewCommentLabel = _notiNewCommentLabel;
@synthesize notiNewFollowerLabel = _notiNewFollowerLabel;
@synthesize notiNewAtLabel = _notiNewAtLabel;

@synthesize notiCloseButton = _notiCloseButton;
@synthesize notiDisplayNewFollowersButton = _notiDisplayNewFollowersButton;
@synthesize notiDisplayNewMentionsButton = _notiDisplayNewMentionsButton;
@synthesize notiDisplayNewCommentsButton = _notiDisplayNewCommentsButton;


#pragma mark - View lifecycle

- (void)dealloc
{
    [_backgroundImageView release];
    [_pushBoxHDImageView release];
    [_bottomStateView release];
    [_bottomStateLabel release];
    [_loginViewController release];
    [_dockViewController release];
    [_cardTableViewController release];
	[_tmpImage release];
	[_notificationView release];
	[_notiNewCommentLabel release];
    [_notiNewFollowerLabel release];
    [_notiNewAtLabel release];
    [_notiCloseButton release];
    [_notiDisplayNewFollowersButton release];
    [_notiDisplayNewMentionsButton release];
    [_notiDisplayNewCommentsButton release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.backgroundImageView = nil;
    self.pushBoxHDImageView = nil;
    self.bottomStateView = nil;
    self.bottomStateLabel = nil;
	self.notificationView = nil;
	self.notiNewCommentLabel = nil;
    self.notiNewFollowerLabel = nil;
    self.notiNewAtLabel = nil;
	self.notiCloseButton = nil;
    self.notiDisplayNewFollowersButton = nil;
    self.notiDisplayNewMentionsButton = nil;
    self.notiDisplayNewCommentsButton = nil;
}

+ (void)initialize {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:30];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:kUserDefaultKeyFirstTime];
	[userDefault registerDefaults:dict];
}

- (void)start
{	
	preNewCommentCount = 0;
	preNewFollowerCount = 0;
	preNewMentionCount = 0;
	self.notificationView.hidden = YES;
	self.bottomStateFrameView.hidden = NO;
	
    WeiboClient *client = [WeiboClient client];
    [client setCompletionBlock:^(WeiboClient *client) {
        if (!client.hasError) {
            NSDictionary *userDict = client.responseJSONObject;
            self.currentUser = [User insertUser:userDict inManagedObjectContext:self.managedObjectContext];
        }
		
		[self updateBackgroundImageAnimated:YES];
		
		[[UIApplication sharedApplication] showLoadingView];
		
		self.cardTableViewController.dataSource = CardTableViewDataSourceFriendsTimeline;
		[self.cardTableViewController firstLoad:^(void) {
			[self.cardTableViewController loadAllFavoritesWithCompletion:nil];
			[self showCardTableView];
			[self showDockView];
			[self showMessagesView];
			[[UIApplication sharedApplication] hideLoadingView];
		}];
    }];
    
    [client getUser:[WeiboClient currentUserID]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDefaultBackgroundImage:NO];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(backgroundChangedNotification:) 
				   name:kNotificationNameBackgroundChanged 
				 object:nil];
    
    [center addObserver:self
               selector:@selector(modalCardViewPresentedNotification:)
                   name:kNotificationNameModalCardPresented
                 object:nil];
    
    [center addObserver:self
               selector:@selector(modalCardViewDismissedNotification:) 
                   name:kNotificationNameModalCardDismissed
                 object:nil];
    
    [center addObserver:self
               selector:@selector(shouldShowUserTimelineNotification:)
                   name:kNotificationNameShouldShowUserTimeline
                 object:nil];
    
    [center addObserver:self
               selector:@selector(userSignoutNotification:) 
                   name:kNotificationNameUserSignedOut 
                 object:nil];
	[center addObserver:self
			   selector:@selector(moveCardIntoView) 
				   name:kNotificationNameReMoveCardsIntoView 
				 object:nil];
	[center addObserver:self
			   selector:@selector(configureUsablityAfterDeleted) 
				   name:kNotificationNameCardDeleted 
				 object:nil];
	[center addObserver:self
			   selector:@selector(showNotificationView:) 
				   name:kNotificationNameNewNotification 
				 object:nil];
	[center addObserver:self 
			   selector:@selector(showMentionsNotification:) 
				   name:kNotificationNameShouldShowMentions 
				 object:nil];
	
    
    self.bottomStateView.alpha = 0.0;
	self.bottomStateInvisibleView.alpha = 0.0;
	_commandCenterFlag = NO;
	
    if ([WeiboClient authorized]) {
        self.pushBoxHDImageView.alpha = 0.0;
		self.currentUser = [User userWithID:[WeiboClient currentUserID] inManagedObjectContext:self.managedObjectContext];
        [self start];
    }
    else {
        [self showLoginView];
    }
}

- (void)userSignoutNotification:(id)sender
{
	preNewCommentCount = 0;
	preNewFollowerCount = 0;
	preNewMentionCount = 0;
	
    [WeiboClient signout];
    [self hideDockView];
    [self hideCardTableView];
	self.bottomStateFrameView.hidden = YES;
	[self hideBottomStateView];
	self.notificationView.hidden = YES;
	[self setDefaultBackgroundImage:YES];
    self.currentUser = nil;
    [User deleteAllObjectsInManagedObjectContext:self.managedObjectContext];
	[Status deleteAllObjectsInManagedObjectContext:self.cardTableViewController.mentionsManagedObjectContext];
    [self performSelector:@selector(showLoginView) withObject:nil afterDelay:1.0];
}

- (void)configureUsablityAfterDeleted
{
	[self.cardTableViewController configureUsability];
}

- (void)moveCardIntoView
{
	CGRect frame = self.cardTableViewController.tableView.frame;
	frame.origin.x += 782;
	self.cardTableViewController.tableView.frame = frame;
	
	self.cardTableViewController.tableView.alpha = 1.0;
	self.cardTableViewController.rootShadowLeft.alpha = 1.0;
	
    [UIView animateWithDuration:1.0 animations:^{
		
		CGRect frame = self.cardTableViewController.tableView.frame;
		frame.origin.x -= 782;
		self.cardTableViewController.tableView.frame = frame;
    }];
}

- (void)showBottomStateView
{
	if (self.bottomStateInvisibleView.image == nil) {
		self.bottomStateInvisibleView.image = _tmpImage;
		self.bottomStateInvisibleView.alpha = 1.0;
	}
	self.bottomStateView.alpha = 1.0;
	[self.bottomStateFrameView.layer addAnimation:[AnimationProvider cubeAnimation] forKey:@"animation"];
	[self.bottomStateFrameView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
	
	[self.bottomStateFrameView bringSubviewToFront:self.bottomStateView];
	self.bottomBackButton.enabled = YES;
}

- (void)showBottomStateViewForSearch
{
    self.dockViewController.searchButton.selected = YES;
    
    [UIView animateWithDuration:0.28 animations:^(void) {
        self.bottomStateView.alpha = 1.0;
        CGRect frame = self.bottomStateView.frame;
        frame.origin.y = 768 - 352 - 46 - 18;
        [self.bottomStateView setFrame:frame];
    }];
    
    self.bottomStateTextField.text = @"";
    self.bottomStateLabel.text = @"";
    self.bottomStateTextField.hidden = NO;
    self.bottomStateLabel.hidden = YES;
}

- (void)hideBottomStateViewForSearch
{
    self.dockViewController.searchButton.selected = NO;
    [self.bottomStateTextField resignFirstResponder];

    [UIView animateWithDuration:0.28 animations:^(void) {
        self.bottomStateView.alpha = 0.0;
        CGRect frame = self.bottomStateView.frame;
        frame.origin.y = 618;
        [self.bottomStateView setFrame:frame];
    }];
    
    self.bottomStateTextField.text = @"";
    self.bottomStateLabel.text = @"";
    self.bottomStateTextField.hidden = YES;
    self.bottomStateLabel.hidden = NO;
}

- (void)hideBottomStateView
{
	[self.bottomStateFrameView.layer addAnimation:[AnimationProvider cubeAnimation] forKey:@"animation"];
	[self.bottomStateFrameView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];

	self.bottomStateView.alpha = 0.0;
	self.bottomBackButton.enabled = NO;

}

- (void)shouldShowUserTimelineNotification:(id)sender
{
    if (self.dockViewController.commandCenterButton.selected) {
        [self hideCommandCenter];
    }
    [self performSelector:@selector(showUserTimeline:) withObject:[sender object] afterDelay:1.0];
}

- (void)showFriendsTimeline:(id)sender
{
    if (self.dockViewController.searchButton.selected)
        [self hideBottomStateViewForSearch];
    
    self.cardTableViewController.dataSource = CardTableViewDataSourceFriendsTimeline;
    [self hideBottomStateView];
    [self.cardTableViewController popCardWithCompletion:^{
        self.dockViewController.showFavoritesButton.selected = NO;
        self.dockViewController.showFavoritesButton.userInteractionEnabled = YES;
    }];
}

- (void)showUserTimeline:(User *)user
{
    self.cardTableViewController.dataSource = CardTableViewDataSourceUserTimeline;
    self.cardTableViewController.user = user;
	
	self.bottomStateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@的微博", nil), user.screenName];
	self.dockViewController.showFavoritesButton.selected = NO;
	[self showBottomStateView];
	
    [self.cardTableViewController pushCardWithCompletion:^{
		[self moveCardIntoView];
    }];
}

- (void)showSearchTimeline:(NSString *)searchString
{
    self.cardTableViewController.dataSource = CardTableViewDataSourceSearchStatues;
	
	NSString* string = [[NSString alloc] initWithFormat:@"包含%@的微博", searchString];
	self.bottomStateLabel.text = NSLocalizedString(string, nil); 
	self.bottomStateTextField.text = @"";
	self.bottomStateTextField.hidden = YES;
	[self showBottomStateView];
	
    [self.cardTableViewController pushCardWithCompletion:^{
        [self moveCardIntoView];
    }];
}

- (void)showFavorites
{
    self.cardTableViewController.dataSource = CardTableViewDataSourceFavorites;
	self.bottomStateLabel.text = NSLocalizedString(@"收藏", nil);
	[self showBottomStateView];
	
    [self.cardTableViewController pushCardWithCompletion:^{
        self.dockViewController.showFavoritesButton.userInteractionEnabled = YES;
		[self moveCardIntoView];
		
    }];
}

- (void)showMentions
{	
	self.cardTableViewController.dataSource = CardTableViewDataSourceMentions;
	self.bottomStateLabel.text = NSLocalizedString(@"@我的微博", nil);
	[self showBottomStateView];
	
	[self.cardTableViewController pushCardWithCompletion:^{
		[self moveCardIntoView];
		WeiboClient *client = [WeiboClient client];
		[client resetUnreadCount:ResetUnreadCountTypeReferMe];
	}];
}

- (void)showMentionsNotification:(id)sender
{
	if (self.dockViewController.commandCenterButton.selected) {
        [self hideCommandCenter];
    }
	
	[self performSelector:@selector(showMentions) withObject:[sender object] afterDelay:1.0];
}


- (BOOL)needUpdateNotiViewWithUserInfo:(NSDictionary*)dict
{
	BOOL result = NO;
	if (preNewCommentCount < [[dict objectForKey:@"comments"] intValue]) {
		preNewCommentCount = [[dict objectForKey:@"comments"] intValue];
		self.notiNewCommentLabel.text = [NSString stringWithFormat:@"%d", preNewCommentCount];
		result = YES;
	}
	if (preNewFollowerCount < [[dict objectForKey:@"followers"] intValue]) {
		preNewFollowerCount = [[dict objectForKey:@"followers"] intValue];
		self.notiNewFollowerLabel.text = [NSString stringWithFormat:@"%d", preNewFollowerCount];
		result = YES;
	}
	if (preNewMentionCount < [[dict objectForKey:@"mentions"] intValue]) {
		preNewMentionCount = [[dict objectForKey:@"mentions"] intValue];
		self.notiNewAtLabel.text = [NSString stringWithFormat:@"%d", preNewMentionCount];
		result = YES;
	}
	
	return result;
}

- (void)showNotificationView:(id)sender
{
	NSDictionary *dict = [sender userInfo];
	
	if ([self needUpdateNotiViewWithUserInfo:dict]) {
		CCUserInfoCardViewController *userCardVC = self.dockViewController.ccUserInfoCardViewController;
		userCardVC.friendsCountLabel.text =  userCardVC.user.friendsCount;
		userCardVC.followersCountLabel.text = userCardVC.user.followersCount;
		
		userCardVC.theNewFollowersCountLabel.text = self.notiNewFollowerLabel.text;
		
		if (self.notificationView.hidden && !_commandCenterFlag) {
			self.notificationView.hidden = NO;
			[self.notificationView.layer addAnimation:[AnimationProvider popoverAnimation] forKey:nil];
		}
	}
}

- (IBAction)refreshAndShowCommentCenter:(id)sender
{
	[self showCommandCenter];
}

- (IBAction)closeNotificationPop:(id)sender
{
	self.notificationView.hidden = YES;
}

- (void)modalCardViewPresentedNotification:(id)sender
{
    if (!_holeImageView) {
		UIImage *image = [UIImage imageNamed:@"card_hole_bg"];
		_holeImageView = [[UIImageView alloc] initWithImage:image];
		_holeImageView.frame = CGRectMake(0, 0, 1024, 768);
		_holeImageView.userInteractionEnabled = NO;
		_holeImageView.alpha = 0.0;
		[self.view addSubview:_holeImageView];
	}
    self.dockViewController.view.userInteractionEnabled = NO;
	self.bottomStateView.userInteractionEnabled = NO;
	self.cardTableViewController.tableView.scrollEnabled = NO;
    self.cardTableViewController.swipeEnabled = NO;
	[self.cardTableViewController enableDismissRegion];
	[UIView animateWithDuration:0.5 animations:^{
		_holeImageView.alpha = 1.0;
	}];
}

- (void)modalCardViewDismissedNotification:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
		_holeImageView.alpha = 0.0;
	}];
	self.bottomStateView.userInteractionEnabled = YES;
    self.dockViewController.view.userInteractionEnabled = YES;
	self.cardTableViewController.tableView.scrollEnabled = YES;
	self.cardTableViewController.swipeEnabled = YES;
	[self.cardTableViewController disableDismissRegion];
}

- (void)cardTableViewController:(CardTableViewController *)vc didScrollToRow:(int)row withNumberOfRows:(int)numberOfRows
{
    UISlider *slider = self.dockViewController.slider;
    [slider setMaximumValue:numberOfRows-1];
    [slider setMinimumValue:0];
    if (row == slider.value) {
        [slider setValue:row + 1 animated:NO];
        [slider setValue:row animated:NO];
    }
    else {
        [slider setValue:row animated:YES];
    }
}

- (void)setDefaultBackgroundImage:(BOOL)animated
{
	NSString *fileName = [BackgroundManViewController backgroundImageFilePathFromEnum:PBBackgroundImageDefault];
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"png"];
	UIImage *img = [UIImage imageWithContentsOfFile:path];
	
	if (animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = 1.0;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.backgroundImageView.layer addAnimation:transition forKey:nil];
    }
	
	self.backgroundImageView.image = img;
}

- (void)updateBackgroundImageAnimated:(BOOL)animated
{
    int enumValue = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyBackground];
    
	NSString *fileName = [BackgroundManViewController backgroundImageFilePathFromEnum:enumValue];
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"png"];
	UIImage *img = [UIImage imageWithContentsOfFile:path];
	
	CGRect myImageRect = CGRectMake(0.0, 642.0, img.size.width, 46);
    UIImage *originalImage = img;	
    CGImageRef imageRef = originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
	
    CGSize size = CGSizeMake(1024, 46);
	
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* cutImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
	
	if (_tmpImage == nil) {
		_tmpImage = [cutImage retain];
	} else {
		self.bottomStateInvisibleView.image = cutImage;
	}
	
	if (animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = 1.0;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.backgroundImageView.layer addAnimation:transition forKey:nil];
		[self.bottomStateInvisibleView.layer addAnimation:transition forKey:nil];
    }
    
	self.backgroundImageView.image = img;

}

- (void)backgroundChangedNotification:(id)sender
{
	[self updateBackgroundImageAnimated:YES];
}

- (void)refresh
{
	if ([[UIApplication sharedApplication] waitingForRefreshing]) {
		[[UIApplication sharedApplication] showRefreshView];
		[self.cardTableViewController refresh];
	}
}

- (void)post
{
    PostViewController *vc = [[PostViewController alloc] init];
    [[UIApplication sharedApplication] presentModalViewController:vc atHeight:kModalViewHeight];
    [vc release];
}

- (void)setPlayTimerEnabled:(BOOL)enabled
{
	if (enabled) {
		int interval = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeySiidePlayTimeInterval];
		_playTimer = [NSTimer scheduledTimerWithTimeInterval:interval 
                                                      target:self 
                                                    selector:@selector(timerFired:) 
                                                    userInfo:nil 
                                                     repeats:YES];
		[_playTimer fire];
		self.dockViewController.slider.highlighted = YES;
	}
	else {
		[_playTimer invalidate];
		self.dockViewController.slider.highlighted = NO;
		_playTimer = nil;
	}
}

- (void)timerFired:(NSTimer *)timer
{
	[self.cardTableViewController showNextCard];
}

- (void)play
{
    [self setPlayTimerEnabled:YES];
    self.dockViewController.playButton.selected = YES;		
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 1024, 768);
    [button addTarget:self action:@selector(playCanceled:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)playCanceled:(UIButton *)sender
{
	[sender removeFromSuperview];
	self.dockViewController.playButton.selected = NO;
	[self setPlayTimerEnabled:NO];
}

- (void)sliderValueChanged:(UISlider *)slider
{
    int index = slider.value;
    [self.cardTableViewController scrollToRow:index];
}

- (void)showDockView
{
    [self.view insertSubview:self.dockViewController.view belowSubview:self.bottomBackButton];
	
	CGRect frame = self.dockViewController.view.frame;
	frame.origin.y += 80;
	self.dockViewController.view.frame = frame;
	
    [UIView animateWithDuration:1.0 animations:^{
		CGRect frame = self.dockViewController.view.frame;
		frame.origin.y -= 80;
		self.dockViewController.view.frame = frame;
		
        self.dockViewController.view.alpha = 1.0;
    }];
}

- (void)showFavorites:(UIButton *)button
{
    button.userInteractionEnabled = NO;
    if (self.dockViewController.commandCenterButton.selected) {
        [self hideCommandCenter];
    }
    if (button.selected) {
        [self performSelector:@selector(showFriendsTimeline:) withObject:nil afterDelay:1.0];
        button.selected = NO;
    }
    else {
        [self performSelector:@selector(showFavorites) withObject:nil afterDelay:1.0];
        button.selected = YES;
    }
}

- (void)hideDockView
{
    [self.dockViewController.optionsPopoverController dismissPopoverAnimated:YES];
    [UIView animateWithDuration:1.0 animations:^{
		CGRect frame = self.dockViewController.view.frame;
		frame.origin.y += 80;
		self.dockViewController.view.frame = frame;
        self.dockViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.dockViewController.view removeFromSuperview];
            self.dockViewController = nil;
        }
    }];
}

- (void)messagesCenterButtonClicked:(UIButton *)button
{
    if (YES)
    {   
        // Test messages request
        WeiboClient *client = [WeiboClient client];
        [client getMessagesByUserSinceID:nil maxID:nil count:20 page:0];
        
        [client setCompletionBlock:^(WeiboClient *client) {
            if (!client.hasError) {
                NSArray *dictArray = client.responseJSONObject;
                
                int count = [dictArray count];
                NSLog(@"-----------------------------------");
                NSLog(@"%d", count);
                NSLog(@"-----------------------------------");
            }
        }];
    }
    
    if (button.selected) {
        [self hideMessagesCenter];
    }
    else {
        [self showMessagesCenter];
    }
}

- (void)showMessagesView
{
    [self.view insertSubview:self.messagesViewController.view belowSubview:self.bottomBackButton];
    [UIView animateWithDuration:1.0 animations:^{
        self.messagesViewController.view.alpha = 1.0;
    }];
}

- (void)hideMessagesView
{
    [UIView animateWithDuration:1.0 animations:^{
        self.messagesViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.messagesViewController.view removeFromSuperview];
            self.messagesViewController = nil;
        }
    }];
}

- (void)showMessagesCenter
{
    [self.messagesViewController viewWillAppear:YES];
    //    if (self.cardTableViewController.dataSource != CardTableViewDataSourceFriendsTimeline) {
    //        [self hideBottomStateView];
    //    }
    [UIView animateWithDuration:kDockAnimationInterval
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.dockViewController.messagesCenterButton.selected = YES;
                         
                         CGRect frame = self.messagesViewController.view.frame;
                         frame.origin.x += kMessagesViewOffsetx;
                         self.messagesViewController.view.frame = frame;
                         
                         frame = self.cardTableViewController.view.frame;
                         frame.origin.x += kMessagesViewOffsetx;
                         self.cardTableViewController.view.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self.messagesViewController viewDidAppear:YES];
                         }
                     }];
    
    self.dockViewController.commandCenterButton.enabled = NO;
    self.dockViewController.playButton.enabled = NO;
    self.dockViewController.slider.enabled = NO;
    self.dockViewController.refreshButton.enabled = NO;
    self.dockViewController.showFavoritesButton.enabled = NO;
    self.dockViewController.searchButton.enabled = NO;
}

- (void)hideMessagesCenter
{
    //    if (self.cardTableViewController.dataSource != CardTableViewDataSourceFriendsTimeline) {
    //        [self showBottomStateView];
    //    }
    [self.messagesViewController viewWillDisappear:YES];
    [UIView animateWithDuration:kDockAnimationInterval
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.dockViewController.messagesCenterButton.selected = NO;
                         
                         CGRect frame = self.messagesViewController.view.frame;
                         frame.origin.x -= kMessagesViewOffsetx;
                         self.messagesViewController.view.frame = frame;
                         
                         frame = self.cardTableViewController.view.frame;
                         frame.origin.x -= kMessagesViewOffsetx;
                         self.cardTableViewController.view.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self.messagesViewController viewDidDisappear:YES];
                         }
                     }];
    self.dockViewController.commandCenterButton.enabled = YES;
    self.dockViewController.playButton.enabled = YES;
    self.dockViewController.slider.enabled = YES;
    self.dockViewController.refreshButton.enabled = YES;
    self.dockViewController.showFavoritesButton.enabled = YES;
    self.dockViewController.searchButton.enabled = YES;
}

- (void)commandCenterButtonClicked:(UIButton *)button
{
    if (self.dockViewController.messagesCenterButton.selected) {
        [self hideMessagesCenter];
    }
    
    if (button.selected) {
        [self hideCommandCenter];
    }
    else {
        [self showCommandCenter];
    }
}

- (void)searchButtonClicked:(UIButton *)button
{
    self.bottomStateView.alpha = 1.0;
    [self.bottomStateTextField becomeFirstResponder];
    
    if (button.selected) {
        [self hideBottomStateViewForSearch];
    }
    else {
        [self showBottomStateViewForSearch];
    }
}

- (void)showCommandCenter
{
	_commandCenterFlag = YES;
	self.notificationView.hidden = YES;
	
	[self.dockViewController.ccCommentTableViewController refresh];
	preNewCommentCount = 0;
	self.notiNewCommentLabel.text = [NSString stringWithFormat:@"%d", preNewCommentCount];
	
    [self.dockViewController viewWillAppear:YES];
    if (self.cardTableViewController.dataSource != CardTableViewDataSourceFriendsTimeline) {
        [self hideBottomStateView];
    }
    [UIView animateWithDuration:kDockAnimationInterval
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.dockViewController.commandCenterButton.selected = YES;
                         
                         CGRect frame = self.dockViewController.view.frame;
                         frame.origin.y -= kDockViewOffsetY;
                         self.dockViewController.view.frame = frame;
                         
                         frame = self.cardTableViewController.view.frame;
                         frame.origin.y -= kCardTableViewOffsetY;
                         self.cardTableViewController.view.frame = frame;
                         
                         frame = self.bottomStateView.frame;
                         frame.origin.y -= kDockViewOffsetY;
                         self.bottomStateView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self.dockViewController viewDidAppear:YES];
                         }
                     }];
    self.dockViewController.playButton.enabled = NO;
    self.dockViewController.slider.enabled = NO;
    self.dockViewController.refreshButton.enabled = NO;
    self.dockViewController.messagesCenterButton.enabled = NO;
	[self.dockViewController.userCardNaviViewController.naviController popToRootViewControllerAnimated:NO];
	[self.dockViewController.commentNaviViewController.naviController popToRootViewControllerAnimated:NO];
}

- (void)hideCommandCenter
{	
	_commandCenterFlag = NO;
    if (self.cardTableViewController.dataSource != CardTableViewDataSourceFriendsTimeline) {
        [self showBottomStateView];
    }
    [self.dockViewController viewWillDisappear:YES];
    [UIView animateWithDuration:kDockAnimationInterval
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.dockViewController.commandCenterButton.selected = NO;
                         
                         CGRect frame = self.dockViewController.view.frame;
                         frame.origin.y += kDockViewOffsetY;
                         self.dockViewController.view.frame = frame;
                         
                         frame = self.cardTableViewController.view.frame;
                         frame.origin.y += kCardTableViewOffsetY;
                         self.cardTableViewController.view.frame = frame;
                         
                         frame = self.bottomStateView.frame;
                         frame.origin.y += kDockViewOffsetY; 
                         self.bottomStateView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self.dockViewController viewDidDisappear:YES];
                         }
                     }];
    self.dockViewController.playButton.enabled = YES;
    self.dockViewController.slider.enabled = YES;
    self.dockViewController.refreshButton.enabled = YES;
    self.dockViewController.messagesCenterButton.enabled = YES;
}

- (void)showLoginView
{
    [self.view addSubview:self.loginViewController.view];
    
	[self.loginViewController.view.layer addAnimation:[AnimationProvider popoverAnimation] forKey:nil];
	
    [UIView animateWithDuration:1.0 animations:^{
        self.pushBoxHDImageView.alpha = 1.0;
        self.loginViewController.view.alpha = 1.0;
    }];
}

- (void)hideLoginView
{
    [UIView animateWithDuration:1.0 animations:^{
        self.pushBoxHDImageView.alpha = 0.0;
        self.loginViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.loginViewController.view removeFromSuperview];
            self.loginViewController = nil;
        }
    }];
}

- (void)showCardTableView
{    
    [self.view insertSubview:self.cardTableViewController.view belowSubview:self.bottomBackButton];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL firstTime = [defaults boolForKey:kUserDefaultKeyFirstTime];
    UIButton *button = nil;
    if (firstTime) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = [UIImage imageNamed:@"root_help"];
        [button setImage:img forState:UIControlStateNormal];
        [button setImage:img forState:UIControlStateHighlighted];
        button.frame = CGRectMake(0, -15, 1024, 768);
        button.alpha = 0.0;
        [button addTarget:self action:@selector(helpButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
	//self.cardTableViewController.tableview.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1024)] autorelease];
	
	CGRect frame = self.cardTableViewController.view.frame;
	frame.origin.x += 782;
	self.cardTableViewController.view.frame = frame;
	frame = self.cardTableViewController.rootShadowLeft.frame;
	frame.origin.x -= 782;
	self.cardTableViewController.rootShadowLeft.frame = frame;

	self.cardTableViewController.view.alpha = 0.0;
	self.cardTableViewController.rootShadowLeft.alpha = 0.0;
	
    [UIView animateWithDuration:1.0 animations:^{
		
		CGRect frame = self.cardTableViewController.view.frame;
		frame.origin.x -= 782;
		self.cardTableViewController.view.frame = frame;
		frame = self.cardTableViewController.rootShadowLeft.frame;
		frame.origin.x += 782;
		self.cardTableViewController.rootShadowLeft.frame = frame;
		
        self.cardTableViewController.view.alpha = 1.0;
		self.cardTableViewController.rootShadowLeft.alpha = 1.0;
		
        button.alpha = 1.0;
    }];
}

- (void)helpButtonClicked:(UIButton *)button
{
    [UIView animateWithDuration:1.0 animations:^{
		button.alpha  = 0.0;
	} completion:^(BOOL fin) {
		if (fin) {
			[button removeFromSuperview];
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultKeyFirstTime];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}];
}

- (void)hideCardTableView
{
    [UIView animateWithDuration:1.0 animations:^{
        self.cardTableViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.cardTableViewController.view removeFromSuperview];
            self.cardTableViewController = nil;
        }
    }];
}

- (void)loginViewControllerDidLogin:(UIViewController *)vc
{
    [self hideLoginView];
    [self start];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (DockViewController *)dockViewController
{
    if (!_dockViewController) {
        _dockViewController = [[DockViewController alloc] init];
        self.dockViewController.currentUser = self.currentUser;
        CGRect frame = self.dockViewController.view.frame;
        frame.origin.y = kDockViewFrameOriginY;
        self.dockViewController.view.frame = frame;
        self.dockViewController.view.alpha = 0.0;
        
        [self.dockViewController.refreshButton addTarget:self 
                                                  action:@selector(refresh) 
                                        forControlEvents:UIControlEventTouchUpInside];
        
        [self.dockViewController.newTweetButton addTarget:self
                                                   action:@selector(post)
                                         forControlEvents:UIControlEventTouchUpInside];
        
        [self.dockViewController.playButton addTarget:self
                                               action:@selector(play)
                                     forControlEvents:UIControlEventTouchUpInside];
        
        [self.dockViewController.commandCenterButton addTarget:self
                                                        action:@selector(commandCenterButtonClicked:)
                                              forControlEvents:UIControlEventTouchUpInside];
        
        [self.dockViewController.messagesCenterButton addTarget:self
                                                         action:@selector(messagesCenterButtonClicked:)
                                               forControlEvents:UIControlEventTouchUpInside];
        
        [self.dockViewController.searchButton addTarget:self
                                                 action:@selector(searchButtonClicked:)
                                       forControlEvents:UIControlEventTouchUpInside];
        
        [self.dockViewController.slider addTarget:self 
                                           action:@selector(sliderValueChanged:)
                                 forControlEvents:UIControlEventValueChanged];
        
        [self.dockViewController.showFavoritesButton addTarget:self
                                                        action:@selector(showFavorites:)
                                              forControlEvents:UIControlEventTouchUpInside];
    }
    return _dockViewController;
}

- (LoginViewController *)loginViewController
{
    if (!_loginViewController) {
        _loginViewController = [[LoginViewController alloc] init];
        self.loginViewController.view.center = kLoginViewCenter;
        self.loginViewController.delegate = self;
        self.loginViewController.view.alpha = 0.0;
        self.pushBoxHDImageView.alpha = 0.0;
    }
    return _loginViewController;
}

- (CardTableViewController *)cardTableViewController
{
    if (!_cardTableViewController) {
        _cardTableViewController = [[CardTableViewController alloc] init];
        self.cardTableViewController.currentUser = self.currentUser;
        self.cardTableViewController.delegate = self;
        CGRect frame = self.cardTableViewController.view.frame;
        frame.origin.y = kCardTableViewFrameOriginY;
        self.cardTableViewController.view.frame = frame;
        self.cardTableViewController.view.alpha = 0.0;
    }
    return _cardTableViewController;
}

- (MessagesViewController *)messagesViewController
{
    if (!_messagesViewController) {
        _messagesViewController = [[MessagesViewController alloc] init];
        self.messagesViewController.view.center = kMessagesViewCenter;
        
        self.messagesViewController.contactsTableViewController.delegate = self;
        self.messagesViewController.dialogTableViewController.delegate = self;
        
        self.messagesViewController.currentUser = self.currentUser;
        self.messagesViewController.contactsTableViewController.currentUser = self.currentUser;
        self.messagesViewController.dialogTableViewController.currentUser = self.currentUser;
    }
    return _messagesViewController;
}

# pragma - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    self.cardTableViewController.searchString = textField.text;
    [self showSearchTimeline:textField.text];
    [self hideBottomStateViewForSearch];
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self hideBottomStateViewForSearch];
}

@end
