//
//  CardFrameViewController.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-14.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "CardFrameViewController.h"
#import "NSDateAddition.h"
#import "AnimationProvider.h"
#import "Status.h"
#import "SystemDefault.h"


@implementation CardFrameViewController

@synthesize index = _index;
@synthesize contentViewController = _contentViewController;

@synthesize pileInfoView = _pileInfoView;
@synthesize dateRangeLabel = _dateRangeLabel;
@synthesize cardNumberLabel = _cardNumberLabel;
@synthesize pileCoverButton = _pileCoverButton;

@synthesize pileBounderShadow = _pileBounderShadow;

@synthesize pileImageView = _pileImageView;


#pragma mark - Tools

- (BOOL)readTagEnabled
{
    return [[SystemDefault systemDefault] readTagEnabled] && [[SystemDefault systemDefault] pileUpEnabled];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.pileBounderShadow = nil;
	self.pileInfoView = nil;
}
#pragma mark - Set ContentViewController methods

- (IBAction)pileCoverButtonClicked:(id)sender
{
    [self.pileInfoView.layer addAnimation:[AnimationProvider flyAnimation] forKey:@"animation"];
        
    self.pileInfoView.hidden = YES;
    self.pileCoverButton.hidden = YES;
    self.pileImageView.hidden = YES;
    [UIView animateWithDuration:0.7 animations:^{
        self.pileBounderShadow.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.pileBounderShadow.hidden = YES;
        self.pileBounderShadow.alpha = 1.0;
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameExpandPile object:nil];
}

- (BOOL)configureCardFrameWithStatus:(Status*)status
{
    if (status == nil) {
        return NO;
    }
    if (self.contentViewController == nil) {
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
    self.pileBounderShadow.hidden = YES;
    self.contentViewController.readImageView.hidden = YES;
    
    return YES;
}

- (BOOL)configureCardFrameWithStatus:(Status*)status AndPile:(CastViewPile*)pile withEndDateString:(NSDate*)endDate
{
    if (status == nil) {
        return NO;
    }

    if (self.contentViewController.view.superview == nil) {
		[self.view insertSubview:self.contentViewController.view belowSubview:self.pileBounderShadow];
	}
    
    long long aID = [self.contentViewController.status.statusID longLongValue];
    long long bID = [status.statusID longLongValue];
    if (aID != bID) {
        self.contentViewController.status = status;
    }
//    }
    
    BOOL result = [pile isMultipleCardPile];
    self.pileInfoView.hidden = !result;
    self.pileCoverButton.hidden = !result;
    self.pileImageView.hidden = !result;
    self.pileBounderShadow.hidden = !result;
    
    if ([self readTagEnabled]) {
        self.contentViewController.readImageView.hidden = ![pile isRead];
    } else {
        self.contentViewController.readImageView.hidden = YES;
    }
    
    NSString *string = @"从 ";
    
#warning this may crash
    self.dateRangeLabel.text = [string stringByAppendingString:[endDate customString]];
    
    self.cardNumberLabel.text = [NSString stringWithFormat:@"%d 张卡片", [pile numberOfCardsInPile]];
    return YES;
}

- (void)setContentViewController:(SmartCardViewController *)content
{
	if (_contentViewController != nil) {
		[_contentViewController release];
	}
    
	_contentViewController = [content retain];
	
	if (self.contentViewController.view.superview == nil) {
		[self.view insertSubview:self.contentViewController.view belowSubview:self.pileBounderShadow];
	}
}

@end
