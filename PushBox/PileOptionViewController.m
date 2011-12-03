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
    self.title = NSLocalizedString(@"卡片堆叠", nil);
    _pileEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultKeyPileUpEnabled];
    _action = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_pileEnabled) {
        return 2;
    } else {
        return 1;
    }
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
               forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = aSwitch1;
            [aSwitch1 release];
            
            cell.textLabel.text = NSLocalizedString(@"启用卡片堆叠", nil);
            break;
            
        case 1:
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UISwitch *aSwitch2 = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 94, 27)];
            aSwitch2.on = [userDefault boolForKey:kUserDefaultKeyReadTagEnabled];
            [aSwitch2 addTarget:self 
                         action:@selector(readTagOn:)
               forControlEvents:UIControlEventValueChanged];
            
            aSwitch2.userInteractionEnabled = [userDefault boolForKey:kUserDefaultKeyPileUpEnabled];
            
            cell.accessoryView = aSwitch2;
            [aSwitch2 release];
            
            
            cell.textLabel.text = NSLocalizedString(@"显示\"已读\"标记", nil);
            
            break;
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    
    if (section == 0) {
        return @"每次刷新后 VCard 会自动将您读过的卡片        整理成一个\"堆叠\"。";
    }
    return nil;
}

- (void)delay
{
    _action = NO;
}

- (void)setSection
{
//    if (_preEnabled == _pileEnabled) {
//        return;
//    }
    if (_pileEnabled) {
        NSIndexSet* set = [NSIndexSet indexSetWithIndex: 1];
        [self.tableView beginUpdates];
        if ([self.tableView numberOfSections] == 2) {
            return;
        }
        [self.tableView insertSections:set withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    } else {
        NSIndexSet* set = [NSIndexSet indexSetWithIndex: 1];
        [self.tableView beginUpdates];
        if ([self.tableView numberOfSections] == 1) {
            return;
        }
        [self.tableView deleteSections:set withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    _action = NO;
//    [self performSelector:@selector(delay) withObject:nil afterDelay:0.5];
}

- (void)pileUpOn:(UISwitch *)sender
{    
//    _action = YES;
    
	BOOL on = sender.on;
    _pileEnabled = on;
	[[NSUserDefaults standardUserDefaults] setBool:on forKey:kUserDefaultKeyPileUpEnabled];
	[[NSUserDefaults standardUserDefaults] synchronize];

    if (_pileEnabled) {
        NSIndexSet* set = [NSIndexSet indexSetWithIndex: 1];        
        if ([self.tableView numberOfSections] == 2) {
            return;
        }
        [self.tableView beginUpdates];
        [self.tableView insertSections:set withRowAnimation:UITableViewRowAnimationFade];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNamePileUpEnabledChanged object:nil];
        [self.tableView endUpdates];
    } else {
        NSIndexSet* set = [NSIndexSet indexSetWithIndex: 1];
        if ([self.tableView numberOfSections] == 1) {
            return;
        }
        [self.tableView beginUpdates];
        [self.tableView deleteSections:set withRowAnimation:UITableViewRowAnimationFade];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNamePileUpEnabledChanged object:nil];
        [self.tableView endUpdates];
    }
    
//    if (_action) {
//        return;
//    }
//    _action = YES;
//    _preEnabled = !_pileEnabled;
//    [self performSelector:@selector(setSection) withObject:nil afterDelay:0.5];
}

- (void)readTagOn:(UISwitch *)sender
{
	BOOL on = sender.on;
	[[NSUserDefaults standardUserDefaults] setBool:on forKey:kUserDefaultKeyReadTagEnabled];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameReadTagEnabledChanged object:nil];
}

@end
