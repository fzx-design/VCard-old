//
//  RelationshipTableViewController.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-30.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "EGOTableViewController.h"
#import "ErrorNotification.h"

typedef enum {
    RelationshipViewTypeFriends,
    RelationshipViewTypeFollowers,
} RelationshipViewType;

@class User;

@interface RelationshipTableViewController : EGOTableViewController {
    UILabel *_titleLabel;
    UIButton *_backButton;
    int _nextCursor;
    
    User *_user;
    RelationshipViewType _type;
}

@property(nonatomic, retain) IBOutlet UILabel* titleLabel;
@property(nonatomic, retain) IBOutlet UIButton* backButton;
@property(nonatomic, retain) User* user;

- (id)initWithType:(RelationshipViewType)type;
- (IBAction)backButtonClicked:(id)sender;

@end
