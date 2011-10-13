//
//  MessagesViewController.m
//  PushBox
//
//  Created by Ren Kelvin on 10/10/11.
//  Copyright 2011 同济大学. All rights reserved.
//

#import "MessagesViewController.h"

@implementation MessagesViewController

@synthesize contactsTableViewController;
@synthesize dialogTableViewController;

@synthesize profileImageView;
@synthesize titleLabel;
@synthesize lastUpdateLabel;
@synthesize errorImageView;

@synthesize currentUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view insertSubview:self.contactsTableViewController.view belowSubview:self.errorImageView];
    [self.view insertSubview:self.dialogTableViewController.view belowSubview:self.errorImageView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (MessagesContactsTableViewController*)contactsTableViewController
{
    if (!contactsTableViewController) {
        contactsTableViewController = [[MessagesContactsTableViewController alloc] init];
        dialogTableViewController = [[MessagesDialogTableViewController alloc] init];
        
        // something
        contactsTableViewController.view.frame = CGRectMake(33, 7, 293, 554);
        dialogTableViewController.view.frame = CGRectMake(326, 86, 603, 475);
    }
    return contactsTableViewController;
}

- (IBAction)newMessageButtonClicked:(id)sender
{
    MessageViewController *vc = [[MessageViewController alloc] init];

    [[UIApplication sharedApplication] presentModalViewController:vc atHeight:36];
    [vc release];
}

@end
