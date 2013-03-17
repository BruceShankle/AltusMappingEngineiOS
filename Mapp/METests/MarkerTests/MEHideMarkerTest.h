//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import "../MEtest.h"

@interface MEHideMarkerTest : METest <MEMarkerMapDelegate>
@property (retain) NSMutableArray* airportMarkers;
@property (assign) unsigned int airportMarkerIndex;
- (void) addMap;
@end


@interface MERemoveMarkerTest : MEHideMarkerTest
@property (retain) NSMutableArray* markerSubset;
@property (assign) int markerIndex;
@end
