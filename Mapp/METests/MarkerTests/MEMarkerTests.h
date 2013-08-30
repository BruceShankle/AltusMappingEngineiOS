//
//  MECreateAndAddMarkerMapTest.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/17/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../METest.h"
#import <ME/ME.h>
#import "MarkerTestData.h"

@interface MEMarkerTest: METest
@end

///////////////////////////////////////////////////////////
//Public transportation markers

//Bus stops generated in memory
@interface MESFOBusAddInMemoryClusteredMarkerTest : MEMarkerTest <MEMarkerMapDelegate>
@end

//Bus stops clustered in memory using fast marker system
@interface BusStopsClusteredInMemoryFast : MEMarkerTest <MEMarkerMapDelegate>
@property (assign) BOOL firstRun;
@end

@interface BusStopsNonClusteredInMemoryFast : MEMarkerTest <MEMarkerMapDelegate>
@property (assign) BOOL firstRun;
@end

@interface BusStopsNonClusteredInMemorySync : MEMarkerTest <MEMarkerMapDelegate>
@end


//Bus stops generated and saved to disk
@interface MESFOBusCreateAndAddClusteredMarkerTest : MESFOBusAddInMemoryClusteredMarkerTest
@end

//Bus stops loaded from disk
@interface MESFOBusAddExistingClusteredMarkerTest : MESFOBusCreateAndAddClusteredMarkerTest
@end

//Moving a marker around
@interface MEBusDynamicMarker : MEMarkerTest <MEMarkerMapDelegate>
@property (retain) MarkerTestData* markerTestData;
@property (assign) int routeIndex;
@end

//Rotating marker that moves around
@interface MERotatingBusDynamicMarker : MEBusDynamicMarker
@property (assign) double rotation;
@end

//METool generated markers
@interface MEMTCountryMarkersFromDisk : MEMarkerTest <MEMarkerMapDelegate>
@end

@interface MEMTStateMarkersFromDisk : MEMTCountryMarkersFromDisk
@end

@interface MEMTCountriesAndStateMarkersFromDisk : MEMTCountryMarkersFromDisk
@end

@interface MEMTCitiesFromDisk : MEMTCountryMarkersFromDisk
@end

@interface MECountryMarkersInMemory : MEMarkerTest <MEMarkerMapDelegate>
@property (retain) NSMutableArray* countries;
@end

@interface MECountryMarkersSaveToDisk : MECountryMarkersInMemory
@end

@interface MECountryMarkersFromDisk : MECountryMarkersSaveToDisk
@end

///////////////////////////////////////////////////////////////
//Aviation towers
@interface METowersHeightsMarkersTest : MEMarkerTest <MEMarkerMapDelegate>
-(NSString*) dbFile;
@end

@interface METowersHeightsMarkersTestHalfHidden : METowersHeightsMarkersTest
@property (assign) BOOL isVisible;
@end

@interface METowersHeightsMarkersTestRandomFontSize : METowersHeightsMarkersTest
@property (assign) float fontSize;
@end

@interface METAWSTowersCached : MEMarkerTest <MEMarkerMapDelegate>
@property (assign) CGPoint markerAnchorPoint;
@end

@interface METAWSTowersNonCached : METAWSTowersCached
@end

///////////////////////////////////////////////////////////////
//Marker performance tests
@interface MEMarkerPerfTest : METest
@end



