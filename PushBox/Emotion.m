//
//  Emotion.m
//  PushBox
//
//  Created by Kelvin Ren on 11/19/11.
//  Copyright (c) 2011 同济大学. All rights reserved.
//

#import "Emotion.h"


@implementation Emotion

@dynamic phrase;
@dynamic type;
@dynamic url;
@dynamic is_hot;
@dynamic is_common;
@dynamic order_number;
@dynamic category;

+ (Emotion *)insertEmotion:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *phrase = [dict objectForKey:@"phrase"];
    
    if (!phrase || [phrase isEqualToString:@""]) {
        return nil;
    }
    
    Emotion *result = [Emotion emotionWithPhrase:phrase inManagedObjectContext:context];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Emotion" inManagedObjectContext:context];
    }
    
    result.phrase = [dict objectForKey:@"phrase"];
    result.type = [dict objectForKey:@"type"];
    result.url = [dict objectForKey:@"url"];
    result.is_hot = [NSNumber numberWithBool:[[dict objectForKey:@"is_hot"] boolValue]];
    result.is_common = [NSNumber numberWithBool:[[dict objectForKey:@"is_common"] boolValue]];
    result.order_number = [NSNumber numberWithInt:[[dict objectForKey:@"order_number"] intValue]];
    result.category = [dict objectForKey:@"category"];
    
    NSLog(@"---------------%@", result.category);
    
    return result;
}

+ (Emotion *)emotionWithPhrase:(NSString *)phrase inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Emotion" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"phrase == %@", phrase]];
    
    Emotion *res = [[context executeFetchRequest:request error:NULL] lastObject];
    
    [request release];
    
    return res;
    
}

@end
