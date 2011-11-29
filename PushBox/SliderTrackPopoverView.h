//
//  SliderTrackPopoverView.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-21.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXLabel.h"

@interface SliderTrackPopoverView : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView *proFileImage;
@property (nonatomic, retain) IBOutlet FXLabel *screenNameLabel;

@property (nonatomic, retain) IBOutlet FXLabel *stackLabel;
@property (nonatomic, retain) IBOutlet FXLabel *stackDateLabel;

@property (nonatomic, retain) IBOutlet UIView *userInfoView;
@property (nonatomic, retain) IBOutlet UIView *stackInfoView;


@end
