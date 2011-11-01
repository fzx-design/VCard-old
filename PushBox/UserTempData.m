//
//  UserTempData.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-1.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "UserTempData.h"
#import "NSDateAddition.h"

@implementation UserTempData

@synthesize userID;
@synthesize screenName;
@synthesize location;
@synthesize selfDescription;
@synthesize blogURL;
@synthesize profileImageURL;
@synthesize domainURL;
@synthesize gender;
@synthesize followersCount;
@synthesize friendsCount;
@synthesize statusesCount;
@synthesize favouritesCount;
@synthesize createdAt;
@synthesize verified;
@synthesize following;
@synthesize statuses;
@synthesize comments;
@synthesize friendsStatuses;
@synthesize updateDate;
@synthesize followers;
@synthesize friends;
@synthesize favorites;
@synthesize commentsToMe;
@synthesize managedObjectContext;

+ (UserTempData *)getUserInDictionary:(NSDictionary *)dict withContext:(NSManagedObjectContext *)context
{
	NSString *userID = [[dict objectForKey:@"id"] stringValue];
    
    if (!userID || [userID isEqualToString:@""]) {
        return nil;
    }
    
    UserTempData *result = [[UserTempData alloc] init];;
    
    result.updateDate = [NSDate date];
    
    result.userID = userID;
    result.screenName = [dict objectForKey:@"screen_name"];
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    
    result.profileImageURL = [dict objectForKey:@"profile_image_url"];
    result.gender = [dict objectForKey:@"gender"];
    result.selfDescription = [dict objectForKey:@"description"];
    result.location = [dict objectForKey:@"location"];
    result.verified = [NSNumber numberWithBool:[[dict objectForKey:@"verified"] boolValue]];
    
    result.domainURL = [dict objectForKey:@"domain"];
    result.blogURL = [dict objectForKey:@"url"];
    
    result.friendsCount = [[dict objectForKey:@"friends_count"] stringValue];
    result.followersCount = [[dict objectForKey:@"followers_count"] stringValue];
    result.statusesCount = [[dict objectForKey:@"statuses_count"] stringValue];
    result.favouritesCount = [[dict objectForKey:@"favourites_count"] stringValue];
    
    BOOL following = [[dict objectForKey:@"following"] boolValue];
	
    result.following = [NSNumber numberWithBool:following];
	
	result.managedObjectContext = context;
    
    return result;
}

@end
