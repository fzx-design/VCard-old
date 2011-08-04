//
//  Status.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "Status.h"
#import "User.h"
#import "NSDateAddition.h"

@implementation Status

@dynamic createdAt;
@dynamic statusID;
@dynamic text;
@dynamic source;
@dynamic favorited;
@dynamic thumbnailPicURL;
@dynamic bmiddlePicURL;
@dynamic originalPicURL;
@dynamic author;
@dynamic repostStatus;
@dynamic comments;
@dynamic isFriendsStatusOf;
@dynamic commentsCount;
@dynamic repostsCount;
@dynamic updateDate;
@dynamic favoritedBy;

- (BOOL)isEqualToStatus:(Status *)status
{
    return [self.statusID isEqualToString:status.statusID];
}

+ (Status *)statusWithID:(NSString *)statudID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"statusID == %@", statudID]];
    
    Status *res = [[context executeFetchRequest:request error:NULL] lastObject];
    
    [request release];
    
    return res;
}

+ (Status *)insertStatus:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *statusID = [[dict objectForKey:@"id"] stringValue];
    
    if (!statusID || [statusID isEqualToString:@""]) {
        return nil;
    }
    
    Status *result = [Status statusWithID:statusID inManagedObjectContext:context];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:context];
    }

    result.updateDate = [NSDate date];
    
    result.statusID = statusID;
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    
    result.text = [dict objectForKey:@"text"];
    
    result.source = [dict objectForKey:@"source"];
    
    result.favorited = [NSNumber numberWithBool:[[dict objectForKey:@"favorited"] boolValue]];
    
    result.commentsCount = [dict objectForKey:@"comment_count"];
    result.repostsCount = [dict objectForKey:@"repost_count"];

    result.thumbnailPicURL = [dict objectForKey:@"thumbnail_pic"];
    result.bmiddlePicURL = [dict objectForKey:@"bmiddle_pic"];
    result.originalPicURL = [dict objectForKey:@"original_pic"];
    
    NSDictionary *userDict = [dict objectForKey:@"user"];
    
    result.author = [User insertUser:userDict inManagedObjectContext:context];
    
    NSDictionary* repostedStatusDict = [dict objectForKey:@"retweeted_status"];
    if (repostedStatusDict) {
        result.repostStatus = [Status insertStatus:repostedStatusDict inManagedObjectContext:context];
    }
    
    return result;
}

+ (void)deleteAllObjectsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    [fetchRequest release];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}


@end
