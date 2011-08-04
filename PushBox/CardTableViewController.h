//
//  CardTableViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-26.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "CardTableViewCell.h"

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
    
    CardTableViewDataSource _dataSource;
    User *_user;
    
    int _currentRowIndex;
    BOOL _swipeEnabled;
    int _nextPage;
    id _delegate;
    
    NSFetchedResultsController *_prevFetchedResultsController;
    int _prevRowIndex;
}

@property(nonatomic, retain) IBOutlet UIImageView *blurImageView;
@property(nonatomic, assign) id<CardTableViewControllerDelegate> delegate;
@property(nonatomic, assign) int currentRowIndex;
@property(nonatomic, assign) BOOL swipeEnabled;
@property(nonatomic, assign) CardTableViewDataSource dataSource;
@property(nonatomic, retain) User *user;
@property(nonatomic, retain) NSFetchedResultsController* prevFetchedResultsController;
@property(nonatomic, assign) int prevRowIndex;

- (void)pushCardWithCompletion:(void (^)())completion;
- (void)popCardWithCompletion:(void (^)())completion;

- (int)numberOfRows;

- (void)loadAllFavoritesWithCompletion:(void (^)())completion;
- (void)loadMoreData;
- (void)clearData;
- (void)refresh;

- (void)showNextCard;
- (void)scrollToRow:(int)row;

@end
