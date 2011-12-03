//
//  ReadStatusID.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-12-3.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ReadStatusID : NSManagedObject

@property (nonatomic, retain) NSString * statusID;

+ (ReadStatusID *)insertStatusID:(long long)statusID inManagedObjectContext:(NSManagedObjectContext *)context;

@end
