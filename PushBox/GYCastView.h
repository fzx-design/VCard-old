//
//  GYCastView.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-13.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RefreshFirstPageIndex 0
#define RefreshSecondPageIndex 1

@class GYCastView;

@protocol GYCastViewDelegate

@required
- (UIView*)viewForItemAtIndex:(GYCastView*)scrollView index:(int)index;
- (int)itemCount:(GYCastView*)scrollView;
- (void)didScrollToIndex:(int)index;
- (void)loadMoreViews;

@end

@interface GYCastView : UIView<UIScrollViewDelegate> {
	UIScrollView *scrollView;	
	id <GYCastViewDelegate, NSObject> delegate;
	NSMutableArray *scrollViewPages;
	BOOL firstLayout;
	CGSize pageSize;
	BOOL dropShadow;
	NSInteger pageNum;
	NSInteger prePage;
	
	BOOL testKey;
}
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, assign) id<GYCastViewDelegate, NSObject> delegate;
@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, assign) BOOL dropShadow;
@property (nonatomic) NSInteger pageNum;

- (void)reloadViews;
- (void)addMoreViews;
- (void)refreshViewsWithFirstPage:(UIView*)firstView 
					andSecondPage:(UIView*)secondView;

- (void)didReceiveMemoryWarning;
- (id)initWithFrameAndPageSize:(CGRect)frame pageSize:(CGSize)size;
- (void)setScrollsToTop:(BOOL)scrollsToTop;

@end