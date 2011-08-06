//
//  Image.m
//  PushBox
//
//  Created by Xie Hasky on 11-8-3.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "Image.h"


@implementation Image
@dynamic url;
@dynamic data;
@dynamic updateDate;

+ (Image *)imageWithURL:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Image" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"url == %@", url]];
    
    Image *res = [[context executeFetchRequest:request error:NULL] lastObject];
    
    [request release];
    
    return res;
}

+ (Image *)insertImage:(NSData *)data withURL:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context
{
    
    if (!url || [url isEqualToString:@""]) {
        return nil;
    }
    
    Image *image = [self imageWithURL:url inManagedObjectContext:context];
    
    if (!image) {
        image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
    }
    
    image.data = data;
    image.url = url;
    image.updateDate = [NSDate date];
    
    [Image clearCacheInContext:context];
    
    return image;
}

+ (void)clearCacheInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Image" inManagedObjectContext:context]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateDate"
                                                                     ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *resultArray = [context executeFetchRequest:request error:NULL];
    
    if (resultArray.count > 40) {
        [resultArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [context deleteObject:obj];
            if (idx > 10) {
                *stop = YES;
            }
        }];
    }
    
    [request release];
}

@end
