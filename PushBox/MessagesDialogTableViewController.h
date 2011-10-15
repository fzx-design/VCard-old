//
//  MessagesDialogTableViewController.h
//  PushBox
//
//  Created by Ren Kelvin on 10/11/11.
//  Copyright 2011 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGOTableViewController.h"

#import "User.h"
#import "Message.h"
#import "MessagesDialogTableViewCell.h"

@interface MessagesDialogTableViewController : EGOTableViewController

@property (nonatomic, retain) User *currentContact;
@property (nonatomic, retain) id delegate;

@end
