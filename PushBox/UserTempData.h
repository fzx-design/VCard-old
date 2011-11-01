//
//  UserTempData.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-1.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserTempData : NSObject

@property (nonatomic, copy) NSString * userID;
@property (nonatomic, copy) NSString * screenName;
@property (nonatomic, copy) NSString * location;
@property (nonatomic, copy) NSString * selfDescription;
@property (nonatomic, copy) NSString * blogURL;
@property (nonatomic, copy) NSString * profileImageURL;
@property (nonatomic, copy) NSString * domainURL;
@property (nonatomic, copy) NSString * gender;
@property (nonatomic, copy) NSString * followersCount;
@property (nonatomic, copy) NSString * friendsCount;
@property (nonatomic, copy) NSString * statusesCount;
@property (nonatomic, copy) NSString * favouritesCount;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * verified;
@property (nonatomic, retain) NSNumber * following;
@property (nonatomic, retain) NSSet *statuses;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *friendsStatuses;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSSet *followers;
@property (nonatomic, retain) NSSet *friends;
@property (nonatomic, retain) NSSet *favorites;
@property (nonatomic, retain) NSSet *commentsToMe;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (UserTempData *)getUserInDictionary:(NSDictionary *)dict withContext:(NSManagedObjectContext *)context;

@end
