//
//  EmotionsViewController.h
//  PushBox
//
//  Created by Kelvin Ren on 11/22/11.
//  Copyright (c) 2011 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmotionsViewControllerDelegate <NSObject>
- (void)didSelectEmotion:(NSString*)phrase;
@end

@interface EmotionsViewController : UIViewController
{
    NSMutableArray *_emotions;
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    
    id<EmotionsViewControllerDelegate> _delegate;
}

@property (nonatomic, retain) NSMutableArray* emotions;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;
@property (nonatomic, retain) id<EmotionsViewControllerDelegate> delegate;


- (NSString*)emotionClicked:(UIButton *)button;

@end
