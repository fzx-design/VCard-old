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

#define kNotificationNameNewCommentsToMe @"kNotificationNameNewCommentsToMe"
#define kNotificationNameNewStatuses @"kNotificationNameNewStatuses"
#define kNotificationNameNewFollowers @"kNotificationNameNewFollowers"
#define kNotificationNameReMoveCardsIntoView @"kNotificationReMoveCardsIntoView"
#define kNotificationNameNewNotification @"kNotificationNameNewNotification"
#define kNotificationNameNewMentions @"kNotificationNameNewMentions"

typedef enum {
    CastViewDataSourceFriendsTimeline,
    CastViewDataSourceUserTimeline,
    CastViewDataSourceFavorites,
    CastViewDataSourceSearchStatues,
	CastViewDataSourceMentions,
} CastViewDataSource;

@class User;
@class CastViewController;

@protocol CastViewControllerDelegate <NSObject>
- (void)castViewController:(CastViewController *)vc 
			didScrollToRow:(int)row 
		  withNumberOfRows:(int)maxRow;
@end

@interface CastViewController : CoreDataTableViewController<GYCastViewDelegate> {
	UIImageView *_blurImageView;
	UIImageView *_rootShadowLeft;
	UIButton *_regionLeftDetectButton;
	UIButton *_regionRightDetectButton;
	GYCastView *_castView;
	
	User *_user;
	CastViewDataSource _dataSource;
	
	id _delegate;
	NSTimer *_timer;
	
	int _currentIndex;
	NSMutableArray *_nextPageStack;
	NSMutableArray *_rowIndexStack;
	
	NSFetchedResultsController *_prevFetchedResultsController;
	
	BOOL _loading;
}

@property(nonatomic, retain) IBOutlet UIButton *regionLeftDetectButton;
@property(nonatomic, retain) IBOutlet UIButton *regionRightDetectButton;
@property(nonatomic, retain) IBOutlet UIImageView *blurImageView;
@property(nonatomic, retain) IBOutlet UIImageView *rootShadowLeft;
@property(nonatomic, retain) IBOutlet GYCastView *castView;

@property(nonatomic, retain) User *user;
@property(nonatomic, assign) CastViewDataSource dataSource;

@property(nonatomic, assign) id<CastViewControllerDelegate> delegate;
@property(nonatomic, assign) int currentIndex;

@property(nonatomic, retain) NSFetchedResultsController* prevFetchedResultsController;

@end
