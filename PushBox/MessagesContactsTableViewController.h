//
//  MessagesContactsTableViewController.h
//  PushBox
//
//  Created by Ren Kelvin on 10/10/11.
//  Copyright 2011 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGOTableViewController.h"

@interface MessagesContactsTableViewController : EGOTableViewController

@property (nonatomic, retain) User *currentContact;
@property (nonatomic, retain) id delegate;

@end
