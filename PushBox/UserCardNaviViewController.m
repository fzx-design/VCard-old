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
    if (sharedUserCardNaviViewController == nil) {
        sharedUserCardNaviViewController = [vc retain];
    }
}

+ (BOOL)sharedUserCardNaviViewControllerExisted
{
	BOOL result = NO;
	if (sharedUserCardNaviViewController != nil) {
		result = YES;
	}
	return result;
}

+ (void)sharedUserCardDismiss
{
	if (sharedUserCardNaviViewController != nil) {
		NSLog(@"Dismiss Start!!!!");
		[sharedUserCardNaviViewController dismissModalViewControllerAnimated:YES];
		NSLog(@"Dismiss End!!!!");
		[sharedUserCardNaviViewController release];
		sharedUserCardNaviViewController = nil;
	}
}

- (id)initWithRootViewController:(UIViewController*)vc
{
	self = [super init];
	if (self) {
		self.naviController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
		self.naviController.navigationBarHidden = YES;
		[self.naviController.view setFrame:[self.contentViewController.view bounds]];
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
		self.contentViewController = [[[UserCardContentViewController alloc] init] autorelease];
		CGRect frame = CGRectMake(self.view.frame.origin.x	+ 49, self.view.frame.origin.y + 5, contentViewController.view.frame.size.width, contentViewController.view.frame.size.height);
		self.contentViewController.view.frame = frame;
		[self.view addSubview:self.contentViewController.view];
	}
	return  contentViewController;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
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
