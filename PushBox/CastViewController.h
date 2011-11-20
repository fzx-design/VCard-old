//
//  CastViewController.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-14.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "UserCardNaviViewController.h"
#import "ErrorNotification.h"
#import "GYCastView.h"
#import "CastViewInfo.h"
#import "CastViewManager.h"
#import "Status.h"

#define kNotificationNameNewCommentsToMe @"kNotificationNameNewCommentsToMe"
#define kNotificationNameNewStatuses @"kNotificationNameNewStatuses"
#define kNotificationNameNewFollowers @"kNotificationNameNewFollowers"
#define kNotificationNameReMoveCardsIntoView @"kNotificationReMoveCardsIntoView"
#define kNotificationNameNewNotification @"kNotificationNameNewNotification"
#define kNotificationNameNewMentions @"kNotificationNameNewMentions"

@class User;

@interface CastViewController : CoreDataTableViewController <GYCastViewDelegate> {
	UIImageView *_blurImageView;
	UIImageView *_rootShadowLeft;
	UIButton *_regionLeftDetectButton;
	UIButton *_regionRightDetectButton;
	GYCastView *_castView;
	
	User *_user;
	CastViewDataSource _dataSource;
	CastViewDataSource _prevDataSource;
	
	NSTimer *_timer;
	
//	NSMutableArray *_nextPageStack;
//	NSMutableArray *_rowIndexStack;
//	NSMutableArray *_fetchedResultsControllerStack;
	
	NSMutableArray *_infoStack;
	
	CastViewManager *_castViewManager;
	
	int _nextPage;
	int _currentNextPage;
	int _oldNextPage;
	
	NSFetchedResultsController *_prevFetchedResultsController;
	
	long long _lastStatusID;
	
	BOOL _loading;
	BOOL _refreshFlag;
	
}

@property(nonatomic, retain) IBOutlet UIButton *regionLeftDetectButton;
@property(nonatomic, retain) IBOutlet UIButton *regionRightDetectButton;
@property(nonatomic, retain) IBOutlet UIImageView *blurImageView;
@property(nonatomic, retain) IBOutlet UIImageView *rootShadowLeft;
@property(nonatomic, retain) IBOutlet GYCastView *castView;

@property(nonatomic, retain) User *user;
@property(nonatomic, assign) CastViewDataSource dataSource;
@property(nonatomic, assign) CastViewDataSource prevDataSource;
@property(nonatomic, retain) CastViewManager *castViewManager;

//@property(nonatomic, retain) NSMutableArray *nextPageStack;
//@property(nonatomic, retain) NSMutableArray *rowIndexStack;
//@property(nonatomic, retain) NSMutableArray *fetchedResultsControllerStack;

@property(nonatomic, retain) NSMutableArray *infoStack;

@property(nonatomic, retain) NSFetchedResultsController* prevFetchedResultsController;


- (void)pushCardWithCompletion:(void (^)())completion;
- (BOOL)popCardWithCompletion:(void (^)())completion;

- (void)getUnread;

- (void)loadAllFavoritesWithCompletion:(void (^)())completion;
- (void)loadMoreDataCompletion:(void (^)())completion;
- (void)clearData;
- (void)refresh;
- (void)firstLoad:(void (^)())completion;

- (void)showNextCard;
- (void)scrollToRow:(int)row;
- (void)configureUsability;
- (IBAction)dismissRegionTouched:(id)sender;
- (void)enableDismissRegion;
- (void)disableDismissRegion;

@end
