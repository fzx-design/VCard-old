//
//  UIAudioAddition.m
//  PushBox
//
//  Created by Kelvin Ren on 10/24/11.
//  Copyright (c) 2011 同济大学. All rights reserved.
//

#import "UIAudioAddition.h"

@implementation UIAudioAddition

- (id)init
{
    self = [super init];
    
    //
    NSString* refreshDoneSoundPath = [[NSBundle mainBundle] pathForResource:@"vc_new_sound" ofType:@"wav"];
    if (refreshDoneSoundPath) {
        NSURL* refreshDoneSoundUrl = [NSURL fileURLWithPath:refreshDoneSoundPath];
        OSStatus err = AudioServicesCreateSystemSoundID((CFURLRef)refreshDoneSoundUrl, &refreshDoneSound);
        if (err != kAudioServicesNoError) {
            NSLog(@"Could not load %@, error code %d", refreshDoneSoundUrl ,(int)err);
        }
    }
    
    //
    NSString* notificationSoundPath = [[NSBundle mainBundle] pathForResource:@"vc_noti_sound" ofType:@"wav"];
    if (notificationSoundPath) {
        NSURL* notificationSoundUrl = [NSURL fileURLWithPath:notificationSoundPath];
        OSStatus err = AudioServicesCreateSystemSoundID((CFURLRef)notificationSoundUrl, &notificationSound);
        if (err != kAudioServicesNoError) {
            NSLog(@"Could not load %@, error code %d", notificationSoundUrl ,(int)err);
        }
    }
    
    return self;
}

- (void)playRefreshDoneSound
{
    AudioServicesPlaySystemSound(refreshDoneSound);
}

- (void)playNotificationSound
{
    AudioServicesPlaySystemSound(notificationSound);
}

@end
