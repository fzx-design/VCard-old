//
//  MessagesDialogTableViewController.m
//  PushBox
//
//  Created by Ren Kelvin on 10/11/11.
//  Copyright 2011 同济大学. All rights reserved.
//

#import "MessagesDialogTableViewController.h"

#define DIALOG_FROM_DEFALUT_FRAME CGRectMake(0, 33, 385, 64)
#define DIALOG_TO_DEFALUT_FRAME CGRectMake(219, 33, 384, 64)
#define DEFAULT_TEST_TEXT @"您好，只要促进环保就应支持，同济大学苹果俱乐部您好，只要促进环保就应支持，同济大学苹果俱乐部您好，只要促进环保就应支持，同济大学苹果俱乐部"

@implementation MessagesDialogTableViewController

@synthesize currentContact;
@synthesize delegate;

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)configureRequest:(NSFetchRequest *)request
{
    request.entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MessagesDialogTableViewCell *dialogCell = (MessagesDialogTableViewCell *)cell;
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (NO) {
        dialogCell.fromTextView.text = DEFAULT_TEST_TEXT;
        
        dialogCell.toTextView.hidden = YES;
        dialogCell.toTopImageView.hidden = YES;
        dialogCell.toCenterImageView.hidden = YES;
        dialogCell.toButtomImageView.hidden = YES;
        
        UITextView *textView = dialogCell.fromTextView;
        
        // textView
        CGRect frame = textView.frame;
        frame.size = textView.contentSize;
        textView.frame = frame;
       
        // image
        frame = dialogCell.fromCenterImageView.frame;
        frame.size.height = textView.frame.size.height - 28;
        dialogCell.fromCenterImageView.frame = frame;
        
        frame = dialogCell.fromButtomImageView.frame;
        frame.origin.y = dialogCell.fromCenterImageView.frame.origin.y + dialogCell.fromCenterImageView.frame.size.height;
        dialogCell.fromButtomImageView.frame = frame;
        
        // cell
        CGFloat height = dialogCell.fromButtomImageView.frame.origin.y + dialogCell.fromButtomImageView.frame.size.height;
        dialogCell.frame = CGRectMake(0, 0, 603, height);
    }
    else {
        dialogCell.toTextView.text = DEFAULT_TEST_TEXT;
        
        dialogCell.fromTextView.hidden = YES;
        dialogCell.fromTopImageView.hidden = YES;
        dialogCell.fromCenterImageView.hidden = YES;
        dialogCell.fromButtomImageView.hidden = YES;
        
        UITextView *textView = dialogCell.toTextView;
        
        // textView
        CGRect frame = textView.frame;
        frame.size = textView.contentSize;
        textView.frame = frame;
        
        // image
        frame = dialogCell.toCenterImageView.frame;
        frame.size.height = textView.frame.size.height - 28;
        dialogCell.toCenterImageView.frame = frame;
        
        frame = dialogCell.toButtomImageView.frame;
        frame.origin.y = dialogCell.toCenterImageView.frame.origin.y + dialogCell.toCenterImageView.frame.size.height;
        dialogCell.toButtomImageView.frame = frame;
        
        // cell
        CGFloat height = dialogCell.toButtomImageView.frame.origin.y + dialogCell.toButtomImageView.frame.size.height;
        dialogCell.frame = CGRectMake(0, 0, 603, height);
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = CGRectMake(0, 0, 603, 10);
    UITextView *textView = [[UITextView alloc] initWithFrame:frame];
    textView.text = DEFAULT_TEST_TEXT;
    frame.size = textView.contentSize;

    [textView release];
    
    return frame.size.height + 83;
}

- (NSString *)customCellClassName
{
    return @"MessagesDialogTableViewCell";
}

@end
