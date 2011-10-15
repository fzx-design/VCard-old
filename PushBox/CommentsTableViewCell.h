//
//  CommentsTableViewCell.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-31.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommentsTableViewCell;

@protocol CommentsTableViewCellDelegats

- (void)commentsTableViewCellCommentButtonClicked:(CommentsTableViewCell *)cell;

@end

@interface CommentsTableViewCell : UITableViewCell {
    UILabel *_screenNameLabel;
    UITextView *_textView;
    UILabel *_dateLabel;
    UIImageView *_separatorLine;
    id<CommentsTableViewCellDelegats> _delegate;
}

@property(nonatomic, retain) IBOutlet UILabel* screenNameLabel;
@property(nonatomic, retain) IBOutlet UITextView* textView;
@property(nonatomic, retain) IBOutlet UILabel* dateLabel;
@property(nonatomic, retain) IBOutlet UIImageView *separatorLine;
@property(nonatomic, assign) id delegate;

- (IBAction)commentButtonClicked:(id)sender;


@end
