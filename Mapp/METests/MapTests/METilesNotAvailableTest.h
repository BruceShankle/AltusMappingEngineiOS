//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"

//This test simulates a tile provider that can be
//toggled on and off.

@interface MEOnOffTileProvider : METileProvider
@property (assign) METileProviderResponse response;
@property (assign) int currentTile;
@end

@interface MEXYZTileProvider: MEOnOffTileProvider
@end

@interface METilesNotAvailableTest : METest
@property (retain) MEOnOffTileProvider* tileProvider;
@property (retain) UIButton* btnOnOff;
@property (retain) UIButton* btnRefreshDirtyTiles;
-(void) createTileProvider;
@end

@interface METilesNotAvailableXYZTest : METilesNotAvailableTest
@end