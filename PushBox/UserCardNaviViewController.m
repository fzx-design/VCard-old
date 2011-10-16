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

+ (void)setSharedUserCardNaviViewController:(UserCardNaviViewController*)vc
{
    sharedUserCardNaviViewController = [vc retain];
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

- (id)initWithRootViewController:(UIViewController*)vc
{
	self = [super init];
	if (self) {
		self.naviController = [[UINavigationController alloc] initWithRootViewController:vc];
		self.naviController.navigationBarHidden = YES;
		[self.contentViewController.view addSubview:self.naviController.view];
	}
	
	return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
	contentViewController = nil;
	naviController = nil;
}

- (void)dealloc
{
	[contentViewController release];
	[naviController release];
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
