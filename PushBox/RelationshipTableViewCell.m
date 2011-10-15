//
//  RelationshipTableViewCell.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-31.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "RelationshipTableViewCell.h"

@implementation RelationshipTableViewCell

@synthesize profileImageView = _profileImageView;
@synthesize screenNameLabel = _screenNameLabel;
@synthesize descriptionLabel = _descriptionLabel;

- (void)dealloc
{
    [super dealloc];
    [_profileImageView release];
    [_screenNameLabel release];
    [_descriptionLabel release];
}

@end
