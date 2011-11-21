//
//  ErrorNotification.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-18.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorNotification : NSObject

+ (void)showLoadingError;
+ (void)showPostError;
+ (void)showOperationError;
+ (void)showNoResultsError;
@end
