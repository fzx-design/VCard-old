//
//  CoreDataViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataViewController.h"
#import "UIApplicationAddition.h"

@implementation CoreDataViewController

@synthesize managedObjectContext = _managedObjectContext;

- (void)dealloc
{
    [_managedObjectContext release];
    [super dealloc];
}

//- (NSManagedObjectContext *)managedObjectContext
//{
//    if (!_managedObjectContext) {
//        _managedObjectContext = [[NSManagedObjectContext alloc] init];
//        _managedObjectContext.persistentStoreCoordinator = [[UIApplication sharedApplication] persistentStoreCoordinator];
//    }
//    
//    return _managedObjectContext;
//}

@end
