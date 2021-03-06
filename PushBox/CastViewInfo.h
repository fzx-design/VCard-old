//
//  CastViewInfo.h
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-19.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CastViewDataSourceFriendsTimeline,
    CastViewDataSourceUserTimeline,
    CastViewDataSourceFavorites,
    CastViewDataSourceSearch,
    CastViewDataSourceTrends,
	CastViewDataSourceMentions,
} CastViewDataSource;

@interface CastViewInfo : NSObject

@property (nonatomic, retain) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, assign) int nextPage;
@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) int indexCount;
@property (nonatomic, assign) int indexSection;
@property (nonatomic, assign) int statusType;
@property (nonatomic, assign) long long statusID;
@property (nonatomic, assign) CastViewDataSource dataSource;

@end
