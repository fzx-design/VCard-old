//
//  UserCardNaviViewController.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-10-15.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "UserCardNaviViewController.h"

@implementation UserCardNaviViewController

static UserCardNaviViewController *sharedUserCardNaviViewController = nil;

@synthesize contentViewController;
@synthesize naviController;

+ (UserCardNaviViewController *)sharedUserCardNaviViewController
{
    @synchronized(self)
	{
        if (sharedUserCardNaviViewController == nil)
		{
            sharedUserCardNaviViewController = [[UserCardNaviViewController alloc] init];
        }
    }
	
    return sharedUserCardNaviViewController;
}

+ (void)sharedUserCardDismiss
{
	if (sharedUserCardNaviViewController) {
		[sharedUserCardNaviViewController dismissModalViewControllerAnimated:YES];
		[sharedUserCardNaviViewController release];
		sharedUserCardNaviViewController = nil;
	}
}

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

- (UserCardContentViewController*)contentViewController
{
	if (!contentViewController) {
		contentViewController = [[UserCardContentViewController alloc] init];
		contentViewController.parent = sharedUserCardNaviViewController;
	}
	return  contentViewController;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view addSubview:self.contentViewController.view];
	CGRect frame = CGRectMake(self.view.frame.origin.x + 49, self.view.frame.origin.y - 5, contentViewController.view.frame.size.width, contentViewController.view.frame.size.height);
	self.contentViewController.view.frame = frame;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	[contentViewController release];
	[naviController release];
	contentViewController = nil;
	naviController = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
