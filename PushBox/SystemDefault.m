//
//  SystemDefault.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-30.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "SystemDefault.h"
#import "OptionsTableViewController.h"

@implementation SystemDefault

static SystemDefault* systemDefault = nil;

@synthesize pileUpEnabled = _pileUpEnabled;
@synthesize readTagEnabled = _readTagEnabled;

+ (SystemDefault*)systemDefault
{
    if (systemDefault == nil) {
        systemDefault = [[SystemDefault alloc] init];
    }
    return systemDefault;
}

- (id)init
{
    if (self = [super init]) {
        _pileUpEnabled = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyPileUpEnabled];
        _readTagEnabled = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyReadTagEnabled];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(resetPileUpEnabled) 
                       name:kNotificationNamePileUpEnabledChanged
                     object:nil];
    }
    return self;
}

- (void)resetPileUpEnabled
{
    _pileUpEnabled = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyPileUpEnabled];
    _readTagEnabled = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyReadTagEnabled];
}


@end
