//
//  RelationshipTableViewCell.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-31.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RelationshipTableViewCell : UITableViewCell {
    UIImageView *_profileImageView;
    UILabel *_screenNameLabel;
    UILabel *_descriptionLabel;
}

@property(nonatomic, retain) IBOutlet UIImageView* profileImageView;
@property(nonatomic, retain) IBOutlet UILabel* screenNameLabel;
@property(nonatomic, retain) IBOutlet UILabel* descriptionLabel;

@end
