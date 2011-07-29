//
//  UIImageViewAddition.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-28.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "UIImageViewAddition.h"

@implementation UIImageView (UIImageViewAddition)

- (void)loadImageFromURL:(NSString *)urlString completion:(void (^)())completion
{
	
	self.backgroundColor = [UIColor clearColor];
	
    NSURL *url = [NSURL URLWithString:urlString];
		
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloadQueue", NULL);
		
    dispatch_async(downloadQueue, ^{ 
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = img;
            if (completion) {
                completion();
            }				
        });
    });
    
    dispatch_release(downloadQueue);
	
}

@end
