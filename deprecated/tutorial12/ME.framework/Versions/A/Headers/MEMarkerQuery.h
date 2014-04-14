//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MEMarker.h"

/**Used to query marker map databases.*/
@interface MEMarkerQuery : NSObject

/** Returns an array of maximum marker weights in a route corridor mapped to a fixed sample point count.The intention of this function is to enable you to draw a graph of samplePointCount width such that a maximum marker weight can be plotted on the graph. For example: plotting the tallest obstacle along a route. This function may be called from a background thread.
 @param markerSqliteFile The full path of the marker sqlite database file.
 @param tableNamePrefix For databases with multiple marker tables, the prefix for the table name.
 @param wayPoints An array of NSValue wrapped CGPoints (minimum of two) that represent waypoints for the route where in each point x = longitude and y = latitude.
 @param samplePointCount The number of samples to generate.
 @param bufferRadius The nautical mile buffer radius around the route formed by the way points..
 */
+ (NSArray*) getMaxMarkerWeightsAlongRoute:(NSString*) markerSqliteFile
						   tableNamePrefix:(NSString*) tableNamePrefix
								 wayPoints:(NSArray*) wayPoints
						  samplePointCount:(uint) samplePointCount
							  bufferRadius:(double) bufferRadius;

/** Returns an array of MEMarker objects that lie along a given route. The route is tesselated to at least samplePointCount and a corridor around this tesselated route is used to search for markers that intersect the corridor. This function may be called from a background thread.
 @param markerSqliteFile The full path of the marker sqlite database file.
 @param tableNamePrefix For databases with multiple marker tables, the prefix for the table name.
 @param wayPoints An array of NSValue wrapped CGPoints (minimum of two) that represent waypoints for the route where in each point x = longitude and y = latitude.
 @param samplePointCount The number of sample points the route will be tesselated to.
 @param bufferRadius The nautical mile buffer radius around the route formed by the way points.
 */
+ (NSArray*) getMarkersAlongRoute:(NSString*) markerSqliteFile
				  tableNamePrefix:(NSString*) tableNamePrefix
						wayPoints:(NSArray*) wayPoints
					 bufferRadius:(double) bufferRadius;

/** Returns an array of MEMarker objects from the specified marker database within a given nautical mile radius of the specified location. This function may called from a background thread.
 @param markerSqliteFile The full path of the marker sqlite database file.
 @param tableNamePrefix For databases with multiple marker tables, the prefix for the table name.
 @param location The geographic point around which to search for markers.
 @param radius The nautical mile radius around the point to search for markers.
 */
+ (NSArray*) getMarkersAroundLocation:(NSString*) markerSqliteFile
					  tableNamePrefix:(NSString*) tableNamePrefix
							 location:(CLLocationCoordinate2D) location
							   radius:(double) radius;

/** Returns an MEMarker object with the highest weight from the specified marker database within a given nautical mile radius of the specified location. If there is no marker, returns nil. This function may be called from a background thread.
 @param markerSqliteFile The full path of the marker sqlite database file.
 @param tableNamePrefix For databases with multiple marker tables, the prefix for the table name.
 @param location The geographic point around which to search for markers.
 @param radius The nautical mile radius around the point to search for markers.
 */
+ (MEMarker*) getHighestMarkerAroundLocation:(NSString*) markerSqliteFile
							 tableNamePrefix:(NSString*) tableNamePrefix
									location:(CLLocationCoordinate2D) location
									  radius:(double) radius;

/** Returns an array of MEMarker objects from the specified marker database that lie within the geographic bounds of a rectangle defined by the specified SW and NE points. This function takes into account meridian and antimeridian crossing of the given bounds. This function may be called from a background thread.
 @param markerSqliteFile The full path of the marker sqlite database file.
 @param tableNamePrefix For databases with multiple marker tables, the prefix for the table name.
 @param southWestLocation The 'lower left' corner of the bounds.
 @param northEastLocation THe 'upper right' cornder of the bounds.
 */
+ (NSArray*) getMarkersInBoundingBox:(NSString*) markerSqliteFile
					 tableNamePrefix:(NSString*) tableNamePrefix
				   southWestLocation:(CLLocationCoordinate2D) southWestLocation
				   northEastLocation:(CLLocationCoordinate2D) northEastLocation;

/** Returns an MEMarker object with the highest weight that lies within the geographic bounds of a rectangle defined by the specified SW and NE points. If there is no marker, returns nil. This function takes into account meridian and antimeridian crossing of the given bounds. This function may be called from a background thread.
 @param markerSqliteFile The full path of the marker sqlite database file.
 @param tableNamePrefix For databases with multiple marker tables, the prefix for the table name.
 @param southWestLocation The 'lower left' corner of the bounds.
 @param northEastLocation THe 'upper right' cornder of the bounds.
 */
+ (MEMarker*) getHighestMarkerInBoundingBox:(NSString*) markerSqliteFile
							tableNamePrefix:(NSString*) tableNamePrefix
						  southWestLocation:(CLLocationCoordinate2D) southWestLocation
						  northEastLocation:(CLLocationCoordinate2D) northEastLocation;

/** Returns an array of MEMarker objects for markers that lie on a radial (from true North) from a given point. This function may be called from a background thread.
 @param markerSqliteFile The full path of the marker sqlite database file.
 @param tableNamePrefix For databases with multiple marker tables, the prefix for the table name.
 @param location  The location from which the radial lies.
 @param radial The radial in degrees.
 @param distance The nautical mile distance of the radial.
 @param bufferRadius The nautical mile width of the corridor along the radial.*/
+ (NSArray*) getMarkersOnRadial:(NSString*) markerSqliteFile
				tableNamePrefix:(NSString*) tableNamePrefix
					   location:(CLLocationCoordinate2D) location
						 radial:(double) radial
					   distance:(double) distance
				   bufferRadius:(double) bufferRadius;

@end
