//
//  UIImageViewAddition.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-28.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "UIImageViewAddition.h"
#import "Image.h"

@implementation UIImageView (UIImageViewAddition)

- (void)loadImageFromURL:(NSString *)urlString 
              completion:(void (^)())completion 
          cacheInContext:(NSManagedObjectContext *)context
{
	
	self.backgroundColor = [UIColor clearColor];
    
//    Image *imageObject = [Image imageWithURL:urlString inManagedObjectContext:context];
//    if (imageObject) {
//        NSData *imageData = imageObject.data;
//        UIImage *img = [UIImage imageWithData:imageData];
//        /////////
//        if (self.image && img) {
//            [self.image release];
//        }
//        ////////
//        self.image = img;
//        if (completion) {
//            completion();
//        }
//        return;
//    }
	
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloadQueue", NULL);
    
    dispatch_async(downloadQueue, ^{ 
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            
//				[Image insertImage:imageData withURL:urlString inManagedObjectContext:context];
//            NSLog(@"cache image url:%@", urlString);
			self.image = nil;
            self.image = img;
            
            if (completion) {
                completion();
            }				
        });
        
    });
    
    dispatch_release(downloadQueue);
	
}

@end
