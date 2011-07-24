//
//  Status.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "Status.h"
#import "User.h"

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
    
    Status *result = [Status statusWithID:statusID inManagedObjectContext:context];
    if (result) {
        return result; 
    }

    result = [NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:context];
    
    result.statusID = statusID;
    
//    result.createdAt = 
    
    result.text = [dict objectForKey:@"text"];
    NSLog(@"text:%@", result.text);
    
    result.source = [dict objectForKey:@"source"];
    
    result.favorited = [NSNumber numberWithBool:[[dict objectForKey:@"favorited"] boolValue]];

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


@end
