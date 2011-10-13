//
//  Message.h
//  PushBox
//
//  Created by Ren Kelvin on 10/11/11.
//  Copyright (c) 2011 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Message : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * sender_id;
@property (nonatomic, retain) NSString * recipient_id;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * sender_screen_name;
@property (nonatomic, retain) NSString * recipient_screen_name;
@property (nonatomic, retain) User *sender;
@property (nonatomic, retain) User *recipient;

@end
