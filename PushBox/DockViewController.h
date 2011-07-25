//
//  DockViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-25.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DockViewController : UIViewController {
    UIButton *_refreshButton;
    UIButton *_newTweetButton;
    UIButton *_playButton;
    UIButton *_commandCenterButton;
    UIButton *_showFavoritesButton;
    UIButton *_optionsButton;
    UISlider *_slider;
    UIView *_controlContainerView;
    UIImageView *_refreshNotiImageView;
    UIImageView *_commandCenterNotiImageView;

    UIPopoverController *_optionsPopoverController;
}

@property(nonatomic, retain) IBOutlet UIButton* refreshButton;
@property(nonatomic, retain) IBOutlet UIButton* newTweetButton;
@property(nonatomic, retain) IBOutlet UIButton* playButton;
@property(nonatomic, retain) IBOutlet UIButton* commandCenterButton;
@property(nonatomic, retain) IBOutlet UIButton* showFavoritesButton;
@property(nonatomic, retain) IBOutlet UIButton* optionsButton;
@property(nonatomic, retain) IBOutlet UISlider* slider;
@property(nonatomic, retain) IBOutlet UIView* controlContainerView;
@property(nonatomic, retain) IBOutlet UIImageView* refreshNotiImageView;
@property(nonatomic, retain) IBOutlet UIImageView* commandCenterNotiImageView;
@property(nonatomic, retain) UIPopoverController* optionsPopoverController;

- (void)showControlsAnimated:(BOOL)animated;
- (void)hideControlsAnimated:(BOOL)animated;

- (IBAction)optionsButtonClicked:(id)sender;

@end
