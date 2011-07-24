//
//  Status.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Status;

@interface Status : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSNumber * favorited;
@property (nonatomic, retain) NSString * thumbnailPicURL;
@property (nonatomic, retain) NSString * bmiddlePicURL;
@property (nonatomic, retain) NSString * originalPicURL;
@property (nonatomic, retain) NSManagedObject *author;
@property (nonatomic, retain) Status *repostStatus;
@property (nonatomic, retain) NSSet *comments;
@end

@interface Status (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(NSManagedObject *)value;
- (void)removeCommentsObject:(NSManagedObject *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
