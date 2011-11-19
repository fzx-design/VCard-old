//
//  AnimationProvider.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-23.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "AnimationProvider.h"

@implementation AnimationProvider

+ (CAKeyframeAnimation*)popoverAnimation
{
	CAKeyframeAnimation * animation; 
	animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"]; 
	animation.duration = 0.5; 
	animation.delegate = self;
	animation.removedOnCompletion = YES;
	animation.fillMode = kCAFillModeForwards;
	
	NSMutableArray *values = [NSMutableArray array];
	[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
	[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]]; 
	[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]]; 
	[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
	
	animation.values = values;
	return animation;
}

+ (CATransition*)cubeAnimationDown
{
	CATransition *animation = [CATransition animation];
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
	animation.fillMode = kCAFillModeForwards;
	animation.removedOnCompletion = NO;
	animation.type = @"cube";
	animation.subtype = kCATransitionFromTop;
	
	return animation;
}

+ (CATransition*)cubeAnimationUp
{
	CATransition *animation = [CATransition animation];
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
	animation.fillMode = kCAFillModeForwards;
	animation.removedOnCompletion = NO;
	animation.type = @"cube";
	animation.subtype = kCATransitionFromBottom;
	
	return animation;
}

@end
