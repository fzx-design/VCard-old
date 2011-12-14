//
//  RootViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataViewController.h"
#import "LoginViewController.h"
#import "DockViewController.h"
#import "CastViewController.h"
#import "PostViewController.h"
#import "MessagesViewController.h"
#import "CastViewController.h"

@interface RootViewController : CoreDataViewController<LoginViewControllerDelegate, CastViewControllerDelegate, UIAlertViewDelegate> {
    UIImageView *_backgroundImageView;
    UIImageView *_pushBoxHDImageView;
    
	UIView *_bottomStateFrameView;
    UIView *_bottomStateView;
	UIImageView *_bottomStateInvisibleView;
	UIButton *_bottomBackButton;
	UILabel *_bottomStateLabel;
    UITextField *_bottomStateTextField;
    
    UIView *_bottomSearchView;
	UILabel *_bottomSearchLabel;
    UITextField *_bottomSearchTextField;
    
    UIImageView *_holeImageView;
	
	UIView *_notificationView;
	UILabel *_notiNewCommentLabel;
	UILabel *_notiNewFollowerLabel;
	UILabel *_notiNewAtLabel;
	
	UIButton *_notiCloseButton;
	UIButton *_notiDisplayNewFollowersButton;
	UIButton *_notiDisplayNewMentionsButton;
	UIButton *_notiDisplayNewCommentsButton;
	
    UIView *_groupView;
    
    LoginViewController *_loginViewController;
    DockViewController *_dockViewController;
    MessagesViewController *_messagesViewController;
//    CardTableViewController *_cardTableViewController;
	
	NSMutableArray *_statusTypeStack;
	
	CastViewController *_castViewController;
    
    NSTimer *_playTimer;
	
	BOOL _commandCenterFlag;
	BOOL _refreshFlag;
	BOOL _newStatusFlag;
	BOOL _inSearchMode;
    BOOL _groupButtonEnabled;
    BOOL _sliderEnabled;
    
	int _trackingIndex;
	
	NSInteger preNewFollowerCount;
	NSInteger preNewCommentCount;
	NSInteger preNewMentionCount;
    
    UIImageView* _bottomSearchBG;
	
//	UIImage *_tmpImage;
	UIImageView *_searchCoverImageView;
    
    UIButton *_tmpButton;
    
    Boolean isSearchReturn;
    
    int getFriendsRequestCount;

    User* _speUser;
    
    UIButton* _searchCoverButton;
}

@property(nonatomic, retain) IBOutlet UIImageView* backgroundImageView;
@property(nonatomic, retain) IBOutlet UIImageView* pushBoxHDImageView;
@property(nonatomic, retain) IBOutlet UIImageView* bottomSearchBG;
@property(nonatomic, retain) IBOutlet UIView* bottomStateFrameView;
@property(nonatomic, retain) IBOutlet UIView* bottomStateView;
@property(nonatomic, retain) IBOutlet UIImageView* bottomStateInvisibleView;
@property(nonatomic, retain) IBOutlet UIButton* bottomBackButton;;
@property(nonatomic, retain) IBOutlet UILabel* bottomStateLabel;
@property(nonatomic, retain) IBOutlet UITextField* bottomStateTextField;

@property(nonatomic, retain) IBOutlet UIView* bottomSearchView;
@property(nonatomic, retain) IBOutlet UILabel* bottomSearchLabel;
@property(nonatomic, retain) IBOutlet UITextField* bottomSearchTextField;

@property(nonatomic, retain) IBOutlet UIButton* searchCoverButton;

@property(nonatomic, retain) IBOutlet UIView *notificationView;
@property(nonatomic, retain) IBOutlet UILabel *notiNewCommentLabel;
@property(nonatomic, retain) IBOutlet UILabel *notiNewFollowerLabel;
@property(nonatomic, retain) IBOutlet UILabel *notiNewAtLabel;

@property(nonatomic, retain) IBOutlet UIButton *notiCloseButton;
@property(nonatomic, retain) IBOutlet UIButton *notiDisplayNewFollowersButton;
@property(nonatomic, retain) IBOutlet UIButton *notiDisplayNewMentionsButton;
@property(nonatomic, retain) IBOutlet UIButton *notiDisplayNewCommentsButton;

@property(nonatomic, retain) IBOutlet UIView *groupView;

@property(nonatomic, retain) LoginViewController* loginViewController;
@property(nonatomic, retain) DockViewController *dockViewController;
@property(nonatomic, retain) MessagesViewController *messagesViewController;

@property(nonatomic, retain) CastViewController* castViewController;
@property(nonatomic, retain) User *speUser;

- (IBAction)showFriendsTimeline:(id)sender;
- (IBAction)showPrevTimeline:(id)sender;

- (IBAction)refreshAndShowCommentCenter:(id)sender;
- (IBAction)closeNotificationPop:(id)sender;
- (IBAction)searchTextFieldClicked:(id)sender;

- (IBAction)groupChoosed:(UIButton*)sender;

- (void)showSearchTimeline:(NSString *)searchString;
- (void)showTrendsTimeline:(NSString *)searchString;
- (void)initSpe;

- (void)showSearchView;
- (void)hideSearchView;

@end
