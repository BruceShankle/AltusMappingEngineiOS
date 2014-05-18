//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import "../METest.h"

@interface TerrainInRadiusTest : METest <MEVectorMapDelegate, MEDynamicMarkerMapDelegate>
@property (retain) MEPolygonStyle* polygonStyle;
@property (retain) NSString* boundingGraphicsMapName;
@property (assign) CLLocationCoordinate2D peakLocation;
@property (assign) CLLocationCoordinate2D centerLocation;
@property (assign) double nauticalMileRadius;
@property (assign) double natticalMilesFromPeak;
@property (assign) double radialFromPeak;
@property (retain) NSMutableArray* terrainMaps;
@end
