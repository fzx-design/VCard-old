//
//  CoreDataViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserTempData.h"

@class User;

@interface CoreDataViewController : UIViewController {
    NSManagedObjectContext *_managedObjectContext;
    UserTempData *_currentUser;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UserTempData *currentUser;

@end
