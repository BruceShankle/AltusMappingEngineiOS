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
@property int tileCacheMemorySize;
@property int tileCacheTileCount;
@property int inFlightTileCount;
@property int multiInFlightTileCount;
@property int appMemoryUsage;

@property int parallelWorkerCount;
@property int serialWorkerCount;
@property int totalWorkerCount;

@end

