//
//  Status.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Status : NSManagedObject {
@private
    
}

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * statusID;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSNumber * favorited;
@property (nonatomic, retain) NSString * thumbnailPicURL;
@property (nonatomic, retain) NSString * bmiddlePicURL;
@property (nonatomic, retain) NSString * originalPicURL;
@property (nonatomic, retain) User *author;
@property (nonatomic, retain) Status *repostStatus;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) User *isFriendsStatusOf;
@property (nonatomic, retain) NSString * commentsCount;
@property (nonatomic, retain) NSString * repostsCount;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) User *favoritedBy;

- (BOOL)isEqualToStatus:(Status *)status;
+ (Status *)insertStatus:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Status *)statusWithID:(NSString *)statudID inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteAllObjectsInManagedObjectContext:(NSManagedObjectContext *)context;

@end

@interface Status (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(NSManagedObject *)value;
- (void)removeCommentsObject:(NSManagedObject *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end

