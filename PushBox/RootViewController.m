
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
#import "Emotion.h"
#import "Comment.h"
#import "PushBoxAppDelegate.h"
#import "GYTrackingSlider.h"
#import "SystemDefault.h"
#import "ReadStatusID.h"

#define kLoginViewCenter CGPointMake(512.0, 370.0)

#define kDockViewFrameOriginY 625.0

#define kDockViewOffsetY 635.0
#define kDockAnimationInterval 0.3

#define kCardTableViewFrameOriginY 25.0
#define kCardTableViewOffsetY 650.0

#define kMessagesViewCenter CGPointMake(512.0 - 1024.0, 350.0)
#define kMessagesViewOffsetx 1024.0

#define kSearchTextFieldFrame CGRectMake(341, 6, 383, 31)
#define kSearchTextFieldInputWait CGRectMake(341, 632, 383, 31)
#define kSearchBGFrame CGRectMake(0, 0, 1024, 42)
#define kSearchBGInputWait CGRectMake(0, 2, 1024, 42)

#define kUserDefaultKeyFirstTime @"kUserDefaultKeyFirstTime"
#define kUserDefaultKeyEmoticonNumber @"kUserDefaultKeyEmoticonNumber"

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
- (void)notificationRefreshed:(id)sender;
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

@synthesize speUser = _speUser;

@synthesize bottomSearchBG = _bottomSearchBG;
@synthesize castViewController = _castViewController;

@synthesize bottomSearchView = _bottomSearchView;
@synthesize bottomSearchLabel = _bottomSearchLabel;
@synthesize bottomSearchTextField = _bottomSearchTextField;

@synthesize notificationView = _notificationView;
@synthesize notiNewCommentLabel = _notiNewCommentLabel;
@synthesize notiNewFollowerLabel = _notiNewFollowerLabel;
@synthesize notiNewAtLabel = _notiNewAtLabel;

@synthesize notiCloseButton = _notiCloseButton;
@synthesize notiDisplayNewFollowersButton = _notiDisplayNewFollowersButton;
@synthesize notiDisplayNewMentionsButton = _notiDisplayNewMentionsButton;
@synthesize notiDisplayNewCommentsButton = _notiDisplayNewCommentsButton;

@synthesize groupView = _groupView;


#pragma mark - Tools

- (void)setRefreshButton
{
    BOOL result = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyPileUpEnabled];
    
    UIImage *image = nil;
    UIImage *imageHL = nil;
    
    BOOL datasourceEnabled = self.castViewController.dataSource == CastViewDataSourceFriendsTimeline;
    
    if (!result || !datasourceEnabled) {
        image = [UIImage imageNamed:@"dock_button_refresh.png"];
        imageHL = [UIImage imageNamed:@"dock_button_refresh_HL.png"];
    } else {
        image = [UIImage imageNamed:@"dock_button_refresh_stack.png"];
        imageHL = [UIImage imageNamed:@"dock_button_refresh_stack.png"];
    }
    
    [self.dockViewController.refreshButton setImage:image forState:UIControlStateNormal];
    [self.dockViewController.refreshButton setImage:imageHL forState:UIControlStateHighlighted];
}

- (void)showMEImageView
{
    UIImageView *view = self.castViewController.meImageView;
    if (view.hidden == NO) {
        return;
    }
    view.hidden = NO;
    view.alpha = 0.0;
    [UIView animateWithDuration:0.7 animations:^{
        view.alpha = 1.0;
    }];
}

- (void)hideMEImageView
{
    UIImageView *view = self.castViewController.meImageView;
    if (view.hidden == YES) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        view.hidden = YES;
        view.alpha = 1.0;
    }];
}

- (BOOL)shouldShowBottomSearchOrNot
{
	return  _inSearchMode && self.castViewController.infoStack.count == 1;
}

- (void)setGroupButtonImage:(int)number
{
    UIImage *image = nil;
    UIImage *imageHL = nil;
    
    if (number == 0) {
        image = [UIImage imageNamed:@"dock_button_group.png"];
        imageHL = [UIImage imageNamed:@"dock_button_group_HL.png"];
    } else if(number == 1) {
        image = [UIImage imageNamed:@"icon_orginal.png"];
        imageHL = [UIImage imageNamed:@"icon_orginal.png"];
    } else if(number == 2) {
        image = [UIImage imageNamed:@"icon_image.png"];
        imageHL = [UIImage imageNamed:@"icon_image.png"];
    } else if(number == 3) {
        image = [UIImage imageNamed:@"icon_video.png"];
        imageHL = [UIImage imageNamed:@"icon_video.png"];
    } else {
        image = [UIImage imageNamed:@"icon_music.png"];
        imageHL = [UIImage imageNamed:@"icon_music.png"];
    }
    
    [self.dockViewController.groupButton setImage:image forState:UIControlStateNormal];
    [self.dockViewController.groupButton setImage:imageHL forState:UIControlStateSelected];
    [self.dockViewController.groupButton setImage:imageHL forState:UIControlStateHighlighted];
}

- (void)clearData
{
    [ReadStatusID deleteAllObjectsInManagedObjectContext:self.managedObjectContext];
    [User deleteAllObjectsInManagedObjectContext:self.managedObjectContext];
    [Status deleteAllObjectsInManagedObjectContext:self.managedObjectContext];
    [Comment deleteAllObjectsInManagedObjectContext:self.managedObjectContext];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:PBBackgroundImageDefault] forKey:kUserDefaultKeyBackground];
}

#pragma mark - View lifecycle

- (void)dealloc
{
    [_backgroundImageView release];
    [_pushBoxHDImageView release];
    [_bottomStateView release];
    [_bottomStateLabel release];
    [_loginViewController release];
    [_dockViewController release];	
	[_castViewController release];
	
//	[_tmpImage release];
	[_notificationView release];
	[_notiNewCommentLabel release];
    [_notiNewFollowerLabel release];
    [_notiNewAtLabel release];
    [_notiCloseButton release];
    [_notiDisplayNewFollowersButton release];
    [_notiDisplayNewMentionsButton release];
    [_notiDisplayNewCommentsButton release];
    
    [_groupView release];
    
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
    
    self.groupView = nil;
}

+ (void)initialize 
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:30];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:kUserDefaultKeyFirstTime];
	[dict setObject:[NSNumber numberWithInt:0] forKey:kUserDefaultKeyEmoticonNumber];
	[userDefault registerDefaults:dict];
}

- (void)initSearchCoverImageView
{
	_searchCoverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_bg.png"]];
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchCoverImageViewClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
	[_searchCoverImageView addGestureRecognizer:tapGesture];
	_searchCoverImageView.frame = CGRectMake(0, 0, 1024, 748);
	_searchCoverImageView.alpha = 0.0;
	_searchCoverImageView.userInteractionEnabled = YES;
	[self.view addSubview:_searchCoverImageView];
	[tapGesture release];
}

- (void)initVariables
{
	_refreshFlag = NO;
	_newStatusFlag = NO;
	_inSearchMode = NO;
    _sliderEnabled = YES;
	
	preNewCommentCount = 0;
	preNewFollowerCount = 0;
	preNewMentionCount = 0;
	self.notificationView.hidden = YES;
	self.bottomStateFrameView.hidden = NO;
	self.groupView.hidden = YES;
    
    self.bottomBackButton.enabled = NO;
    
	_statusTypeStack = [[NSMutableArray alloc] init];
}

- (void)getFriendsDelta:(int)cursor 
{
    
    if (cursor == 0) {
        return;
    }
    
    getFriendsRequestCount++;
    if (getFriendsRequestCount > 10) {
        return;
    }
    
    WeiboClient *client = [WeiboClient client];
    [client setCompletionBlock:^(WeiboClient *client) {
        if (!client.hasError) {
            NSArray *dictArray = [client.responseJSONObject objectForKey:@"users"];
            for (NSDictionary *dict in dictArray) {
                [User insertUser:dict inManagedObjectContext:self.managedObjectContext];
            }
            
            int next_cursor = [[client.responseJSONObject objectForKey:@"next_cursor"] intValue];
            [self getFriendsDelta:next_cursor];
        } 
        else {
            NSLog(@"Get friends error!");
        }
    }];
    
    [client getFriendsOfUser:self.currentUser.userID cursor:cursor count:200];
    
}

- (void)getFriends
{
    [self initSpe];
    
    getFriendsRequestCount = 0;
    
    int cursor = -1;
    [self getFriendsDelta:cursor];
    
}

- (void)getEmotions
{    
    WeiboClient *client = [WeiboClient client];
    [client setCompletionBlock:^(WeiboClient *client) {
        if (!client.hasError) {
            int sum = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyEmoticonNumber];
            NSArray *dictArray = client.responseJSONObject;
            if (sum < [dictArray count]) {
                for (NSDictionary *dict in dictArray) {
                    [Emotion insertEmotion:dict inManagedObjectContext:self.managedObjectContext];
                }
                [[NSUserDefaults standardUserDefaults] setInteger:[[[NSNumber alloc] initWithInt:[dictArray count]] integerValue] forKey:kUserDefaultKeyEmoticonNumber];
            }
        }
    }];
    
    [client getEmotionsWithType:nil language:nil];
}

- (void)initCastView
{
	WeiboClient *client = [WeiboClient client];
    [client setCompletionBlock:^(WeiboClient *client) {
        if (!client.hasError) {
            NSDictionary *userDict = client.responseJSONObject;
            self.currentUser = [User insertUser:userDict inManagedObjectContext:self.managedObjectContext];
        }
		
		[self updateBackgroundImageAnimated:YES];
		
		[[UIApplication sharedApplication] showLoadingView];
        
		self.castViewController.dataSource = CastViewDataSourceFriendsTimeline;
		self.castViewController.prevDataSource = self.castViewController.dataSource;
		[self.castViewController firstLoad:^(void) {
			[self.castViewController loadAllFavoritesWithCompletion:nil];
			[self showCardTableView];
			[self showDockView];
//			[self showMessagesView];
			[self.dockViewController hideLoadingView];
            
            [self setRefreshButton];
		}];
		
    }];
	
    [client getUser:[WeiboClient currentUserID]];
}

- (void)initSpe
{
	WeiboClient *client = [WeiboClient client];
    [client setCompletionBlock:^(WeiboClient *client) {
        if (!client.hasError) {
            NSDictionary *userDict = client.responseJSONObject;
            self.speUser = [User insertUser:userDict inManagedObjectContext:self.managedObjectContext];
            NSLog(@"%@", self.speUser.screenName);
        }
		
    }];
	
    [client getUser:@"2588683162"];
}

- (void)start
{
	[[UIApplication sharedApplication] showLoadingView];
    
	[self initVariables];
	
	[self initCastView];
	
	[self initSearchCoverImageView];
	
	[self getFriends];
	
	[self getEmotions];
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
	[center addObserver:self
			   selector:@selector(notificationRefreshed:) 
				   name:kNotificationNameNotificationRefreshed 
				 object:nil];
	[center addObserver:self
			   selector:@selector(hideCommandCenter) 
				   name:kNotificationNameHideCommandCenter 
				 object:nil];
    [center addObserver:self
               selector:@selector(showGroupView) 
                   name:kNotificationNameShowGroupChoice 
                 object:nil];
	[center addObserver:self
               selector:@selector(setRefreshButton) 
                   name:kNotificationNamePileUpEnabledChanged 
                 object:nil];
    
    self.groupView.layer.anchorPoint = CGPointMake(0.5, 1.0);
    CGRect frame = self.groupView.frame;
    frame.origin.y += frame.size.height / 2;
    self.groupView.frame = frame;
    
	self.bottomStateView.hidden = YES;
	self.notificationView.hidden = YES;
    self.groupView.hidden = YES;
        
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

#pragma mark - Show & Hide Views


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == alertView.cancelButtonIndex) {
		return;
	}
	else {
        WeiboClient *client = [WeiboClient client];
        [client setCompletionBlock:^(WeiboClient *client){
            if (!client.hasError) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"完成", nil) 
                                                                message:NSLocalizedString(@"您可以在 VCard 官方微博中找到使用窍门和最新信息。", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"好", nil)
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }];
        [client follow:@"2478499604"]; 
    }
    
}

- (void)userSignoutNotification:(id)sender
{
	[self hideDockView];
	[self hideCardTableView];
	[self hideBottomStateView];
    self.bottomSearchTextField.hidden = YES;
    self.bottomSearchTextField.text = @"";
    [CastViewPileUpController releaseSharedCastViewPileUpController];
	
	[self.castViewController.castView moveOutViews:^(){
		preNewCommentCount = 0;
		preNewFollowerCount = 0;
		preNewMentionCount = 0;
		
		[WeiboClient signout];
		
//		if (_tmpImage != nil) {
//			[_tmpImage release];
//		}
//		_tmpImage = nil;
		
		if (_searchCoverImageView != nil) {
			[_searchCoverImageView release];
		}
		_searchCoverImageView = nil;
		
		_statusTypeStack = nil;
		
		self.bottomStateInvisibleView.image = nil;
		self.bottomStateFrameView.hidden = YES;
		self.notificationView.hidden = YES;
		self.currentUser = nil;
		[self setDefaultBackgroundImage:YES];
        
        [self clearData];
        
		[self performSelector:@selector(showLoginView) withObject:nil afterDelay:0.1];
	}];
}

- (void)configureUsablityAfterDeleted
{
    [self.castViewController configureUsability];
}

- (void)moveCardIntoView
{
    CGRect frame = self.castViewController.castView.frame;
    frame.origin.x += 782;
    self.castViewController.castView.frame = frame;
    
    self.castViewController.castView.alpha = 1.0;
    self.castViewController.rootShadowLeft.alpha = 1.0;
    
    [UIView animateWithDuration:1.0 animations:^{
        
        CGRect frame = self.castViewController.castView.frame;
        frame.origin.x -= 782;
        self.castViewController.castView.frame = frame;
    }];
}

- (void)showSearchView 
{
    
	[UIView animateWithDuration:0.3 animations:^{
		_searchCoverImageView.alpha = 1.0;
	}];
	
    self.dockViewController.searchButton.selected = YES;
    
	self.bottomSearchView.hidden = NO;
    
    isSearchReturn = NO;
    
    self.bottomSearchTextField.hidden = NO;
    self.bottomSearchTextField.frame = kSearchTextFieldFrame;
    self.bottomSearchBG.hidden = NO;
    self.bottomSearchBG.frame = kSearchBGFrame;
    
    [self.view addSubview:self.bottomSearchBG];
//    [self.view addSubview:self.bottomSearchTextField];
    [self.view insertSubview:self.bottomSearchTextField aboveSubview:self.bottomSearchBG];
    
    [self.bottomSearchTextField becomeFirstResponder];
    
    [self.bottomSearchView addSubview:self.bottomSearchBG]; 
    [self.bottomSearchView addSubview:self.bottomSearchTextField]; 
}

- (void)showSearchWaitingView 
{
	[UIView animateWithDuration:0.3 animations:^{
		_searchCoverImageView.alpha = 0.0;
	}];
	
    self.dockViewController.searchButton.selected = YES;
    
	self.bottomStateLabel.hidden = YES;
	
	self.bottomSearchView.hidden = NO;
    
    self.bottomSearchTextField.hidden = NO;
    self.bottomSearchTextField.frame = kSearchTextFieldInputWait;
    self.bottomSearchBG.hidden = NO;
    self.bottomSearchBG.frame = kSearchBGInputWait;
    
    [self.bottomSearchBG removeFromSuperview];
    [self.bottomSearchTextField removeFromSuperview];
    [self.bottomStateView addSubview:self.bottomSearchBG]; 
    [self.view insertSubview:self.bottomSearchTextField aboveSubview:self.bottomSearchBG];
	
	self.bottomSearchTextField.alpha = 0.0;
	[UIView animateWithDuration:1.0 animations:^{
		self.bottomSearchTextField.alpha = 1.0;
	}];
    
    [self.bottomSearchTextField resignFirstResponder];
}

- (void)hideSearchView
{	
	[UIView animateWithDuration:0.3 animations:^{
		_searchCoverImageView.alpha = 0.0;
	}];
    
    self.dockViewController.searchButton.selected = NO;
    
	self.bottomStateLabel.hidden = NO;
	
	self.bottomSearchView.hidden = YES;
    
    self.bottomSearchTextField.hidden = YES;
    self.bottomSearchTextField.frame = kSearchTextFieldFrame;
    self.bottomSearchBG.hidden = YES;
    self.bottomSearchBG.frame = kSearchBGFrame;
    
    [self.bottomSearchBG removeFromSuperview];
    [self.bottomSearchTextField removeFromSuperview];
    [self.view addSubview:self.bottomSearchBG];
//    [self.view addSubview:self.bottomSearchTextField];
    [self.view insertSubview:self.bottomSearchTextField aboveSubview:self.bottomSearchBG];
    
    [self.bottomSearchTextField resignFirstResponder];
}

- (void)searchButtonClicked:(UIButton*) button
{
	
	[self.castViewController clearCardStack];
	
	if (self.dockViewController.commandCenterButton.selected) {
		[self hideCommandCenter];
	}
	
    //
    [self.bottomSearchTextField setInputAccessoryView:self.bottomSearchView];
    
    if (button.selected) {
        [self hideSearchView];
		[self showPrevTimeline:nil];
    }
    else {
		if (self.castViewController.infoStack.count != 0) {
			[self showPrevTimeline:nil];
		}
        [self showSearchView];
    }
}

- (void)showGroupView
{
    self.groupView.hidden = NO;
    [self.groupView.layer addAnimation:[AnimationProvider popoverAnimation] forKey:nil];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)];
    _tmpButton = button;
    [button addTarget:self action:@selector(hideGroupView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:button belowSubview:self.groupView];
    [button release];
}

- (void)hideGroupView:(UIButton*)sender
{
    self.dockViewController.groupButton.selected = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.groupView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.groupView.hidden = YES;
        self.groupView.alpha = 1.0;
        [sender removeFromSuperview];
    }];
}

- (void)showBottomStateView
{
    
    if ([[SystemDefault systemDefault] isIPad2]) {
        self.bottomStateView.hidden = NO;
        
        if ([self.bottomStateView.layer animationForKey:@"animationDown"] == nil) {
            
            [self.bottomStateFrameView.layer addAnimation:[AnimationProvider cubeAnimationDown] forKey:@"animationDown"];
        }
        [self.bottomStateFrameView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
        
        [self.bottomStateFrameView bringSubviewToFront:self.bottomStateView];
        self.bottomBackButton.enabled = YES;
        
        if (self.castViewController.dataSource == CastViewDataSourceSearch) {
            [self showSearchWaitingView];
        } else {
            [self hideSearchView];
            if (_inSearchMode) {
                self.dockViewController.searchButton.selected = YES;
            }
        }
    } else {
        
        self.bottomStateInvisibleView.hidden = YES;
        self.bottomBackButton.enabled = YES;
        
        if (self.bottomStateView.hidden == YES) {
            self.bottomStateView.hidden = NO;
            
            if (self.castViewController.dataSource == CastViewDataSourceSearch) {
                self.bottomSearchBG.hidden = NO;
                self.bottomStateLabel.hidden = YES;
                self.bottomSearchTextField.hidden = NO;
            } else {
                self.bottomSearchBG.hidden = YES;
                self.bottomStateLabel.hidden = NO;
                self.bottomSearchTextField.hidden = YES;
            }
            
            self.bottomStateView.alpha = 0.0;
            self.bottomStateLabel.alpha = 0.0;
            
            [UIView animateWithDuration:0.7 animations:^{
                self.bottomStateView.alpha = 1.0;
                self.bottomStateLabel.alpha = 0.5;
            }];
        } else {
            
            if (self.castViewController.dataSource == CastViewDataSourceSearch) {

                [UIView animateWithDuration:0.3 animations:^{
                    self.bottomStateLabel.alpha = 0.0;
                    self.bottomSearchBG.alpha = 1.0;
                    self.bottomSearchTextField.alpha = 1.0;
                } completion:^(BOOL finished) {
                    self.bottomStateLabel.alpha = 0.5;
                    self.bottomStateLabel.hidden = YES;
                    
                    self.bottomSearchBG.hidden = NO;
                    self.bottomSearchTextField.hidden = NO;
                }];
                
            } else {
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.bottomStateLabel.alpha = 0.5;
                    self.bottomSearchBG.alpha = 0.0;
                    self.bottomSearchTextField.alpha = 0.0;
                } completion:^(BOOL finished) {
                    
                    self.bottomSearchBG.hidden = YES;
                    self.bottomStateLabel.hidden = NO;
                    self.bottomSearchTextField.hidden = YES;
                    self.bottomSearchBG.alpha = 1.0;
                }];
                
            }
            
            self.bottomStateLabel.alpha = 0.0;
            [UIView animateWithDuration:0.7 animations:^{
                self.bottomStateLabel.alpha = 0.5;
            }];
        }
    }
    

}

- (void)hideBottomStateView
{
    if ([[SystemDefault systemDefault] isIPad2]) {
        
        if ([self.bottomStateView.layer animationForKey:@"animationUp"] == nil) {
            
            [self.bottomStateFrameView.layer addAnimation:[AnimationProvider cubeAnimationUp] forKey:@"animationUp"];
        }
        [self.bottomStateFrameView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
        
        self.bottomStateView.hidden = YES;
        self.bottomBackButton.enabled = NO;
        
    } else {
        
        [UIView animateWithDuration:0.7 animations:^{
            self.bottomStateView.alpha = 0.0;
            self.bottomStateLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.bottomStateView.hidden = YES;
            self.bottomBackButton.enabled = NO;
        }];
    }
    

}

- (void)popBottomStateView
{
    
    if ([[SystemDefault systemDefault] isIPad2]) {
        
        if ([self.bottomStateView.layer animationForKey:@"animationUp"] == nil) {
            
            [self.bottomStateFrameView.layer addAnimation:[AnimationProvider cubeAnimationUp] forKey:@"animationUp"];
        }
        [self.bottomStateFrameView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
        if (_inSearchMode && self.castViewController.infoStack.count == 2) {
            [self showSearchWaitingView];
        }
        
    } else {
        self.bottomStateLabel.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomStateLabel.alpha = 0.5;
        }];
        
        if (self.castViewController.dataSource == CastViewDataSourceSearch) {
            
            self.bottomSearchBG.hidden = NO;
            self.bottomSearchTextField.hidden = NO;
            
            self.bottomSearchBG.alpha = 0.0;
            self.bottomSearchTextField.alpha = 0.0;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.bottomStateLabel.alpha = 0.0;
                self.bottomSearchBG.alpha = 1.0;
                self.bottomSearchTextField.alpha = 1.0;
            } completion:^(BOOL finished) {
                self.bottomStateLabel.alpha = 0.5;
                self.bottomStateLabel.hidden = YES;
            }];
            

        } else {
            self.bottomSearchBG.hidden = YES;
            self.bottomStateLabel.hidden = NO;
            self.bottomSearchTextField.hidden = YES;
        }
        
    }

}

- (void)shouldShowUserTimelineNotification:(id)sender
{
    if (self.dockViewController.commandCenterButton.selected) {
        [self hideCommandCenter];
    }
    [self performSelector:@selector(showUserTimeline:) withObject:[sender object] afterDelay:1.0];
}


#pragma mark - Show Timeline


- (void)showFriendsTimeline:(id)sender
{
	[self hideMEImageView];
	_inSearchMode = NO;
    if (self.dockViewController.searchButton.selected)
        [self hideSearchView];
    
    self.castViewController.dataSource = CastViewDataSourceFriendsTimeline;
	[self.castViewController popCardWithCompletion:^{
        self.dockViewController.showFavoritesButton.selected = NO;
        self.dockViewController.showFavoritesButton.userInteractionEnabled = YES;
        self.dockViewController.groupButton.enabled = YES;
        [self setGroupButtonImage:self.castViewController.statusTypeID];
        [self setRefreshButton];
    }];
}

- (void)showPrevTimeline:(id)sender
{
    [self hideMEImageView];
	if (self.castViewController.infoStack.count > 1) {
		[self.castViewController popCardWithCompletion:^{
            BOOL result = self.castViewController.dataSource == CastViewDataSourceFriendsTimeline || self.castViewController.dataSource == CastViewDataSourceUserTimeline;
            self.dockViewController.groupButton.enabled = result;
			[self setGroupButtonImage:self.castViewController.statusTypeID];
            [self setRefreshButton];
            if (![[SystemDefault systemDefault] isIPad2]) {
                [self popBottomStateView];
            }
		}];
        
        if ([[SystemDefault systemDefault] isIPad2]) {
            [self popBottomStateView];
        }
		
		[_statusTypeStack removeLastObject];
		NSString *string =  [_statusTypeStack lastObject];
		self.bottomStateLabel.text = string;
		if ([string isEqualToString:[NSString stringWithString:NSLocalizedString(@"收藏", nil)]]) {
			self.dockViewController.showFavoritesButton.selected = YES;
		} else {
			self.dockViewController.showFavoritesButton.selected = NO;
		}
	} else {
		
		[self hideBottomStateView];
		[self showFriendsTimeline:nil];
		self.dockViewController.refreshNotiImageView.hidden = self.dockViewController.refreshNotiImageShown;
	}
}

- (void)showUserTimeline:(User *)user
{
	[self hideMEImageView];
    self.castViewController.dataSource = CastViewDataSourceUserTimeline;
    self.castViewController.user = user;
    
	NSString* string = [NSString stringWithFormat:NSLocalizedString(@"%@ 的微博", nil), user.screenName];
    self.bottomStateLabel.text = string;
	[_statusTypeStack addObject:string];
    
    self.dockViewController.showFavoritesButton.selected = NO;
    
    [self showBottomStateView];
	self.dockViewController.showFavoritesButton.selected = NO;
    
    [self.castViewController pushCardWithCompletion:^{
        [self moveCardIntoView];
        [self setRefreshButton];
    }];
	self.dockViewController.refreshNotiImageView.hidden = YES;
    
    self.dockViewController.groupButton.enabled = YES;
    [self setGroupButtonImage:0];
}

- (void)showSearchTimeline:(NSString *)searchString
{
	[self hideMEImageView];
    self.castViewController.dataSource = CastViewDataSourceSearch;
    
    NSString* string = [[[NSString alloc] initWithFormat:@"包含 %@ 的微博", searchString] autorelease];
	[_statusTypeStack addObject:string];
	
    self.bottomStateLabel.text = NSLocalizedString(string, nil); 
    self.bottomStateTextField.text = @"";
    self.bottomStateTextField.hidden = YES;
	
	if (!self.castViewController.inSearchMode) {
		[self showBottomStateView];
		self.dockViewController.showFavoritesButton.selected = NO;
	}
    
	[self.castViewController switchToSearchCards:^{
        if (!_inSearchMode) {
            [self moveCardIntoView];
            [self setRefreshButton];
        }
        _inSearchMode = YES;
	}];
    
	self.dockViewController.refreshNotiImageView.hidden = YES;
    
    self.dockViewController.groupButton.enabled = NO;
    [self setGroupButtonImage:0];
}

- (void)showTrendsTimeline:(NSString *)searchString
{
	[self hideMEImageView];
    self.castViewController.dataSource = CastViewDataSourceTrends;
    
    NSString* string = [[[NSString alloc] initWithFormat:@"包含 %@ 的微博", searchString] autorelease];
	[_statusTypeStack addObject:string];
	
    self.bottomStateLabel.text = NSLocalizedString(string, nil); 
    self.bottomStateTextField.text = @"";
    self.bottomStateTextField.hidden = YES;
    
    [self showBottomStateView];
	self.dockViewController.showFavoritesButton.selected = NO;
    
    [self.castViewController pushCardWithCompletion:^{
        [self moveCardIntoView];
        [self setRefreshButton];
    }];
	self.dockViewController.refreshNotiImageView.hidden = YES;
    
    self.dockViewController.groupButton.enabled = NO;
    [self setGroupButtonImage:0];
}

- (void)showFavorites
{
	[self hideMEImageView];
    self.castViewController.dataSource = CastViewDataSourceFavorites;
	NSString *string = [NSString stringWithString:NSLocalizedString(@"收藏", nil)];
    self.bottomStateLabel.text = string;
	[_statusTypeStack addObject:string];
    
    [self showBottomStateView];
	self.dockViewController.showFavoritesButton.selected = YES;
    
    [self.castViewController pushCardWithCompletion:^{
        self.dockViewController.showFavoritesButton.userInteractionEnabled = YES;
        [self moveCardIntoView];
        [self setRefreshButton];
    }];
	self.dockViewController.refreshNotiImageView.hidden = YES;
    
    self.dockViewController.groupButton.enabled = NO;
    [self setGroupButtonImage:0];
}

- (void)showMentions
{	
	[self hideMEImageView];
    self.castViewController.dataSource = CastViewDataSourceMentions;
	NSString *string = [NSString stringWithString:NSLocalizedString(@"@我的微博", nil)];
    self.bottomStateLabel.text = string;
	[_statusTypeStack addObject:string];
    
    [self showBottomStateView];
	self.dockViewController.showFavoritesButton.selected = NO;
    
    [self.castViewController pushCardWithCompletion:^{
        [self moveCardIntoView];
        [self setRefreshButton];
    }];
    
	self.dockViewController.refreshNotiImageView.hidden = YES;
    
    self.dockViewController.groupButton.enabled = NO;
    [self setGroupButtonImage:0];
}

- (void)showMentionsNotification:(id)sender
{
    if (self.dockViewController.commandCenterButton.selected) {
        [self hideCommandCenter];
    }
    if (self.castViewController.dataSource != CastViewDataSourceMentions) {
        [self performSelector:@selector(showMentions) withObject:[sender object] afterDelay:1.0];
    }
}

#pragma mark - 

- (void)initDockViewController
{
    if (preNewCommentCount == 0) {
        self.dockViewController.ccCommentTableViewController.theNewCommentCountLabel.text = @"";
    } else {
        self.dockViewController.ccCommentTableViewController.theNewCommentCountLabel.text = [NSString stringWithFormat:@"%d", preNewCommentCount];
    }
    
    if (preNewFollowerCount == 0) {
        self.dockViewController.ccUserInfoCardViewController.theNewFollowersCountLabel.text = @"";
    } else {
        self.dockViewController.ccUserInfoCardViewController.theNewFollowersCountLabel.text = [NSString stringWithFormat:@"%d", preNewFollowerCount];
    }
    
    if (preNewMentionCount == 0) {
        self.dockViewController.ccCommentTableViewController.theNewMentionsCountLabel.text = @"";
    } else {
        self.dockViewController.ccCommentTableViewController.theNewMentionsCountLabel.text = [NSString stringWithFormat:@"%d", preNewMentionCount];
    }
}

- (void)notificationRefreshed:(id)sender
{
	NSDictionary *dict = [sender userInfo];
	NSString *typeName = [dict objectForKey:@"type"];
	if ([typeName isEqual:kNotificationObjectNameFollower]) {
		preNewFollowerCount = 0;
		self.dockViewController.ccUserInfoCardViewController.theNewFollowersCountLabel.text = @"";
		self.notiNewFollowerLabel.text = @"0";
		WeiboClient *client = [WeiboClient client];
		[client resetUnreadCount:ResetUnreadCountTypeFollowers];
	} else if([typeName isEqual:kNotificationObjectNameComment]) {
		preNewCommentCount = 0;
		self.dockViewController.ccCommentTableViewController.theNewCommentCountLabel.text = @"";
		self.notiNewCommentLabel.text = @"0";
		WeiboClient *client = [WeiboClient client];
		[client resetUnreadCount:ResetUnreadCountTypeComments];
	} else if([typeName isEqual:kNotificationObjectNameMention]) {
		preNewMentionCount = 0;
		self.dockViewController.ccCommentTableViewController.theNewMentionsCountLabel.text = @"";
		self.notiNewAtLabel.text = @"0";
		WeiboClient *client = [WeiboClient client];
        [client resetUnreadCount:ResetUnreadCountTypeReferMe];
	}
}

- (BOOL)needUpdateNotiViewWithUserInfo:(NSDictionary*)dict
{
    BOOL result = NO;
    if (preNewCommentCount < [[dict objectForKey:@"comments"] intValue]) {
        preNewCommentCount = [[dict objectForKey:@"comments"] intValue];
        if (preNewCommentCount == 0) {
			self.dockViewController.ccCommentTableViewController.theNewCommentCountLabel.text = @"";
		} else {
			self.notiNewCommentLabel.text = [NSString stringWithFormat:@"%d", preNewCommentCount];
			self.dockViewController.ccCommentTableViewController.theNewCommentCountLabel.text = [NSString stringWithFormat:@"%d", preNewCommentCount];
		}
		
        result = YES;
    }
    if (preNewFollowerCount < [[dict objectForKey:@"followers"] intValue]) {
        preNewFollowerCount = [[dict objectForKey:@"followers"] intValue];
		if (preNewFollowerCount == 0) {
			self.dockViewController.ccUserInfoCardViewController.theNewFollowersCountLabel.text = @"";
		} else {
			self.notiNewFollowerLabel.text = [NSString stringWithFormat:@"%d", preNewFollowerCount];
			self.dockViewController.ccUserInfoCardViewController.theNewFollowersCountLabel.text = [NSString stringWithFormat:@"%d", preNewFollowerCount];
        }
		result = YES;
    }
    if (preNewMentionCount < [[dict objectForKey:@"mentions"] intValue]) {
        preNewMentionCount = [[dict objectForKey:@"mentions"] intValue];
		if (preNewMentionCount == 0) {
			self.dockViewController.ccCommentTableViewController.theNewMentionsCountLabel.text = @"";
		} else {
			self.notiNewAtLabel.text = [NSString stringWithFormat:@"%d", preNewMentionCount];
			self.dockViewController.ccCommentTableViewController.theNewMentionsCountLabel.text = [NSString stringWithFormat:@"%d", preNewMentionCount];
		}
        result = YES;
    }
    
    return result;
}

- (void)showNotificationView:(id)sender
{
	NSDictionary *dict = [sender userInfo];
	
	if ([self needUpdateNotiViewWithUserInfo:dict]) {
		_refreshFlag = YES;
		
		CCUserInfoCardViewController *userCardVC = self.dockViewController.ccUserInfoCardViewController;
		userCardVC.friendsCountLabel.text =  self.currentUser.friendsCount;
		userCardVC.followersCountLabel.text = self.currentUser.followersCount;
		userCardVC.statusesCountLabel.text = self.currentUser.statusesCount;
        
		BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultKeyNotiPopoverEnabled];
		if (self.notificationView.hidden && !_commandCenterFlag && enabled) {
			self.notificationView.hidden = NO;
			[self.notificationView.layer addAnimation:[AnimationProvider popoverAnimation] forKey:nil];
		}
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultKeySoundEnabled]) {
            UIAudioAddition* audioAddition = [[UIAudioAddition alloc] init];
            [audioAddition playNotificationSound];
            [audioAddition release];
        }
    }
}

- (IBAction)refreshAndShowCommentCenter:(id)sender
{
    [self showCommandCenter];
}

- (IBAction)closeNotificationPop:(id)sender
{
	[UIView animateWithDuration:0.3 animations:^(){
		self.notificationView.alpha = 0.0;
	} completion:^(BOOL finished){
		if (finished) {
			self.notificationView.hidden = YES;
			self.notificationView.alpha = 1.0;
		}
	}];
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
    self.castViewController.castView.scrollEnabled = NO;
    self.bottomBackButton.enabled = NO;
    [self.castViewController enableDismissRegion];
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
    self.castViewController.castView.scrollEnabled = YES;
    self.bottomBackButton.enabled = YES;
    [self.castViewController disableDismissRegion];
}

#pragma mark - 

- (void)castViewControllerdidScrollToRow:(int)row withNumberOfRows:(int)numberOfRows
{
    UISlider *slider = self.dockViewController.slider;
    [slider setMaximumValue:numberOfRows - 1];
    [slider setMinimumValue:0];
    if (row == slider.value) {
        [slider setValue:row + 1 animated:NO];
        [slider setValue:row animated:NO];
    }
    else {
        [slider setValue:row animated:YES];
    }
    
    slider.enabled = numberOfRows != 0;
    if (numberOfRows != 0) {
        [self hideMEImageView];
    } else {
        [self showMEImageView];
    }
    
}

- (void)setDefaultBackgroundImage:(BOOL)animated
{
    NSString *fileName = [BackgroundManViewController backgroundImageFilePathFromEnum:PBBackgroundImageDefault];
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg"];
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
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg"];
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
    
//    if (_tmpImage == nil) {
//        _tmpImage = [cutImage retain];
//    } else {
//        self.bottomStateInvisibleView.image = cutImage;
//    }
    
    self.bottomStateInvisibleView.image = cutImage;
    
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
    if (self.dockViewController.refreshButton.enabled) {
        [self.dockViewController showLoadingView];
//        [self.cardTableViewController refresh];
		[self.castViewController refresh];
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
    //    [self.cardTableViewController showNextCard];
	[self.castViewController showNextCard];
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

- (void)sliderTouchedIn:(UISlider *)slider
{
	GYTrackingSlider *trackingSlider = (GYTrackingSlider*)slider;
	[self.castViewController.castViewManager configureTrackingPopover:trackingSlider.trackPopoverView 
															  AtIndex:self.castViewController.castViewManager.currentIndex 
														andDataSource:self.castViewController.dataSource];
	
	_trackingIndex = self.castViewController.castViewManager.currentIndex;
}

- (void)sliderValueChanged:(UISlider *)slider
{
    int index = slider.value;
	if (_trackingIndex == index) {
		return;
	}
	_trackingIndex = index;
	GYTrackingSlider *trackingSlider = (GYTrackingSlider*)slider;
	[self.castViewController.castViewManager configureTrackingPopover:trackingSlider.trackPopoverView 
															  AtIndex:index 
														andDataSource:self.castViewController.dataSource];
}

- (void)sliderDidEndDragging:(UISlider *)slider
{
	int index = slider.value;
	if (index == self.castViewController.castViewManager.currentIndex) {
		return;
	}
	[self.castViewController.castViewManager moveCardsToIndex:index];
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
        [self performSelector:@selector(showPrevTimeline:) withObject:nil afterDelay:1.0];
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
    [UIView animateWithDuration:kDockAnimationInterval
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.dockViewController.messagesCenterButton.selected = YES;
                         
                         CGRect frame = self.messagesViewController.view.frame;
                         frame.origin.x += kMessagesViewOffsetx;
                         self.messagesViewController.view.frame = frame;
                         
						 frame = self.castViewController.view.frame;
                         frame.origin.x += kMessagesViewOffsetx;
                         self.castViewController.view.frame = frame;
                         //                         frame = self.cardTableViewController.view.frame;
                         //                         frame.origin.x += kMessagesViewOffsetx;
                         //                         self.cardTableViewController.view.frame = frame;
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
    
    [self.messagesViewController viewWillDisappear:YES];
    [UIView animateWithDuration:kDockAnimationInterval
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.dockViewController.messagesCenterButton.selected = NO;
                         
                         CGRect frame = self.messagesViewController.view.frame;
                         frame.origin.x -= kMessagesViewOffsetx;
                         self.messagesViewController.view.frame = frame;
                         
						 frame = self.castViewController.view.frame;
                         frame.origin.x -= kMessagesViewOffsetx;
                         self.castViewController.view.frame = frame;
                         
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

- (void)showCommandCenter
{

    [self.dockViewController setCommandCenter];
    
    [self hideMEImageView];
    _sliderEnabled = self.dockViewController.slider.enabled;
    
	_commandCenterFlag = YES;
	self.notificationView.hidden = YES;
    _groupButtonEnabled = self.dockViewController.groupButton.enabled;
    self.dockViewController.groupButton.enabled = NO;
    
    self.bottomSearchTextField.hidden = YES;
    [self.bottomSearchTextField setAlpha:0.0];
    [UIView animateWithDuration:0.3 animations:^(void){
        [self.bottomSearchTextField setAlpha:1.0];
    }];
	
	self.dockViewController.hideCommandCenterButton.enabled = YES;
	
	if (_refreshFlag) {
		_refreshFlag = NO;
		[self.dockViewController.ccCommentTableViewController refresh];
	}
	
    [self.dockViewController viewWillAppear:YES];
    
    [UIView animateWithDuration:kDockAnimationInterval
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.dockViewController.commandCenterButton.selected = YES;
                         
                         CGRect frame = self.dockViewController.view.frame;
                         frame.origin.y -= kDockViewOffsetY;
                         self.dockViewController.view.frame = frame;
                         
						 frame = self.castViewController.view.frame;
                         frame.origin.y -= kCardTableViewOffsetY;
                         self.castViewController.view.frame = frame;
                         
                         frame = self.bottomStateView.frame;
                         frame.origin.y -= kDockViewOffsetY;
                         self.bottomStateView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self.dockViewController viewDidAppear:YES];
                             [self initDockViewController];
                             [[UIApplication sharedApplication] hideLoadingView];
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
    
    if (!_sliderEnabled) {
        [self showMEImageView];
    }
	
	self.dockViewController.hideCommandCenterButton.enabled = NO;
    self.dockViewController.groupButton.enabled = _groupButtonEnabled;
    self.bottomSearchTextField.hidden = self.bottomSearchBG.hidden;
    
    [self.dockViewController viewWillDisappear:YES];
    [UIView animateWithDuration:kDockAnimationInterval
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.dockViewController.commandCenterButton.selected = NO;
                         
                         CGRect frame = self.dockViewController.view.frame;
                         frame.origin.y += kDockViewOffsetY;
                         self.dockViewController.view.frame = frame;
                         
						 frame = self.castViewController.view.frame;
                         frame.origin.y += kCardTableViewOffsetY;
                         self.castViewController.view.frame = frame;
						 
                         //                         frame = self.cardTableViewController.view.frame;
                         //                         frame.origin.y += kCardTableViewOffsetY;
                         //                         self.cardTableViewController.view.frame = frame;
                         
                         frame = self.bottomStateView.frame;
                         frame.origin.y += kDockViewOffsetY; 
                         self.bottomStateView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self.dockViewController viewDidDisappear:YES];
                             [self.dockViewController clearCommandCenter];
                         }
                     }];
    self.dockViewController.playButton.enabled = YES;
    self.dockViewController.slider.enabled = _sliderEnabled;
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
	[self.view insertSubview:self.castViewController.view belowSubview:self.bottomBackButton];
    
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
        
        // 
        WeiboClient *client = [WeiboClient client];
        
        [client setCompletionBlock:^(WeiboClient *client) {
            NSDictionary *dict = client.responseJSONObject;
            dict = [dict objectForKey:@"target"];
            
            BOOL followedByMe = [[dict objectForKey:@"followed_by"] boolValue];
            
            if (!followedByMe) {                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"关注 VCard HD", nil)
                                                                message:NSLocalizedString(@"您可以在 VCard 官方微博中找到使用窍门和最新信息。", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"不, 谢谢", nil)
                                                      otherButtonTitles:NSLocalizedString(@"好", nil), nil];
                [alert show];
                [alert release];
            }
            
        }];
        
        [client getRelationshipWithUser:@"2478499604"];
    }
    
	CGRect frame = self.castViewController.view.frame;
    frame.origin.x += 782;
    self.castViewController.view.frame = frame;
    frame = self.castViewController.rootShadowLeft.frame;
    frame.origin.x -= 782;
    self.castViewController.rootShadowLeft.frame = frame;
    
    self.castViewController.view.alpha = 0.0;
    self.castViewController.rootShadowLeft.alpha = 0.0;
    
    [UIView animateWithDuration:1.0 animations:^{
        
        CGRect frame = self.castViewController.view.frame;
        frame.origin.x -= 782;
        self.castViewController.view.frame = frame;
        frame = self.castViewController.rootShadowLeft.frame;
        frame.origin.x += 782;
        self.castViewController.rootShadowLeft.frame = frame;
        
        self.castViewController.view.alpha = 1.0;
        self.castViewController.rootShadowLeft.alpha = 1.0;
        
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
        self.castViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.castViewController.view removeFromSuperview];
            self.castViewController = nil;
        }
    }];
}

- (void)loginViewControllerDidLogin:(UIViewController *)vc shouldClearData:(BOOL)differentUser
{
    if (differentUser) {
        [self clearData];
    }
    
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
		self.dockViewController.managedObjectContext = self.managedObjectContext;
        CGRect frame = self.dockViewController.view.frame;
        frame.origin.y = kDockViewFrameOriginY;
        self.dockViewController.view.frame = frame;
        self.dockViewController.view.alpha = 0.0;
        
        [self.dockViewController.refreshButton addTarget:self 
                                                  action:@selector(refresh) 
                                        forControlEvents:UIControlEventTouchUpInside];
        
        [self.dockViewController.postButton addTarget:self
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
		
		[self.dockViewController.slider addTarget:self
										   action:@selector(sliderDidEndDragging:)
								 forControlEvents:UIControlEventTouchUpInside];
        
		[self.dockViewController.slider addTarget:self
										   action:@selector(sliderDidEndDragging:)
								 forControlEvents:UIControlEventTouchUpOutside];
		
		[self.dockViewController.slider addTarget:self
										   action:@selector(sliderTouchedIn:)
								 forControlEvents:UIControlEventTouchDown];
		
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

- (CastViewController *)castViewController
{
    if (!_castViewController) {
        _castViewController = [[CastViewController alloc] init];
        self.castViewController.currentUser = self.currentUser;
		self.castViewController.managedObjectContext = self.managedObjectContext;
        self.castViewController.delegate = self;
        CGRect frame = self.castViewController.view.frame;
        frame.origin.y = kCardTableViewFrameOriginY;
        self.castViewController.view.frame = frame;
        self.castViewController.view.alpha = 0.0;
    }
    return _castViewController;
}

- (MessagesViewController *)messagesViewController
{
    if (!_messagesViewController) {
        _messagesViewController = [[MessagesViewController alloc] init];
        
        self.messagesViewController.contactsTableViewController.delegate = self;
        self.messagesViewController.dialogTableViewController.delegate = self;
        
        self.messagesViewController.currentUser = self.currentUser;
        self.messagesViewController.contactsTableViewController.currentUser = self.currentUser;
        self.messagesViewController.dialogTableViewController.currentUser = self.currentUser;
		self.messagesViewController.dialogTableViewController.managedObjectContext = self.managedObjectContext;
		self.messagesViewController.contactsTableViewController.managedObjectContext = self.managedObjectContext;
		
        self.messagesViewController.view.center = kMessagesViewCenter;
    }
    return _messagesViewController;
}

# pragma - UITextFieldDelegate

- (void)showNullSearchStringError
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"无结果", nil)
													message:NSLocalizedString(@"请检查关键字并重试", nil)
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"好", nil)
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
        if (self.dockViewController.searchButton.selected) {
            [self.bottomSearchTextField becomeFirstResponder];
        }
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	if ([textField.text isEqualToString:@""]) {
		
        //		[ErrorNotification showSearchStringNullError];
		
		[self showNullSearchStringError];
		
		return NO;
	} else {
		
		[textField resignFirstResponder];
		
		self.castViewController.searchString = textField.text;
		
		[self showSearchTimeline:textField.text];
		
		[self showSearchWaitingView];
		
		isSearchReturn = YES;
		
		return NO;
	}
}

- (IBAction)searchTextFieldClicked:(id)sender 
{
	[self showSearchView];
}

- (void)textFieldDidEndEditing:(UITextField *)textField 
{
    if(!isSearchReturn) {
		isSearchReturn = YES;
        [self hideSearchView];
		if (_inSearchMode) {
			[self showSearchWaitingView];
		}
    }
}

- (void)searchCoverImageViewClicked:(id)sender
{
	[self textFieldDidEndEditing:self.bottomSearchTextField];
}

- (IBAction)groupChoosed:(UIButton*)sender
{
    int statusType = 0;
    UIImage *image = nil;
    UIImage *imageHL = nil;
    
    if ([sender.titleLabel.text isEqualToString:@"            全部卡片"]) {
        statusType = 0;
        image = [UIImage imageNamed:@"dock_button_group.png"];
        imageHL = [UIImage imageNamed:@"dock_button_group_HL.png"];
    } else if([sender.titleLabel.text isEqualToString:@"            原创"]) {
        statusType = 1;
        image = [UIImage imageNamed:@"icon_orginal.png"];
        imageHL = [UIImage imageNamed:@"icon_orginal.png"];
    } else if([sender.titleLabel.text isEqualToString:@"            图览"]) {
        statusType = 2;
        image = [UIImage imageNamed:@"icon_image.png"];
        imageHL = [UIImage imageNamed:@"icon_image.png"];
    } else if([sender.titleLabel.text isEqualToString:@"            电影和视频"]) {
        statusType = 3;
        image = [UIImage imageNamed:@"icon_video.png"];
        imageHL = [UIImage imageNamed:@"icon_video.png"];
    } else {
        statusType = 4;
        image = [UIImage imageNamed:@"icon_music.png"];
        imageHL = [UIImage imageNamed:@"icon_music.png"];
    }
    
    [self.dockViewController.groupButton setImage:image forState:UIControlStateNormal];
    [self.dockViewController.groupButton setImage:imageHL forState:UIControlStateSelected];
    [self.dockViewController.groupButton setImage:imageHL forState:UIControlStateHighlighted];
    
    self.castViewController.statusTypeID = statusType;
    
    [[UIApplication sharedApplication] showLoadingView];
    
    [self.castViewController reload:nil];
    
    [self hideGroupView:_tmpButton];
}

@end
