//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"

@interface MEStaticAsyncTileProviderBatch : METileProvider
@property (assign) double sleepTime;
@property (assign) BOOL failRandomly;
@property (assign) BOOL failWithUIImage;
@property (assign) BOOL useNSData;
@property (assign) int currentTileSet;
- (void) nextTileSet;
@end

@interface MEAnimatedMapTest : METest
@property (assign) int currentState;
@property (assign) int currentLocation;
@property (retain) MEStaticAsyncTileProviderBatch* tileProvider;
@property (assign) BOOL automaticTileRequestMode;
@end

@interface MEAnimatedMapTest2 : MEAnimatedMapTest <MEMapViewDelegate>
@property (retain) id<MEMapViewDelegate> oldDelegate;
@property (retain) UIButton* btnPlayPause;

@end

@interface MEAnimatedMapTest3 : MEAnimatedMapTest2
@property (retain) UIButton* btnRefreshDirtyTiles;
@end

@interface MEAnimatedMapTest4 : MEAnimatedMapTest3
@property (retain) UIButton* btnFailRandomly;
@property (retain) UIButton* btnFailType;
@end

@interface MEAnimatedMapTest5 : MEAnimatedMapTest4
@property (retain) IBOutlet UIButton* btnRefreshRegion;
@end




