//
//  SliderTrackPopoverView.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-21.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "SliderTrackPopoverView.h"

@implementation SliderTrackPopoverView

@synthesize proFileImage;
@synthesize screenNameLabel;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    screenNameLabel.backgroundColor = [UIColor clearColor];
    screenNameLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    screenNameLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    screenNameLabel.shadowBlur = 10.0f;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
