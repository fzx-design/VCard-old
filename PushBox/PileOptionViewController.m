//
//  PileOptionViewController.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-30.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "PileOptionViewController.h"


@implementation PileOptionViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"堆叠", nil);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    switch (indexPath.section) {
        case 0:
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UISwitch *aSwitch1 = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 94, 27)];
            aSwitch1.on = [userDefault boolForKey:kUserDefaultKeyPileUpEnabled];
            [aSwitch1 addTarget:self 
                         action:@selector(pileUpOn:)
               forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = aSwitch1;
            [aSwitch1 release];
            
            cell.textLabel.text = NSLocalizedString(@"堆叠", nil);
            break;
            
        case 1:
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UISwitch *aSwitch2 = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 94, 27)];
            aSwitch2.on = [userDefault boolForKey:kUserDefaultKeyReadTagEnabled];
            [aSwitch2 addTarget:self 
                         action:@selector(readTagOn:)
               forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = aSwitch2;
            [aSwitch2 release];
            
            cell.textLabel.text = NSLocalizedString(@"显示已读标志", nil);
            
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)pileUpOn:(UISwitch *)sender
{
	BOOL on = sender.on;
	[[NSUserDefaults standardUserDefaults] setBool:on forKey:kUserDefaultKeyPileUpEnabled];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)readTagOn:(UISwitch *)sender
{
	BOOL on = sender.on;
	[[NSUserDefaults standardUserDefaults] setBool:on forKey:kUserDefaultKeyReadTagEnabled];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
