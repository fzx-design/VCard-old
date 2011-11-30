//
//  SystemDefault.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-30.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemDefault : NSObject

@property (nonatomic, readonly) BOOL pileUpEnabled;
@property (nonatomic, readonly) BOOL readTagEnabled;

+ (SystemDefault*)systemDefault;

@end
