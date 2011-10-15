//
//  NSDateAddition.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-29.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "NSDateAddition.h"

@implementation NSDate (NSDateAddition)

+ (NSDate *)dateFromStringRepresentation:(NSString *)dateString
{
    time_t timeStamp = 0;
	struct tm created;
	if (dateString) {
		if (strptime([dateString UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
			strptime([dateString UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
		}
		timeStamp = mktime(&created);
	}
    
    NSDate *date = nil;
    
    if (timeStamp) {
        date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    }
    
    return date;
}

- (NSString *)stringRepresentation
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *dateStr = [formatter stringFromDate:self];
    return dateStr;
}

@end
