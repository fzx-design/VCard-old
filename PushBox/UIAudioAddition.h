//
//  UIAudioAddition.h
//  PushBox
//
//  Created by Kelvin Ren on 10/24/11.
//  Copyright (c) 2011 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface UIAudioAddition : NSObject
{
    SystemSoundID refreshDoneSound;
    SystemSoundID notificationSound;
}

- (void)playRefreshDoneSound;
- (void)playNotificationSound;

@end
