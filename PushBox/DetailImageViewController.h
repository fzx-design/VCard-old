//
//  DetailImageViewController.h
//  PushBox
//
//  Created by Hasky on 11-2-27.
//  Copyright 2011 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"

@protocol DetailImageViewControllerDelegate
- (void)detailImageViewControllerShouldDismiss:(UIViewController *)vc;
@end


@interface DetailImageViewController : CoreDataViewController <UIScrollViewDelegate, UIWebViewDelegate> {
	UIImageView *_imageView;
    UIWebView *_webView;
	UIScrollView *_scrollView;
    UIActivityIndicatorView *_activityView;
	
	id _delegate;
	UIImage *_image;
    NSString *_gifUrl;
    NSString *_url;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, assign) IBOutlet id <DetailImageViewControllerDelegate> delegate;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *gifUrl;
@property (nonatomic, retain) NSString *url;

- (id)initWithImage:(UIImage *)image;
- (id)initWithUrl:(NSString*)url;
- (IBAction)saveImage:(UIButton *)sender;
- (IBAction)dismiss:(UIButton *)sender;

@end
