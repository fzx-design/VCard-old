//
//  DetailImageViewController.h
//  PushBox
//
//  Created by Hasky on 11-2-27.
//  Copyright 2011 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DetailImageViewControllerDelegate
- (void)detailImageViewControllerShouldDismiss:(UIViewController *)vc;
@end


@interface DetailImageViewController : UIViewController <UIScrollViewDelegate> {
	UIImageView *_imageView;
	UIScrollView *_scrollView;
	
	id _delegate;
	UIImage *_image;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) IBOutlet id <DetailImageViewControllerDelegate> delegate;
@property (nonatomic, retain) UIImage *image;

- (id)initWithImage:(UIImage *)image;
- (IBAction)saveImage:(UIButton *)sender;
- (IBAction)dismiss:(UIButton *)sender;

@end
