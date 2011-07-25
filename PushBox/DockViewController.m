//
//  DockViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-25.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "DockViewController.h"


@implementation DockViewController

@synthesize refreshButton = _refreshButton;
@synthesize newTweetButton = _newTweetButton;
@synthesize playButton = _playButton;
@synthesize commandCenterButton = _commandCenterButton;
@synthesize showFavoritesButton = _showFavoritesButton;
@synthesize optionsButton = _optionsButton;
@synthesize slider = _slider;
@synthesize refreshNotiImageView = _refreshNotiImageView;
@synthesize commandCenterNotiImageView = _commandCenterNotiImageView;
@synthesize optionsPopoverController = _optionsPopoverController;
@synthesize controlContainerView = _controlContainerView;

#pragma mark - View lifecycle

- (void)dealloc
{
    [_refreshButton release];
    [_newTweetButton release];
    [_playButton release];
    [_commandCenterButton release];
    [_showFavoritesButton release];
    [_optionsButton release];
    [_slider release];
    [_controlContainerView release];
    [_refreshNotiImageView release];
    [_commandCenterNotiImageView release];
    [_optionsPopoverController release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.slider setThumbImage:[UIImage imageNamed:@"dock_slider_thumb.png"] forState:UIControlStateNormal];
	[self.slider setThumbImage:[UIImage imageNamed:@"dock_slider_thumb_HL.png"] forState:UIControlStateHighlighted];
	[self.slider setMinimumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
	[self.slider setMaximumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.refreshButton = nil;
    self.newTweetButton = nil;
    self.playButton = nil;
    self.commandCenterButton = nil;
    self.showFavoritesButton = nil;
    self.optionsButton = nil;
    self.slider = nil;
    self.refreshNotiImageView = nil;
    self.commandCenterNotiImageView = nil;
    self.controlContainerView = nil;
}

- (void)showControlsAnimated:(BOOL)animated;
{
    [UIView animateWithDuration:animated animations:^{
        self.controlContainerView.alpha = 1.0;
    }];
}

- (void)hideControlsAnimated:(BOOL)animated;
{
    [UIView animateWithDuration:animated animations:^{
        self.controlContainerView.alpha = 0.0;
    }];
}

- (IBAction)optionsButtonClicked:(id)sender {
    OptionsTableViewController *otvc = [[OptionsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:otvc];
    
    _optionsPopoverController = [[UIPopoverController alloc] initWithContentViewController:nc];
    self.optionsPopoverController.delegate = self;
    
	CGRect rect = self.optionsButton.bounds;
	rect.origin.x += 7;
	rect.origin.y += 10;
	rect.size.width -= 30;
	rect.size.height -= 30;
    [self.optionsPopoverController presentPopoverFromRect:rect
                                                   inView:self.optionsButton
                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                 animated:YES];
    [otvc release];
    [nc release];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.optionsPopoverController = nil;
}


@end
