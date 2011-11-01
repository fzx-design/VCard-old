//
//  PostViewAtTableViewCell.h
//  PushBox
//
//  Created by Kelvin Ren on 10/31/11.
//  Copyright (c) 2011 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostViewAtTableViewCell : UITableViewCell {
    UILabel* _screenNameLabel;
}

@property (nonatomic, retain) IBOutlet UILabel* screenNameLabel;

@end
