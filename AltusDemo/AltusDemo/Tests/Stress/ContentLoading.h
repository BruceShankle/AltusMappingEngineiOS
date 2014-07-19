//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import "../METest.h"

/**
Simulates content loading of different map types:
1. CPU-intensive map from a custom tile provider (Artistic / Fractal)
2. A streaming internet map that is not cached (WMS / NOAA Radar)
3. A vector base map loaded from disk (Vector Maps / AltusVectorPackage)
4. An in-memory vector map with lots of polygons (Vector Maps / Polygons)
5. A layer with a route and labels on each waypoint (User Interaction / Route Plotting)
6. Labels for places all over the world with complex font rendering (Markers / Clustered / Places - Arial)
*/
@interface ContentLoading : METest <MEMapViewDelegate>
@property (retain) NSArray* otherTests;
@property (retain) id<MEMapViewDelegate> oldMapViewDelegate;
@property (assign) int mapsLoadingCount;
@property (assign) int initialFPS;
@property (assign) int loadingFPS;
@property (assign) BOOL tileBiasSmoothingEnabled;
@property (assign) float tileLevelBias;
@property (assign) int maxTilesInFlight;
@end

@interface ContentLoadingAdjustPriorities : ContentLoading
@end

@interface ContentLoadingNoBiasDynFPSAdjustPriorities : ContentLoadingAdjustPriorities
@end

@interface ContentLoadingNoBias : ContentLoading
@end

@interface ContentLoadingNoBiasDynFPS : ContentLoading
@end

@interface ContentLoadingNoBiasDynFPSTIF : ContentLoading
@end
