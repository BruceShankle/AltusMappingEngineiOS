//  Copyright (c) 2012 BA3, LLC. All rights reserved.

/**
 Provides performance information about the engine.
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MEGeographicBounds.h"
@interface MEInfo : NSObject

@property CGFloat cameraX;
@property CGFloat cameraY;
@property CGFloat cameraZ;
@property BOOL cameraChangedSinceLastFrame;
@property CGFloat frameRate;
@property CGFloat frameTime;
@property CGFloat drawCallsPerFrame;
@property uint tileCacheMemorySize;
@property uint tileCacheTileCount;
@property uint inFlightTileCount;
@property uint multiInFlightTileCount;
@property uint appMemoryUsage;

@property uint totalWorkerCount;
@property uint animationCount;
@property uint updateablesCount;
@property uint visibleTileCount;
@property uint visibleTileCountPreBias;
@property BOOL cameraIsMoving;
@end

