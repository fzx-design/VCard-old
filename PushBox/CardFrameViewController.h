//
//  CardFrameViewController.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-14.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartCardViewController.h"
#import "CastViewPile.h"

#define kNotificationNameExpandPile @"kNotificationNameExpandPile"

@interface CardFrameViewController : UIViewController {
	int _index;
	SmartCardViewController *_contentViewController;
    
    UIView *_pileInfoView;
    UILabel *_dateRangeLabel;
    UILabel *_cardNumberLabel;
    UIButton *_pileCoverButton;
    
    UIImageView *_pileBounderShadow;
    
    UIImageView *_pileImageView;
    
    UIImageView *_readImageView;
}

@property (nonatomic, assign) int index;
@property (nonatomic, retain) SmartCardViewController* contentViewController;

@property (nonatomic, retain) IBOutlet UIView* pileInfoView;
@property (nonatomic, retain) IBOutlet UILabel* dateRangeLabel;
@property (nonatomic, retain) IBOutlet UILabel* cardNumberLabel;
@property (nonatomic, retain) IBOutlet UIButton* pileCoverButton;

@property (nonatomic, retain) IBOutlet UIImageView* pileBounderShadow;

@property (nonatomic, retain) IBOutlet UIImageView* pileImageView;

@property (nonatomic, retain) IBOutlet UIImageView* readImageView;

- (void)configureCardFrameWithStatus:(Status*)status;
- (void)configureCardFrameWithStatus:(Status*)status AndPile:(CastViewPile*)pile;

@end
