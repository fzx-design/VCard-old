//
//  CastViewPileUpController.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-25.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CastViewPile.h"

@interface CastViewPileUpController : NSObject
{
	NSMutableSet *_newReadIDSet;
	NSMutableSet *_oldReadIDSet;
	NSMutableArray *_castViewPiles;
	
	int _currentViewIndex;
    int _lastIndexInFR;
}

@property (nonatomic, retain) NSMutableArray* castViewPiles;
@property (nonatomic, assign) int currentViewIndex;
@property (nonatomic, assign) int lastIndexFR;

+ (CastViewPileUpController*)sharedCastViewPileUpController;

- (CastViewPile*)pileAtIndex:(int)index;

- (void)addNewReadID:(long long)readStatusID;
- (void)insertCardwithID:(long long)statusID  andIndexInFR:(int)index;

- (int)indexInFRForViewIndex:(int)index;
- (int)itemCount;
- (void)print;

- (void)deletePileAtIndex:(int)index;
- (void)clearPiles;

@end
