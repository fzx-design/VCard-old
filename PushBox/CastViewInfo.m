//
//  CastViewInfo.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-19.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "CastViewInfo.h"

@implementation CastViewInfo

@synthesize fetchedResultsController;
@synthesize nextPage;
@synthesize currentIndex;
@synthesize indexCount;
@synthesize indexSection;
@synthesize statusID;
@synthesize dataSource;

- (void)dealloc
{
	[fetchedResultsController release];
	[super dealloc];
}

@end
