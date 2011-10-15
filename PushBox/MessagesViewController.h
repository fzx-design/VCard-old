//
//  MessagesViewController.h
//  PushBox
//
//  Created by Ren Kelvin on 10/10/11.
//  Copyright 2011 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIApplicationAddition.h"

#import "User.h"
#import "MessagesContactsTableViewController.h"
#import "MessagesDialogTableViewController.h"
#import "MessageViewController.h"

@interface MessagesViewController : UIViewController

@property (nonatomic, retain) MessagesContactsTableViewController *contactsTableViewController;
@property (nonatomic, retain) MessagesDialogTableViewController *dialogTableViewController;

@property (nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *lastUpdateLabel;
@property (nonatomic, retain) IBOutlet UIImageView *errorImageView;

@property (nonatomic, retain) User *currentUser;

- (IBAction)newMessageButtonClicked:(id)sender;

@end
