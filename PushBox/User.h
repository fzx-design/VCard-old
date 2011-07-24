//
//  User.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Status;

@interface User : NSManagedObject {
@private
}

@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * selfDescription;
@property (nonatomic, retain) NSString * blogURL;
@property (nonatomic, retain) NSString * profileImageURL;
@property (nonatomic, retain) NSString * domainURL;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * followersCount;
@property (nonatomic, retain) NSString * friendsCount;
@property (nonatomic, retain) NSString * statusesCount;
@property (nonatomic, retain) NSString * favouritesCount;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * verified;
@property (nonatomic, retain) NSNumber * following;
@property (nonatomic, retain) NSSet *statuses;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *friendsStatuses;

+ (User *)insertUser:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context;
+ (User *)userWithID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addStatusesObject:(Status *)value;
- (void)removeStatusesObject:(Status *)value;
- (void)addStatuses:(NSSet *)values;
- (void)removeStatuses:(NSSet *)values;

- (void)addCommentsObject:(NSManagedObject *)value;
- (void)removeCommentsObject:(NSManagedObject *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addFriendsStatusesObject:(Status *)value;
- (void)removeFriendsStatusesObject:(Status *)value;
- (void)addFriendsStatuses:(NSSet *)values;
- (void)removeFriendsStatuses:(NSSet *)values;

@end
