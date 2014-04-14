//  Copyright (c) 2012 BA3, LLC. All rights reserved.


//Demonstrates loading a marker as fast as possible
#import <Foundation/Foundation.h>
#import "../METest.h"

@interface MEMarkerSynchronousLoad : METest <MEMarkerMapDelegate>
@property (assign) MEMarkerImageLoadingStrategy markerImageLoadingStrategy;
@end

@interface MEMarkerAsynchronousLoad : MEMarkerSynchronousLoad
@end

@interface MEMarkersFastPath : METest <MEMarkerMapDelegate>
@property (assign) int markerWeight;
@property (assign) int clusterDistance;
@property (assign) int maxLevel;
@property (assign) MEMapType mapType;
- (NSMutableArray*) createMarkers;
- (void) addMap;
@end

@interface MEMarkersFastPathClustered : MEMarkersFastPath
@end
