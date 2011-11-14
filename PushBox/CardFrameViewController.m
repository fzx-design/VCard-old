//
//  CardFrameViewController.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-14.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "CardFrameViewController.h"

@implementation CardFrameViewController

@synthesize index = _index;
@synthesize contentViewController = _contentViewController;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Set ContentViewController methods
- (void)setContentViewController:(SmartCardViewController *)contentViewController
{
	_contentViewController = contentViewController;
	[self.view addSubview:self.contentViewController.view];
}

@end
