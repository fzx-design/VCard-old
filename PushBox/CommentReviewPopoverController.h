//
//  CommentReviewPopoverController.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-26.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"
#import "DetailImageViewController.h"
#import "Status.h"

@interface CommentReviewPopoverController : CoreDataViewController<DetailImageViewControllerDelegate>
{
	UIImageView *_profileImageView;
	UILabel *_screenNameLabel;
	UILabel *_dateLabel;
	UIButton *_actionsButton;
	UIImageView *_tweetImageView;
	UILabel *_tweetTextLabel;

	UIView *_statusView;
	
	Status *_status;
}

@property(nonatomic, retain) IBOutlet UIImageView* profileImageView;
@property(nonatomic, retain) IBOutlet UILabel* screenNameLabel;
@property(nonatomic, retain) IBOutlet UILabel* dateLabel;
@property(nonatomic, retain) IBOutlet UIButton* actionsButton;
@property(nonatomic, retain) IBOutlet UIImageView* tweetImageView;
@property(nonatomic, retain) IBOutlet UILabel* tweetTextLabel;

@property(nonatomic, retain) IBOutlet UIView* statusView;

@property(nonatomic, retain) Status* status;

- (IBAction)dismissButtonClicked:(id)sender;
+(CommentReviewPopoverController*)sharedCommentReviewPopoverController;

@end
