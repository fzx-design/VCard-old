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

#define kNotificationNameNewCommentsToMe @"kNotificationNameNewCommentsToMe"
#define kNotificationNameNewStatuses @"kNotificationNameNewStatuses"
#define kNotificationNameNewFollowers @"kNotificationNameNewFollowers"

typedef enum {
    CardTableViewDataSourceFriendsTimeline,
    CardTableViewDataSourceUserTimeline,
    CardTableViewDataSourceFavorites,
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
    
    int _currentRowIndex;
    BOOL _swipeEnabled;
    int _nextPage;
    id _delegate;
    
    NSFetchedResultsController *_prevFetchedResultsController;
    int _prevRowIndex;
    
    NSTimer *_timer;
    BOOL _loading;
    
    BOOL _insertionAnimationEnabled;
	
	BOOL _checkingDirection;
	NSInteger _direction;
	CGFloat dragStartOffset;
	CGFloat preDiff;
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

- (void)pushCardWithCompletion:(void (^)())completion;
- (void)popCardWithCompletion:(void (^)())completion;

- (int)numberOfRows;

- (void)getUnread;

- (void)loadAllFavoritesWithCompletion:(void (^)())completion;
- (void)loadMoreDataCompletion:(void (^)())completion;
- (void)clearData;
- (void)refresh;

- (void)showNextCard;
- (void)scrollToRow:(int)row;

-(IBAction)dismissRegionTouched:(id)sender;
-(void)enableDismissRegion;
-(void)disableDismissRegion;

@end
