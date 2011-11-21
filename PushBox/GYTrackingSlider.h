//
//  GYTrackingSlider.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-21.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SliderTrackPopoverView.h"

@interface GYTrackingSlider : UISlider {
	//    MNESliderValuePopupView *valuePopupView;
	
	SliderTrackPopoverView *trackPopoverView;
}

@property (nonatomic, retain) SliderTrackPopoverView *trackPopoverView;
@property (nonatomic, readonly) CGRect thumbRect;

@end