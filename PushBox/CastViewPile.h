//
//  CastViewPile.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-25.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	CastViewCellTypeCard,
	CastViewCellTypeSingleCardPile,
    CastViewCellTypeMutipleCardPile,
} CastViewCellType;

@interface CastViewPile : NSObject
{
    CastViewCellType _type;
    
	int _pileIndex;
	
	int _startIndexInFR;
	int _endIndexInFR;
    BOOL _isRead;
}

@property (nonatomic, assign) CastViewCellType type;

@property (nonatomic, assign) int pileIndex;

@property (nonatomic, assign) int startIndexInFR;
@property (nonatomic, assign) int endIndexInFR;

@property (nonatomic, assign) BOOL isRead;

- (id)initWithStartIndexInFR:(int)start;

- (int)numberOfCardsInPile;
- (BOOL)containsIndexInFR:(int)index;
- (BOOL)isPileTail:(int)index;
- (void)resetPileIndexWithOffset:(int)offset;
- (void)enlargePileVolume;
- (void)resetAfterDeleting;

- (BOOL)isMultipleCardPile;
- (BOOL)isRead;

@end
