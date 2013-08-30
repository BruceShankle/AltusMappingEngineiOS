//
//  MarkerTestData.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/29/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarkerTestData : NSObject
@property (retain) NSMutableArray* sanFranciscoBusStops;
@property (retain) NSMutableArray* sanFranciscoBusStopsFast;
@property (retain) NSMutableArray* sanFranciscoBusRoute;


+ (NSMutableArray*) loadCountries;
+ (NSString*) getCachePath;
+ (NSMutableArray*) loadAirportMarkers;
//Library/Caches paths
+ (NSString*) sfoBusStopsMarkerCachePath;
+ (NSString*) countryMarkerCachePath;
+ (NSString*) airportMarkerCachePath;

//Bundle paths
+ (NSString*) aviationDatabaseBundlePath;


+ (NSString*) airportMarkerBundlePath;
+ (NSString*) airportMarkerEvenBundlePath;
+ (NSString*) metoolMarkerBundlePath;
+ (NSString*) towerMarkerBundlePath;
+ (NSString*) stateMarkerBundlePath;
+ (NSString*) countryAndStateMarkerBundlePath;
+ (NSString*) citiesMarkerBundlePath;
+ (NSString*) countriesCitiesStatesMarkerBundlePath;
+ (NSString*) obstacleBundlePath;
@end
