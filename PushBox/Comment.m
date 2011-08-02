//
//  Comment.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "Comment.h"
#import "Status.h"
#import "User.h"
#import "NSDateAddition.h"

@implementation Comment
@dynamic commentID;
@dynamic text;
@dynamic source;
@dynamic createdAt;
@dynamic author;
@dynamic targetStatus;
@dynamic updateDate;

+ (Comment *)insertComment:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *commentID = [[dict objectForKey:@"id"] stringValue];
    
    if (!commentID || [commentID isEqualToString:@""]) {
        return nil;
    }
    
    Comment *result = [Comment commentWithID:commentID inManagedObjectContext:context];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
    }
    
    result.commentID = commentID;
    
    result.updateDate = [NSDate date];
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    
    result.text = [dict objectForKey:@"text"];
    
    NSDictionary *statusDict = [dict objectForKey:@"status"];
    
    if (statusDict) {
        result.targetStatus = [Status insertStatus:statusDict inManagedObjectContext:context];
    }
    
    NSDictionary *userDict = [dict objectForKey:@"user"];
    
    if (userDict) {
        result.author = [User insertUser:userDict inManagedObjectContext:context];
    }
    
    return result;
    
}

+ (Comment *)commentWithID:(NSString *)commentID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"commentID == %@", commentID]];
    
    Comment *res = [[context executeFetchRequest:request error:NULL] lastObject];
    
    [request release];
    
    return res;
}

+ (void)deleteAllObjectsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    [fetchRequest release];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

- (BOOL)isEqualToComment:(Comment *)comment
{
    return [self.commentID isEqualToString:comment.commentID];
}

@end
