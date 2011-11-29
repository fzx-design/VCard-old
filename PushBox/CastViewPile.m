//
//  CastViewPile.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-25.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "CastViewPile.h"

@implementation CastViewPile

@synthesize type = _type;

@synthesize pileIndex = _pileIndex;

@synthesize startIndexInFR = _startIndexInFR;

@synthesize endIndexInFR = _endIndexInFR;

@synthesize isRead = _isRead;

@synthesize endDate = _endDate;

- (void)dealloc
{
	[super dealloc];
}

- (id)initWithStartIndexInFR:(int)start
{
	if (self = [super init]) {
		_endIndexInFR = start;
        _startIndexInFR = start;
	}
	return self;
}

- (int)numberOfCardsInPile
{
	return _endIndexInFR - _startIndexInFR + 1;
}

- (BOOL)containsIndexInFR:(int)index
{
    return _startIndexInFR <= index && _endIndexInFR >= index;
}

- (BOOL)isPileTail:(int)index
{
    return _endIndexInFR == index - 1 && _type != CastViewCellTypeCard;
}

- (void)resetPileIndexWithOffset:(int)offset
{
	_pileIndex += offset - 1;
}

- (void)enlargePileVolume
{
    _type = CastViewCellTypeMutipleCardPile;
	_endIndexInFR++;
}

- (BOOL)isMultipleCardPile
{
    return _type == CastViewCellTypeMutipleCardPile;
}

- (BOOL)isRead
{
    return _isRead;
}

- (void)resetAfterDeleting
{
    _startIndexInFR--;
    _endIndexInFR--;
}

@end
