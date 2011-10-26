//
//  OptionsTableViewController.m
//  PushBox
//
//  Created by Hasky on 11-1-29.
//  Copyright 2011 同济大学. All rights reserved.
//

#import "OptionsTableViewController.h"
#import "WeiboClient.h"

@implementation OptionsTableViewController

#pragma mark -
#pragma mark View lifecycle

#define kContentSizeForViewInPopover CGSizeMake(320.0f, 500.0f)

- (void)dealloc
{
    NSLog(@"OptionsTableViewController dealloc");
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"关于", nil)
//																			 style:UIBarButtonItemStylePlain
//																			target:self
//																			action:@selector(showAbout)];
	
    self.title = NSLocalizedString(@"VCard HD", nil);
    self.contentSizeForViewInPopover = kContentSizeForViewInPopover;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.tableView reloadData];
}

- (void)showAbout
{
	AboutViewController *aboutVC = [[AboutViewController alloc] init];
	[self.navigationController pushViewController:aboutVC animated:YES];
    aboutVC.contentSizeForViewInPopover = kContentSizeForViewInPopover;
	[aboutVC release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 1;
        case 2:
            return 4;
		case 3:
			return 1;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header = nil;
    switch (section) {
        case 0:
            header = NSLocalizedString(@"账户", nil);
            break;
        case 1:
            header = NSLocalizedString(@"外观", nil);
            break;
        case 2:
            header = NSLocalizedString(@"设置", nil);
            break;
		case 3:
			header = NSLocalizedString(@"",nil);
    }
    return header;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	
    switch (indexPath.section) {
        case 0:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"新浪微博", nil);
                    cell.detailTextLabel.text = NSLocalizedString(@"注销", nil);
                    cell.imageView.image = [UIImage imageNamed:@"flag_sina.png"];
                    break;
            }
            break;
        case 1:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"色彩", nil);
			int enumValue = [[userDefault objectForKey:kUserDefaultKeyBackground] intValue];
			NSString *desc = [BackgroundManViewController backgroundDescriptionFromEnum:enumValue];
            cell.detailTextLabel.text = desc;
			NSString *path = [BackgroundManViewController backgroundIconFilePathFromEnum:enumValue];
            cell.imageView.image = [UIImage imageNamed:path];
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                        //cell.selectionStyle = UITableViewCellSelectionStyleGray; //to consider
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.text = NSLocalizedString(@"SlidePlay 时间间隔", nil);
					int interval = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeySiidePlayTimeInterval];
                    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d 秒", nil), interval]; 
                    cell.imageView.image = [UIImage imageNamed:@"options_icon_time.png"];
                    break;
					
				case 1:
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.text = NSLocalizedString(@"消息更新速度", nil);
					int refreshInterval = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyRefreshingInterval];
					if (refreshInterval == 10) {
						cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"立即", nil), interval];
					} else if(refreshInterval == 30) {
						cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"每30秒", nil), interval];
					} else if(refreshInterval == 60) {
						cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"每分钟", nil), interval];
					} else {
						cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%手动", nil), interval];
					}
                    
                    cell.imageView.image = [UIImage imageNamed:@"options_icon_time.png"];
                    break;
					
                case 2:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
					
					UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 94, 27)];
					aSwitch.on = [userDefault boolForKey:kUserDefaultKeyImageDownloadingEnabled];
					[aSwitch addTarget:self
								action:@selector(loadImageOn:)
					  forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = aSwitch;
					[aSwitch release];
					
                    cell.textLabel.text = NSLocalizedString(@"加载微博图片", nil);
                    cell.imageView.image = [UIImage imageNamed:@"options_icon_image.png"];
                    break;
                case 3:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
					
					UISwitch *aSwitch2 = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 94, 27)];
					aSwitch2.on = [userDefault boolForKey:kUserDefaultKeySoundEnabled];
					[aSwitch2 addTarget:self 
                                 action:@selector(soundOn:)
                       forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = aSwitch2;
					[aSwitch2 release];
					
					cell.textLabel.text = NSLocalizedString(@"音效", nil);
                    cell.imageView.image = [UIImage imageNamed:@"options_icon_sound.png"];
                    break;
					
            }
            break;
		case 3:
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"关于", nil);
			cell.imageView.image = [UIImage imageNamed:@"options_icon_about.png"];
//			int enumValue = [[userDefault objectForKey:kUserDefaultKeyBackground] intValue];
//			NSString *desc = [BackgroundManViewController backgroundDescriptionFromEnum:enumValue];
//            cell.detailTextLabel.text = desc;
//			NSString *path = [BackgroundManViewController backgroundIconFilePathFromEnum:enumValue];
//            cell.imageView.image = [UIImage imageNamed:path];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)loadImageOn:(UISwitch *)sender
{
	BOOL on = sender.on;
	[[NSUserDefaults standardUserDefaults] setBool:on forKey:kUserDefaultKeyImageDownloadingEnabled];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)soundOn:(UISwitch *)sender
{
	BOOL on = sender.on;
	[[NSUserDefaults standardUserDefaults] setBool:on forKey:kUserDefaultKeySoundEnabled];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIAlertView *alert;
    switch (indexPath.section) {
        case 0:
			if (indexPath.row == 0) {
				alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"注销帐号将抹掉当前登录信息", nil)
												   message:nil
												  delegate:self
										 cancelButtonTitle:NSLocalizedString(@"取消", nil)
										 otherButtonTitles:NSLocalizedString(@"继续", nil), nil];
				[alert show];
				[alert release];
				break;
			}
			break;
        case 1:
        {
            BackgroundManViewController *bvc = [[BackgroundManViewController alloc] initWithStyle:UITableViewStyleGrouped];
            bvc.contentSizeForViewInPopover = kContentSizeForViewInPopover;
            [self.navigationController pushViewController:bvc animated:YES];
            [bvc release];
            break;
        }
        case 2:
            if (indexPath.row == 0) {
                IntervalManViewController *ivc = [[IntervalManViewController alloc] initWithStyle:UITableViewStyleGrouped];
                ivc.contentSizeForViewInPopover = kContentSizeForViewInPopover;
                [self.navigationController pushViewController:ivc animated:YES];
                [ivc release];
            } else if(indexPath.row == 1) {
				RefreshingIntervalViewController *ivc = [[RefreshingIntervalViewController alloc] initWithStyle:UITableViewStyleGrouped];
                ivc.contentSizeForViewInPopover = kContentSizeForViewInPopover;
                [self.navigationController pushViewController:ivc animated:YES];
                [ivc release];
			}
            break;
		case 3:
			[self showAbout];
		}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != alertView.cancelButtonIndex) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameUserSignedOut
															object:nil];
        [WeiboClient signout];
	}
}

@end

