//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"


@interface MEMarkerDatabaseCacheTest : METest <MEMarkerMapDelegate>
@property (assign) int tickCount;
@property (retain) NSMutableArray* airportMarkers;
@end
