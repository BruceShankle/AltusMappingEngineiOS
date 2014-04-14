//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"

@interface MERefreshMapTileProvider : METileProvider
@property (assign) int currentTile;
@property (retain) NSString* imageName;
- (void) nextTile;
@end

@interface MERefreshMapRegionTest : METest
@property (retain) MERefreshMapTileProvider* tileProvider;
@property (retain) UIButton* btnRefreshMap;
@property (retain) UIButton* btnRefreshRegion;
-(void) showTestRegions;
@end


@interface MERefreshMapStressTileProvider : MERefreshMapTileProvider
@end

@interface MERefreshMapRegionStress : MERefreshMapRegionTest
@property (retain) NSMutableArray* boundingBoxes;
@property (assign) int boxIndex;
@property (assign) int timerTickCount;
@end
