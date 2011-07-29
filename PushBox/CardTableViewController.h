//
//  CardTableViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-26.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "CardTableViewCell.h"

@class User;

@interface CardTableViewController : CoreDataTableViewController {

}

- (void)loadMoreData;
- (void)refresh;

@end
