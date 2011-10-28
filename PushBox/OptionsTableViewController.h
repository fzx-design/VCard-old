//
//  OptionsTableViewController.h
//  PushBox
//
//  Created by Hasky on 11-1-29.
//  Copyright 2011 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IntervalManViewController.h"
#import "BackgroundManViewController.h"
#import "RefreshingIntervalViewController.h"
#import "AboutViewController.h"
#import "LegacyViewController.h"

#define kUserDefaultKeyImageDownloadingEnabled @"kUserDefaultKeyImageDownloadingEnabled"
#define kUserDefaultKeySoundEnabled @"kUserDefaultKeySoundEnabled"
#define kUserDefaultKeyNotiPopoverEnabled @"kUserDefaultKeyNotiPopoverEnabled"
#define kNotificationNameUserSignedOut @"kNotificationNameUserSignedOut"

@interface OptionsTableViewController : UITableViewController {

}

@property (nonatomic, copy) NSString* name;

@end
