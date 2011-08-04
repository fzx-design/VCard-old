//
//  Image.h
//  PushBox
//
//  Created by Xie Hasky on 11-8-3.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Image : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSDate * updateDate;

+ (Image *)imageWithURL:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Image *)insertImage:(NSData *)data withURL:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)clearCacheInContext:(NSManagedObjectContext *)context;

@end
