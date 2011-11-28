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
            case PBBackgroundImageAmbers:
                imageName = NSLocalizedString(@"琥珀", nil);
                break;
            case PBBackgroundImageAurora:
                imageName = NSLocalizedString(@"极光", nil);
                break;
            case PBBackgroundImageChampagne:
                imageName = NSLocalizedString(@"香槟", nil);
                break;
            case PBBackgroundImageMist:
                imageName = NSLocalizedString(@"薄雾", nil);
                break;
            case PBBackgroundImageTwilight:
                imageName = NSLocalizedString(@"暮色", nil);
                break;
            case PBBackgroundImageKelp:
                imageName = NSLocalizedString(@"海藻", nil);
                break;
            case PBBackgroundImageWater:
                imageName = NSLocalizedString(@"水域", nil);
                break;
            case PBBackgroundImageBlossom:
                imageName = NSLocalizedString(@"桃花", nil);
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
		case PBBackgroundImageAmbers:
			imageName = @"bg_ambers";
			break;
		case PBBackgroundImageAurora:
			imageName = @"bg_aurora";
			break;
		case PBBackgroundImageChampagne:
			imageName = @"bg_champagne";
			break;
		case PBBackgroundImageMist:
			imageName = @"bg_mist";
			break;
		case PBBackgroundImageTwilight:
			imageName = @"bg_twilight";
			break;
        case PBBackgroundImageKelp:
			imageName = @"bg_kelp";
            break;
        case PBBackgroundImageWater:
			imageName = @"bg_water";
            break;
        case PBBackgroundImageBlossom:
			imageName = @"bg_flower";
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
		case PBBackgroundImageAmbers:
			imageName = @"bg_icon_ambers";
			break;
		case PBBackgroundImageAurora:
			imageName = @"bg_icon_aurora";
			break;
		case PBBackgroundImageChampagne:
			imageName = @"bg_icon_champagne";
			break;
		case PBBackgroundImageMist:
			imageName = @"bg_icon_mist";
			break;
		case PBBackgroundImageTwilight:
			imageName = @"bg_icon_twilight";
			break;
        case PBBackgroundImageKelp:
			imageName = @"bg_icon_kelp";
            break;
        case PBBackgroundImageWater:
			imageName = @"bg_icon_water";
            break;
        case PBBackgroundImageBlossom:
			imageName = @"bg_icon_flower";
            break;
	}
	return imageName;
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"色彩", nil);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 9;
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

