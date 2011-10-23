//
//  AnimationProvider.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-23.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushBoxAppDelegate.h"

@interface AnimationProvider : NSObject

+ (CAKeyframeAnimation*)popoverAnimation;
+ (CATransition*)cubeAnimation;

@end
