//
//  BackgroundManViewController.h
//  PushBox
//
//  Created by Hasky on 11-1-29.
//  Copyright 2011 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

enum PBBackgroundImage {
	PBBackgroundImageDefault,
	PBBackgroundImageDream,
	PBBackgroundImageLake,
	PBBackgroundImageMask,
	PBBackgroundImagePencils,
	PBBackgroundImageWooden,
};

#define kUserDefaultKeyBackground @"kUserDefaultKeyBackground"
#define kNotificationNameBackgroundChanged @"kNotificationNameBackgroundChanged"

@interface BackgroundManViewController : UITableViewController {

}

+ (NSString *)backgroundDescriptionFromEnum:(int)enumValue;
+ (NSString *)backgroundImageFilePathFromEnum:(int)enumValue;
+ (NSString *)backgroundIconFilePathFromEnum:(int)enumValue;

@end
