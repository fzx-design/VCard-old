//
//  DetailImageViewController.m
//  PushBox
//
//  Created by Hasky on 11-2-27.
//  Copyright 2011 同济大学. All rights reserved.
//

#import "DetailImageViewController.h"
#import "UIApplicationAddition.h"
#import "UIImageViewAddition.h"
#import "CoreDataViewController.h"
#import "DetailImageViewController.h"
#import "Status.h"
#import "PushBoxAppDelegate.h"

#define kScreenCenter CGPointMake(1024.0/2, 768.0/2)

@implementation DetailImageViewController

@synthesize imageView = _imageView;
@synthesize webView = _webView;
@synthesize activityView = _activityView;
@synthesize scrollView = _scrollView;
@synthesize delegate = _delegate;
@synthesize image = _image;
@synthesize gifUrl = _gifUrl;
@synthesize url = _url;
@synthesize webViewCoverButton = _webViewCoverButton;

- (id)initWithImage:(UIImage *)image
{   
    self.gifUrl = nil;
    
	self = [super init];
	if (self) {
		self.image = image;
	}
	return self;
}

- (id)initWithUrl:(NSString*)url
{
    self.gifUrl = nil;
    
    self = [super init];
    if (self) {
        self.url = url;
    }
    
    return self;
}

- (void)viewDidLoad {
    self.activityView.alpha = 1.0;
    [self.activityView startAnimating];
    
    [super viewDidLoad];
	
    NSManagedObjectContext* context = [(PushBoxAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    //
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:tapGesture];
    [tapGesture release];
//    //
//    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
//    tapGesture2.numberOfTapsRequired = 1;
//    tapGesture2.numberOfTouchesRequired = 1;
//    [self.webView addGestureRecognizer:tapGesture2];
//    [tapGesture2 release];
//
//    //
//    for (id subview in self.webView.subviews){
//        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
//            ((UIScrollView *)subview).scrollEnabled = NO;
//        ((UIScrollView *)subview).bounces = NO;
//    }
    
    if (self.gifUrl) {
        [self.imageView setHidden:YES];
        
        NSString* htmlStr = [[[NSString alloc] initWithFormat:@"<html><head><link href=\"smartcard.css\" rel=\"stylesheet\" type=\"text/css\" /></head><body><div id=\"gifImg\"><img src=\"%@\"></div></body></html>", self.gifUrl] autorelease];
        [self.webView loadHTMLString:htmlStr baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    }
    else {
        [self.webView setHidden:YES];
        [self.webViewCoverButton setHidden:YES];
        
        [self.imageView loadImageFromURL:_url 
                              completion:^(void)
         {
             CGRect frame = self.imageView.frame;
             CGSize size = self.imageView.image.size;
             frame.size = size;
             self.imageView.frame = frame;
             // <
             if (size.height <= 748) {
                 if (size.width <= 1024) {
                     frame.origin.x = 1024/2 - size.width/2;
                     frame.origin.y = 748/2 - size.height/2;
                 }
                 else {
                     frame.origin.x = 0;
                     frame.origin.y = 748/2 - size.height/2;
                 }
             }
             
             // >
             else {
                 frame.origin.y = 0;
                 if (size.width <= 1024) {
                     frame.origin.x = 1024/2 - size.width/2;
                 }
                 else {
                     frame.origin.x = 0;
                 }
             }
             
             self.imageView.frame = frame;
             self.scrollView.delegate = self;
             
             self.scrollView.contentSize = size;
             
             [self.activityView stopAnimating];
             self.imageView.alpha = 0.0;
             [UIView animateWithDuration:0.3 animations:^(void) {
                 self.imageView.alpha = 1.0;
                 self.activityView.alpha = 0.0;
             }];
         }
                          cacheInContext:context];
    }
}

- (void)imageViewClicked:(id)sender
{
    [self dismiss:nil];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    self.imageView = nil;
    self.scrollView = nil;
    self.delegate = nil;
    self.webView = nil;
}


- (void)dealloc {
    [_imageView release];
    [_scrollView release];
    [_image release];
    [_webView release];
    [super dealloc];
}

- (IBAction)saveImage:(UIButton *)sender
{
    
    [[UIApplication sharedApplication] showLoadingView];
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:finishedSavingWithError:contextInfo:), NULL);
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    [[UIApplication sharedApplication] hideLoadingView];
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"保存失败", nil)
                              message:NSLocalizedString(@"无法保存图片", nil)
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    else {
        [[UIApplication sharedApplication] showOperationDoneView];
    }
    
}

- (IBAction)dismiss:(UIButton *)sender
{
    [self.delegate detailImageViewControllerShouldDismiss:self];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (self.gifUrl) {
        return self.webView;
    }
    else {
        return self.imageView;
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (self.gifUrl) {
//        CGSize size = _webView.frame.size;
//        CGRect frame = self.webView.frame;
//        // <
//        if (size.height <= 748) {
//            if (size.width <= 1024) {
//                frame.origin.x = 1024/2 - size.width/2;
//                frame.origin.y = 748/2 - size.height/2;
//            }
//            else {
//                frame.origin.x = 0;
//                frame.origin.y = 748/2 - size.height/2;
//            }
//        }
//        
//        // >
//        else {
//            frame.origin.y = 0;
//            if (size.width <= 1024) {
//                frame.origin.x = 1024/2 - size.width/2;
//            }
//            else {
//                frame.origin.x = 0;
//            }
//        }
//        
//        self.imageView.frame = frame;
//        self.scrollView.contentSize = size;
        
    }
    else {
        CGSize size = _imageView.frame.size;
        CGRect frame = self.imageView.frame;
        // <
        if (size.height <= 748) {
            if (size.width <= 1024) {
                frame.origin.x = 1024/2 - size.width/2;
                frame.origin.y = 748/2 - size.height/2;
            }
            else {
                frame.origin.x = 0;
                frame.origin.y = 748/2 - size.height/2;
            }
        }
        
        // >
        else {
            frame.origin.y = 0;
            if (size.width <= 1024) {
                frame.origin.x = 1024/2 - size.width/2;
            }
            else {
                frame.origin.x = 0;
            }
        }
        
        self.imageView.frame = frame;
        self.scrollView.contentSize = size;
    }
    
}

#pragma - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.activityView.alpha = 1.0;
    [self.activityView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityView stopAnimating];
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.activityView.alpha = 0.0;
    }];
}

@end
