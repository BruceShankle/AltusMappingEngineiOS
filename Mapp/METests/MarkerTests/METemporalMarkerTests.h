//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"

//Test A: add 10 markers every 0.5 seconds
@interface METemporalMarkerTestA : METest <MEMarkerMapDelegate>
@property (retain) NSMutableArray* airportMarkers;
@property (assign) unsigned int airportMarkerIndex;
@end

//Test B: add all markers from an existing db then add 10 new markers every 0.5 second
@interface METemporalMarkerTestB : METest <MEMarkerMapDelegate>
@property (retain) NSMutableArray* airportMarkers;
@property (assign) unsigned int airportMarkerIndex;
@end

//Test C: add all markers from an existing db then update 10 existing markers every 0.5 second
@interface METemporalMarkerTestC : METest <MEMarkerMapDelegate>
@property (retain) NSMutableArray* airportMarkers;
@property (retain) NSMutableDictionary* markerImageDictionary;
@property (assign) unsigned int airportMarkerIndex;
@end

//Test D: mix of C and B
@interface METemporalMarkerTestD : METest <MEMarkerMapDelegate>
@property (retain) NSMutableArray* airportMarkersEven;
@property (retain) NSMutableArray* airportMarkersOdd;
@property (retain) NSMutableDictionary* markerImageDictionary;
@property (assign) unsigned int airportMarkerEvenIndex;
@property (assign) unsigned int airportMarkerOddIndex;
@end

