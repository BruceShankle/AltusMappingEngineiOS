//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <ME/ME.h>
#import "../METest.h"

@interface VectorGridProvider : METileProvider
@property (retain) NSMutableArray* terrainMaps;
@property (assign) CGPoint zeroFtImageAnchorPoint;
@property (assign) CGPoint questionMarkerAnchorPoint;
@property (retain) NSMutableDictionary* terrainMarkerDictionary;
@property (assign) BOOL showAllLevels;
@end

@interface TerrainGridTest : METest <MEDynamicMarkerMapDelegate>
-(VectorGridProvider*) createTileProvider;
@end

@interface TerrainGridTest2 : TerrainGridTest
@end
