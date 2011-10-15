//
//  RootViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "RootViewController.h"
#import "WeiboClient.h"
#import "UIApplicationAddition.h"
#import <QuartzCore/QuartzCore.h>
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
- (void)showMessagesView;
- (void)hideMessagesView;
- (void)showMessagesCenter;
- (void)hideMessagesCenter;
- (void)showCommandCenter;
- (void)hideCommandCenter;
- (void)showCardTableView;
- (void)hideCardTableView;
- (void)updateBackgroundImageAnimated:(BOOL)animated;
@end

@implementation RootViewController

@synthesize backgroundImageView = _backgroundImageView;
@synthesize pushBoxHDImageView = _pushBoxHDImageView;
@synthesize bottomStateView = _bottomStateView;
@synthesize bottomStateLabel = _bottomStateLabel;
@synthesize loginViewController = _loginViewController;
@synthesize dockViewController = _dockViewController;
@synthesize messagesViewController = _messagesViewController;
@synthesize cardTableViewController = _cardTableViewController;

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
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.backgroundImageView = nil;
    self.pushBoxHDImageView = nil;
    self.bottomStateView = nil;
    self.bottomStateLabel = nil;
}

+ (void)initialize {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:30];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:kUserDefaultKeyFirstTime];
	[userDefault registerDefaults:dict];
}

- (void)start
{
    WeiboClient *client = [WeiboClient client];
    [client setCompletionBlock:^(WeiboClient *client) {
        if (!client.hasError) {
            NSDictionary *userDict = client.responseJSONObject;
            self.currentUser = [User insertUser:userDict inManagedObjectContext:self.managedObjectContext];
            
            self.cardTableViewController.dataSource = CardTableViewDataSourceFriendsTimeline;
            [self.cardTableViewController loadMoreDataCompletion:^(void) {
                [self.cardTableViewController loadAllFavoritesWithCompletion:NULL];
                [self showCardTableView];
                [self showDockView];
                [self showMessagesView];
                [self.cardTableViewController getUnread];
            }];;
        }
    }];
    [client getUser:[WeiboClient currentUserID]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateBackgroundImageAnimated:NO];
    
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
    
    self.bottomStateView.alpha = 0.0;
    
    if ([WeiboClient authorized]) {
        self.pushBoxHDImageView.alpha = 0.0;
        [self start];
    }
    else {
        [self showLoginView];
    }
}

- (void)userSignoutNotification:(id)sender
{
    [WeiboClient signout];
    [self hideDockView];
    [self hideCardTableView];
    [self hideBottomStateView];
    self.currentUser = nil;
    [User deleteAllObjectsInManagedObjectContext:self.managedObjectContext];
    [self performSelector:@selector(showLoginView) withObject:nil afterDelay:1.0];
}

- (void)showBottomStateView
{
    [UIView animateWithDuration:1.0 animations:^(void) {
        self.bottomStateView.alpha = 1.0;
    }];
}

- (void)hideBottomStateView
{
    [UIView animateWithDuration:1.0 animations:^(void) {
        self.bottomStateView.alpha = 0.0;
    }];
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
    [self.cardTableViewController pushCardWithCompletion:^{
        self.bottomStateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@的微博", nil), user.screenName];
        self.dockViewController.showFavoritesButton.selected = NO;
        [self showBottomStateView];
    }];
}

- (void)showFavorites
{
    self.cardTableViewController.dataSource = CardTableViewDataSourceFavorites;
    [self.cardTableViewController pushCardWithCompletion:^{
        self.bottomStateLabel.text = NSLocalizedString(@"收藏", nil);
        [self showBottomStateView];
        self.dockViewController.showFavoritesButton.userInteractionEnabled = YES;
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
	self.cardTableViewController.tableView.scrollEnabled = NO;
    self.cardTableViewController.swipeEnabled = NO;
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
}

- (void)cardTableViewController:(CardTableViewController *)vc didScrollToRow:(int)row withNumberOfRows:(int)numberOfRows
{
    UISlider *slider = self.dockViewController.slider;
    [slider setMaximumValue:numberOfRows-1];
    [slider setMinimumValue:0];
    if (row == slider.value) {
        [slider setValue:row+1 animated:NO];
        [slider setValue:row animated:NO];
    }
    else {
        [slider setValue:row animated:YES];
    }
}

- (void)updateBackgroundImageAnimated:(BOOL)animated
{
    int enumValue = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyBackground];
    
	NSString *fileName = [BackgroundManViewController backgroundImageFilePathFromEnum:enumValue];
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



- (void)backgroundChangedNotification:(id)sender
{
	[self updateBackgroundImageAnimated:YES];
}

- (void)refresh
{
    [self.cardTableViewController refresh];
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
    [self.view insertSubview:self.dockViewController.view belowSubview:self.bottomStateView];
    [UIView animateWithDuration:1.0 animations:^{
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
    // Test messages request
//        WeiboClient *client = [WeiboClient client];
//        [client getMessagesByUserSinceID:nil maxID:nil count:20 page:0];
//        
//        [client setCompletionBlock:^(WeiboClient *client) {
//            if (!client.hasError) {
//                NSArray *dictArray = client.responseJSONObject;
//                
//                int count = [dictArray count];
//                NSLog(@"-----------------------------------");
//                NSLog(@"%d", count);
//                NSLog(@"-----------------------------------");
//            }
//        }];
    
    if (button.selected) {
        [self hideMessagesCenter];
    }
    else {
        [self showMessagesCenter];
    }
}

- (void)showMessagesView
{
    [self.view insertSubview:self.messagesViewController.view belowSubview:self.bottomStateView];
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
    
    [self.dockViewController.commandCenterButton setEnabled:NO];
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
    [self.dockViewController.commandCenterButton setEnabled:YES];
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
}

- (void)hideCommandCenter
{
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
    [self.view insertSubview:self.cardTableViewController.view belowSubview:self.bottomStateView];
    
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
    
    [UIView animateWithDuration:1.0 animations:^{
        self.cardTableViewController.view.alpha = 1.0;
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

@end
