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
    [super viewDidLoad];
	
    //
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    if (self.gifUrl) {
        [self.imageView setHidden:YES];
        
        NSString* htmlStr = [[NSString alloc] initWithFormat:@"<html><head><link href=\"smartcard.css\" rel=\"stylesheet\" type=\"text/css\" /></head><body><div id=\"gifImg\"><img src=\"%@\"></div></body></html>", self.gifUrl];
        [self.webView loadHTMLString:htmlStr baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    }
    else {
        //        [self.webView setHidden:YES];
        //        
        //        self.imageView.image = _image;
        //        CGRect frame = self.imageView.frame;
        //        CGSize size = self.image.size;
        //        frame.size = size;
        //        frame.origin.y = 0;
        //        frame.origin.x = 1024/2 - size.width/2;
        //        self.imageView.frame = frame;
        //        
        //        self.scrollView.contentSize = CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height);
        //        float y = self.imageView.frame.size.height/2 - 768/2;
        //        self.scrollView.contentOffset = CGPointMake(0, y);
        //        
        //        self.scrollView.maximumZoomScale = 1.5;
        //        self.scrollView.minimumZoomScale = 0.5;
        //        self.scrollView.delegate = self;
        
        [self.webView setHidden:YES];
        
        self.imageView.image = _image;
        
        CGSize size = _image.size;
        CGRect frame = self.imageView.frame;
        frame.size = size;
        // <
        if (size.height <= 748) {
            if (size.width <= 1024) {
                //            self.imageView.center = kScreenCenter;
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
	UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:finishedSavingWithError:contextInfo:), NULL);
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
	return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //	CGRect frame = _imageView.frame;
    //	frame.origin.y = 100;
    //	frame.origin.x = 1024/2 - frame.size.width/2;
    //	self.imageView.frame = frame;
    //	
    //	self.scrollView.contentSize = _imageView.frame.size;
    
    //	float y = self.imageView.frame.size.height/2 - 768/2;
    //	self.scrollView.contentOffset = CGPointMake(0, y);
    
    CGSize size = _imageView.frame.size;
    CGRect frame = self.imageView.frame;
    // <
    if (size.height <= 748) {
        if (size.width <= 1024) {
//            self.imageView.center = kScreenCenter;
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

#pragma - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityView stopAnimating];
}

@end
