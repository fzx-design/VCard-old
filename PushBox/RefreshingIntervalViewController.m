//
//  RefreshingIntervalViewController.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-27.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "RefreshingIntervalViewController.h"

@implementation RefreshingIntervalViewController

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
    return 4;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	int defaultInterval = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyRefreshingInterval];
	int cellInterval = defaultInterval;
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
			cellInterval = 10;
			cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"立即", nil)];
            break;
        case 1:
			cellInterval = 30;
			cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"每30秒", nil)];
            break;
        case 2:
			cellInterval = 60;
			cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"每分钟", nil)];
            break;
        case 3:
			cellInterval = 65535;
			cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"手动", nil)];
            break;
    }
	cell.accessoryType = UITableViewCellAccessoryNone;
	if (cellInterval == defaultInterval) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int cellInterval = 3;
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
			cellInterval = 10;
            break;
        case 1:
			cellInterval = 30;
            break;
        case 2:
			cellInterval = 60;
            break;
        case 3:
			cellInterval = 65535;
            break;
    }
	[[NSUserDefaults standardUserDefaults] setInteger:cellInterval forKey:kUserDefaultKeyRefreshingInterval];
	[self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES]; 
}


@end
