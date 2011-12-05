//
//  GYCastView.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-13.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FirstPageIndex 0
#define SecondPageIndex 1
#define ThirdPageIndex 2
#define InitialIndex 10000000

#define kNumberOfCardsInSection 10

@class GYCastView;

@protocol GYCastViewDelegate

@required
- (UIView*)viewForItemAtIndex:(GYCastView*)scrollView index:(int)index;
- (int)itemCount:(GYCastView*)scrollView;

- (void)didScrollToIndex:(int)index;
- (void)loadMoreViews;
- (void)resetViewsAroundCurrentIndex:(int)index;

@end

@interface GYCastView : UIView<UIScrollViewDelegate> {
	UIScrollView *scrollView;	
	id <GYCastViewDelegate, NSObject> delegate;
	NSMutableArray *scrollViewPages;
	BOOL firstLayout;
	BOOL animating;
	CGSize pageSize;
	BOOL dropShadow;
	NSInteger pageNum;
	NSInteger prePage;
	
	NSInteger pageSection;
    
    BOOL loadingMoreViewsFlag;
    
    BOOL _test;
}
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, assign) id<GYCastViewDelegate, NSObject> delegate;
@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, assign) BOOL dropShadow;
@property (nonatomic) NSInteger pageNum;

@property (nonatomic, assign) NSInteger pageSection;
@property (nonatomic, assign) BOOL scrollEnabled;

- (void)removeAllSubviews;
- (void)changeViews;
- (void)reloadViews;
- (void)deleteView;
- (void)moveOutViews:(void (^)())completion;
- (void)addMoreViews;
- (void)addMoreViewsWithoutSection;
- (void)refreshViewsWithFirstPage:(UIView*)firstView 
					andSecondPage:(UIView*)secondView;

- (void)moveViewsWithPageOffset:(int)offset 
				 andCurrentPage:(int)currentPage;

- (void)moveViewsWithPageOffset:(int)diff 
				 andCurrentPage:(int)index 
				  withFirstPage:(UIView*)view1 
					 secondPage:(UIView*)view2 
					  thirdPage:(UIView*)view3;

- (void)resetWithCurrentIndex:(int)index numberOfPages:(int)page;

- (id)initWithFrameAndPageSize:(CGRect)frame pageSize:(CGSize)size;
- (void)setScrollsToTop:(BOOL)scrollsToTop;

@end