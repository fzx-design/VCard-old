//
//  CardFrameViewController.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-14.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartCardViewController.h"

@interface CardFrameViewController : UIViewController {
	int _index;
	SmartCardViewController *_contentViewController;
}

@property (nonatomic, assign) int index;
@property (nonatomic, retain) SmartCardViewController* contentViewController;

@end
