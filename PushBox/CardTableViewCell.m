//
//  CardTableViewCell.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-26.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CardTableViewCell.h"

@implementation CardTableViewCell

@synthesize statusCardViewController = _statusCardViewController;
@synthesize smartCardViewController = _smartCardViewController;

- (void)dealloc
{
    NSLog(@"CardTableViewCell dealloc");
    [_statusCardViewController release];
    [_smartCardViewController release];
    [super dealloc];
}

- (void)awakeFromNib
{
    NSLog(@"CardTableViewCell awakeFromNib");
    self.transform = CGAffineTransformRotate(self.transform, M_PI_2);
    
    if(NO)
    {if (!_statusCardViewController) {
        _statusCardViewController = [[StatusCardViewController alloc] init];
    }
        
        [self.contentView addSubview:_statusCardViewController.view];
    }
    else
    {
        if (!_smartCardViewController) {
            _smartCardViewController = [[SmartCardViewController alloc] init];
        }
        
        [self.contentView addSubview:_smartCardViewController.view];
    }
}


@end
