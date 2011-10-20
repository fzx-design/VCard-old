//
//  IntervalManViewController.m
//  PushBox
//
//  Created by Hasky on 11-1-29.
//  Copyright 2011 同济大学. All rights reserved.
//

#import "IntervalManViewController.h"


@implementation IntervalManViewController

- (void)dealloc
{
    NSLog(@"IntervalManViewController dealloc");
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"SlidePlay 时间间隔", nil);
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 6;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	int defaultInterval = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeySiidePlayTimeInterval];
	int cellInterval = defaultInterval;
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
			cellInterval = 3;
            break;
        case 1:
			cellInterval = 5;
            break;
        case 2:
			cellInterval = 10;
            break;
        case 3:
			cellInterval = 15;
            break;
        case 4:
			cellInterval = 20;
            break;
        case 5:
			cellInterval = 30;
            break;
    }
	cell.accessoryType = UITableViewCellAccessoryNone;
	if (cellInterval == defaultInterval) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d 秒", nil), cellInterval];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int cellInterval = 3;
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
			cellInterval = 3;
            break;
        case 1:
			cellInterval = 5;
            break;
        case 2:
			cellInterval = 10;
            break;
        case 3:
			cellInterval = 15;
            break;
        case 4:
			cellInterval = 20;
            break;
        case 5:
			cellInterval = 30;
            break;
    }
	[[NSUserDefaults standardUserDefaults] setInteger:cellInterval forKey:kUserDefaultKeySiidePlayTimeInterval];
	[self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES]; 
}


@end

