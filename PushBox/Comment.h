//
//  Comment.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Status, User;

@interface Comment : NSManagedObject 

@property (nonatomic, retain) NSString * commentID;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) User *author;
@property (nonatomic, retain) Status *targetStatus;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) User *targetUser;


+ (Comment *)insertComment:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Comment *)commentWithID:(NSString *)commentID inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteAllObjectsInManagedObjectContext:(NSManagedObjectContext *)context;
- (BOOL)isEqualToComment:(Comment *)comment;

@end
