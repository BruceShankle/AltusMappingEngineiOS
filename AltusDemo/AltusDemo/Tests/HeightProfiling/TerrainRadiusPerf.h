//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import "../METest.h"

@interface TerrainRadiusPerf : METest <MEVectorMapDelegate, MEDynamicMarkerMapDelegate>
@property (retain) MEPolygonStyle* polygonStyle;
@property (retain) NSString* boundingGraphicsMapName;
@property (assign) CLLocationCoordinate2D peakLocation;
@property (assign) CLLocationCoordinate2D centerLocation;
@property (assign) double nauticalMileRadius;
@property (assign) double natticalMilesFromPeak;
@property (assign) double radialFromPeak;
@property (retain) NSMutableArray* terrainMaps;
@property (retain) NSDate *startTime;
@property (retain) NSDate *endTime;
//@property (retain) METerrainProfileCache* terrainProfileCache;
@property (assign) BOOL useCache;
@end


@interface TerrainRadiusPerfCached : TerrainRadiusPerf
@end

@interface TerrainRadiusPerfCachedBigRadius : TerrainRadiusPerf
@end
