    //
//  DetailImageViewController.m
//  PushBox
//
//  Created by Hasky on 11-2-27.
//  Copyright 2011 同济大学. All rights reserved.
//

#import "DetailImageViewController.h"
#import "UIApplicationAddition.h"


@implementation DetailImageViewController

@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize delegate = _delegate;
@synthesize image = _image;


- (id)initWithImage:(UIImage *)image
{
	self = [super init];
	if (self) {
		self.image = image;
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.imageView.image = _image;
	CGRect frame = self.imageView.frame;
	CGSize size = self.image.size;
	frame.size = size;
	frame.origin.y = 0;
	frame.origin.x = 1024/2 - size.width/2;
	self.imageView.frame = frame;


	self.scrollView.contentSize = CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height);
	float y = self.imageView.frame.size.height/2 - 768/2;
	self.scrollView.contentOffset = CGPointMake(0, y);
	
	self.scrollView.maximumZoomScale = 1.5;
	self.scrollView.minimumZoomScale = 0.5;
	self.scrollView.delegate = self;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
	tapGesture.numberOfTapsRequired = 1;
	tapGesture.numberOfTouchesRequired = 1;
	[self.imageView addGestureRecognizer:tapGesture];
	[tapGesture release];
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
}


- (void)dealloc {
	[_imageView release];
    [_scrollView release];
    _delegate = nil;
	[_image release];
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
	CGRect frame = _imageView.frame;
	frame.origin.y = 0;
	frame.origin.x = 1024/2 - frame.size.width/2;
	self.imageView.frame = frame;
	
	self.scrollView.contentSize = CGSizeMake(_imageView.frame.size.width,
										 _imageView.frame.size.height);
	float y = self.imageView.frame.size.height/2 - 768/2;
	self.scrollView.contentOffset = CGPointMake(0, y);
}


@end
