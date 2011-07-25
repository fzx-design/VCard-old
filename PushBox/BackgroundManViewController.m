//
//  BackgroundManViewController.m
//  PushBox
//
//  Created by Hasky on 11-1-29.
//  Copyright 2011 同济大学. All rights reserved.
//

#import "BackgroundManViewController.h"


@implementation BackgroundManViewController

- (void)dealloc
{
    NSLog(@"BackgroundManViewController dealloc");
    [super dealloc];
}

+ (NSString *)backgroundDescriptionFromEnum:(int)enumValue
{
    {
        NSString *imageName = nil;
        switch (enumValue) {
            case PBBackgroundImageDefault:
                imageName = NSLocalizedString(@"默认", nil);
                break;
            case PBBackgroundImageDream:
                imageName = NSLocalizedString(@"梦幻", nil);
                break;
            case PBBackgroundImageLake:
                imageName = NSLocalizedString(@"湖面", nil);
                break;
            case PBBackgroundImageMask:
                imageName = NSLocalizedString(@"蓝色马赛克", nil);
                break;
            case PBBackgroundImagePencils:
                imageName = NSLocalizedString(@"彩色铅笔", nil);
                break;
            case PBBackgroundImageWooden:
                imageName = NSLocalizedString(@"木制桌面", nil);
                break;
        }
        return imageName;
    }
}

+ (NSString *)backgroundImageFilePathFromEnum:(int)enumValue
{
    
    NSString *imageName = nil;
	switch (enumValue) {
		case PBBackgroundImageDefault:
			imageName = @"bg_default";
			break;
		case PBBackgroundImageDream:
			imageName = @"bg_dream";
			break;
		case PBBackgroundImageLake:
			imageName = @"bg_lake";
			break;
		case PBBackgroundImageMask:
			imageName = @"bg_mask";
			break;
		case PBBackgroundImagePencils:
			imageName = @"bg_pencils";
			break;
		case PBBackgroundImageWooden:
			imageName = @"bg_wooden";
			break;
	}
	return imageName;
}

+ (NSString *)backgroundIconFilePathFromEnum:(int)enumValue
{
    NSString *imageName = nil;
	switch (enumValue) {
		case PBBackgroundImageDefault:
			imageName = @"bg_icon_default";
			break;
		case PBBackgroundImageDream:
			imageName = @"bg_icon_dream";
			break;
		case PBBackgroundImageLake:
			imageName = @"bg_icon_lake";
			break;
		case PBBackgroundImageMask:
			imageName = @"bg_icon_mask";
			break;
		case PBBackgroundImagePencils:
			imageName = @"bg_icon_pencils";
			break;
		case PBBackgroundImageWooden:
			imageName = @"bg_icon_desk";
			break;
	}
	return imageName;
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"背景", nil);
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	int enumValue = [[userDefault objectForKey:kUserDefaultKeyBackground] intValue];
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	if (enumValue == indexPath.row) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
    
	NSString *imagePath = [BackgroundManViewController backgroundIconFilePathFromEnum:indexPath.row];
    cell.textLabel.text = [BackgroundManViewController backgroundDescriptionFromEnum:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:imagePath];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:kUserDefaultKeyBackground];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameBackgroundChanged object:self];
	[self.tableView reloadData];
}

@end

