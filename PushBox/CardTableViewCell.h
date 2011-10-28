//
//  CardTableViewCell.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-26.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatusCardViewController.h"
#import "SmartCardViewController.h"

@interface CardTableViewCell : UITableViewCell {
    StatusCardViewController *_statusCardViewController;
    SmartCardViewController *_smartCardViewController;
}

@property(nonatomic, retain) StatusCardViewController* statusCardViewController;
@property(nonatomic, retain) SmartCardViewController* smartCardViewController;

- (void)clear;

@end
