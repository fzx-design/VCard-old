//
//  ReadStatusID.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-12-3.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "ReadStatusID.h"

@implementation ReadStatusID

@dynamic statusID;

+ (ReadStatusID *)statusIDWithIDinString:(NSString*)statusIDinString inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"ReadStatusID" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"statusID == %@", statusIDinString]];
    
    ReadStatusID *res = [[context executeFetchRequest:request error:NULL] lastObject];
    
    [request release];
    
    return res;
    
}

+ (ReadStatusID *)insertStatusID:(long long)statusID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *statusIDinString = [NSString stringWithFormat:@"%lld", statusID];
    
    ReadStatusID *result = [ReadStatusID statusIDWithIDinString:statusIDinString inManagedObjectContext:context];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"ReadStatusID" inManagedObjectContext:context];
    }
    
    result.statusID = statusIDinString;
        
    return result;
}

+ (void)deleteAllObjectsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReadStatusID" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    [fetchRequest release];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}



@end
