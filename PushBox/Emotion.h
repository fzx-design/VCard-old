//
//  Emotion.h
//  PushBox
//
//  Created by Kelvin Ren on 11/19/11.
//  Copyright (c) 2011 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Emotion : NSManagedObject

@property (nonatomic, retain) NSString * phrase;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * is_hot;
@property (nonatomic, retain) NSNumber * is_common;
@property (nonatomic, retain) NSNumber * order_number;
@property (nonatomic, retain) NSString * category;

+ (Emotion *)insertEmotion:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Emotion *)emotionWithPhrase:(NSString *)phrase inManagedObjectContext:(NSManagedObjectContext *)context;

@end
