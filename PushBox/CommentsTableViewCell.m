//
//  CommentsTableViewCell.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-31.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CommentsTableViewCell.h"

@implementation CommentsTableViewCell

@synthesize screenNameLabel = _screenNameLabel;
@synthesize textView = _textView;
@synthesize dateLabel = _dateLabel;
@synthesize delegate = _delegate;
@synthesize separatorLine = _separatorLine;

- (void)dealloc
{   
    [_screenNameLabel release];
    [_textView release];
    [_dateLabel release];
    [_separatorLine release];
    [super dealloc];
}

- (IBAction)commentButtonClicked:(id)sender {
    [_delegate commentsTableViewCellCommentButtonClicked:self];
}

@end
