//
//  CardFrameViewController.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-14.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "CardFrameViewController.h"
#import "NSDateAddition.h"
#import "Status.h"

@implementation CardFrameViewController

@synthesize index = _index;
@synthesize contentViewController = _contentViewController;

@synthesize pileInfoView = _pileInfoView;
@synthesize dateRangeLabel = _dateRangeLabel;
@synthesize cardNumberLabel = _cardNumberLabel;
@synthesize pileCoverButton = _pileCoverButton;

@synthesize pileImageView = _pileImageView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.pileInfoView = nil;
}
#pragma mark - Set ContentViewController methods

- (IBAction)pileCoverButtonClicked:(id)sender
{
    self.pileInfoView.hidden = YES;
    self.pileCoverButton.hidden = YES;
    self.pileImageView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameExpandPile object:nil];
}

- (void)configureCardFrameWithStatus:(Status*)status
{
    if (status == nil || self.contentViewController == nil) {
        self.contentViewController.status = status;
    } else {
        long long aID = [self.contentViewController.status.statusID longLongValue];
        long long bID = [status.statusID longLongValue];
        if (aID != bID) {
            self.contentViewController.status = status;
        }
    }
    
    self.pileInfoView.hidden = YES;
    self.pileCoverButton.hidden = YES;
    self.pileImageView.hidden = YES;
}

- (void)configureCardFrameWithStatus:(Status*)status AndPile:(CastViewPile*)pile
{
    if (status == nil || self.contentViewController == nil) {
        self.contentViewController.status = status;
    } else {
        long long aID = [self.contentViewController.status.statusID longLongValue];
        long long bID = [status.statusID longLongValue];
        if (aID != bID) {
            self.contentViewController.status = status;
        }
    }
    
    BOOL result = [pile isMultipleCardPile];
    self.pileInfoView.hidden = !result;
    self.pileCoverButton.hidden = !result;
    self.pileImageView.hidden = !result;
    
    self.dateRangeLabel.text = [status.createdAt customString];
    self.cardNumberLabel.text = [NSString stringWithFormat:@"%d 张卡片", [pile numberOfCardsInPile]];
}


- (void)setContentViewController:(SmartCardViewController *)contentViewController
{
	if (_contentViewController != nil) {
		[_contentViewController release];
	}
	
	_contentViewController = [contentViewController retain];
	
	if (self.contentViewController.view.superview == nil) {
		[self.view insertSubview:self.contentViewController.view belowSubview:self.pileInfoView];
	}
}

@end
