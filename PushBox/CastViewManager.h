//
//  CastViewManager.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-18.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GYCastView.h"
#import "User.h"
#import "CastViewInfo.h"

@protocol CastViewControllerDelegate <NSObject>
- (void)castViewControllerdidScrollToRow:(int)row withNumberOfRows:(int)maxRow;
@end

@interface CastViewManager : NSObject {
	GYCastView *_castView;
	
	int _currentIndex;
	
	NSMutableArray *_cardFrames;
	NSFetchedResultsController *_fetchedResultsController;
	User *_currentUser;
	
	id _delegate;
}

@property(nonatomic, retain) GYCastView *castView;

@property(nonatomic, assign) int currentIndex;

@property(nonatomic, retain) NSMutableArray *cardFrames;
@property(nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, retain) User *currentUser;


@property(nonatomic, assign) id<CastViewControllerDelegate> delegate;

- (void)initialSetUp;
- (void)refreshCards;

- (void)pushNewViews;
- (void)popNewViews:(CastViewInfo *)info;

- (int)numberOfRows;

- (UIView*)viewForItemAtIndex:(GYCastView*)scrollView index:(int)index;
- (int)itemCount:(GYCastView*)scrollView;
- (void)didScrollToIndex:(int)index;
- (void)resetViewsAroundCurrentIndex:(int)index;

@end
