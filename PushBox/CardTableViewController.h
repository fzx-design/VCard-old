//
//  CardTableViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-26.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "CardTableViewCell.h"
#import "UserCardNaviViewController.h"
#import "ErrorNotification.h"

#define kNotificationNameNewCommentsToMe @"kNotificationNameNewCommentsToMe"
#define kNotificationNameNewStatuses @"kNotificationNameNewStatuses"
#define kNotificationNameNewFollowers @"kNotificationNameNewFollowers"
#define kNotificationNameReMoveCardsIntoView @"kNotificationReMoveCardsIntoView"
#define kNotificationNameNewNotification @"kNotificationNameNewNotification"
#define kNotificationNameNewMentions @"kNotificationNameNewMentions"

typedef enum {
    CardTableViewDataSourceFriendsTimeline,
    CardTableViewDataSourceUserTimeline,
    CardTableViewDataSourceFavorites,
    CardTableViewDataSourceSearchStatues,
} CardTableViewDataSource;

@class CardTableViewController;
@protocol CardTableViewControllerDelegate <NSObject>
- (void)cardTableViewController:(CardTableViewController *)vc didScrollToRow:(int)row withNumberOfRows:(int)maxRow;
@end

@class User;

@interface CardTableViewController : CoreDataTableViewController {
    UIImageView *_blurImageView;
	UIImageView *_rootShadowLeft;
    
    CardTableViewDataSource _dataSource;
    User *_user;
    
    id _delegate;
    int _nextPage;
    int _currentRowIndex;
    BOOL _swipeEnabled;
    
    NSFetchedResultsController *_prevFetchedResultsController;
    int _prevRowIndex;
    
    NSTimer *_timer;
    BOOL _loading;
    
    BOOL _insertionAnimationEnabled;
	
	BOOL _refreshFlag;
	BOOL _checkingDirection;
	Status *_lastStatus;
	NSInteger _direction;
	CGFloat dragStartOffset;
	CGFloat preDiff;
	
	NSInteger preNewFollowerCount;
	NSInteger preNewCommentCount;
	NSInteger preNewMentionCount;
}

@property(nonatomic, retain) IBOutlet UIButton *regionLeftDetectButton;
@property(nonatomic, retain) IBOutlet UIButton *regionRightDetectButton;
@property(nonatomic, retain) IBOutlet UIImageView *blurImageView;
@property(nonatomic, retain) IBOutlet UIImageView *rootShadowLeft;
@property(nonatomic, assign) id<CardTableViewControllerDelegate> delegate;
@property(nonatomic, assign) int currentRowIndex;
@property(nonatomic, assign) BOOL swipeEnabled;
@property(nonatomic, assign) CardTableViewDataSource dataSource;
@property(nonatomic, retain) User *user;
@property(nonatomic, retain) NSFetchedResultsController* prevFetchedResultsController;
@property(nonatomic, assign) int prevRowIndex;
@property(nonatomic, assign) BOOL insertionAnimationEnabled;
@property(nonatomic, assign) NSString *searchString;

- (void)pushCardWithCompletion:(void (^)())completion;
- (void)popCardWithCompletion:(void (^)())completion;

- (void)pushCardWithoutCompletion;

- (int)numberOfRows;

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
