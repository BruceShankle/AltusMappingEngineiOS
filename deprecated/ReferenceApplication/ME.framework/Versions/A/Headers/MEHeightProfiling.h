//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>

/**Describes a sample from a terrain database.
 */
@interface MEHeightSample : NSObject
@property (assign) CLLocationCoordinate2D location;
@property (assign) short height;
@end

/**Provides functions to sample heights from terrain maps.*/
@interface METerrainProfiler : NSObject

/** Returns an array of MEHeightSample objects along a given route. This function may be run on a background thread.
 @param terrainMaps An array of MEMapFileInfo objects for each terrain map to sample from.
 @param wayPoints An array of NSValue wrapped CGPoints (minimum of two) that represent waypoints for the route.
 @param samplePointCount The number of samples to generate.
 @param bufferRadius The nautical mile buffer radius around the route formed by the way points.
 */
+ (NSArray*) getTerrainProfile:(NSArray*) terrainMaps
					 wayPoints:(NSArray*) wayPoints
			  samplePointCount:(uint) samplePointCount
				  bufferRadius:(double) bufferRadius;


/** Returns the minimum (.x value) and maximum (.y value) terrain heights within the geographic bounds of a rectangle defined by the specified SW and NE points. This function may be called from a background thread.
 @param terrianMaps An array of MEMapFileInfo objects for each terrain map to sample from.
 @param southWestLocation The 'lower left' corner of the bounds.
 @param northEastLocation THe 'upper right' cornder of the bounds.
 */
+ (CGPoint) getMinMaxTerrainHeightsInBoundingBox:(NSArray*) terrainMaps
							   southWestLocation:(CLLocationCoordinate2D) southWestLocation
							   northEastLocation:(CLLocationCoordinate2D) northEastLocation;

/** Returns the minimum (.x value) and maximum (.y value) terrain heights within the specified radius (in nautical miles) of the specified location. This function may be called from a background thread.
 @param terrianMaps An array of MEMapFileInfo objects for each terrain map to sample from.
 @param location The geographic point around which to search for markers.
 @param radius The nautical mile radius around the point to search for markers.
 */
+ (CGPoint) getMinMaxTerrainHeightsAroundLocation:(NSArray*) terrainMaps
										 location:(CLLocationCoordinate2D) location
										   radius:(double) radius;


@end