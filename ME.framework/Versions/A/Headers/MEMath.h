//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MEGeographicBounds.h"

/**Useful math functions.*/
@interface MEMath : NSObject

+(CGPoint) transformCoordinate:(CLLocationCoordinate2D) coordinate bounds:(MEGeographicBounds*) bounds size:(CGSize) size;

+(CGPoint) transformCoordinate:(CGFloat) longitude latitude:(CGFloat) latitude bounds:(MEGeographicBounds*) bounds size:(CGSize) size;

/**Given a CGPoint where x represents longitude, and y represents latitude, returns a new CGPoint in EPSG:3857 coordinates where x represents longitude and y represents latitude.*/
+(CGPoint) transformCoordinateToSphericalMercator:(CGPoint) sourceCoordinate;

/**Convert degrees to radians.*/
+(double) toRadians:(double)degrees;

/**Convert radians to degrees.*/
+(double) toDegrees:(double)radians;

/**Returns the great circle distance between two points in radians between two points.*/
+(double) distanceBetween:(CGPoint) point1
				   point2:(CGPoint) point2;

/**Returns the great circle distance in nautical miles between two points.*/
+(double) nauticalMilesBetween:(CGPoint) point1
						point2:(CGPoint) point2;

/**Returns the great circle distance in nautical miles of a route.*/
+(double) nauticalMilesInRoute:(NSArray*) wayPoints;

/**Given an array of way points, return a new array of points evenly spaced along that route.*/
+(NSArray*) tesselateRoute:(NSArray*) wayPoints pointCount:(uint) pointCount;

/**Converts radians to nautical miles.*/
+(double) radiansToNauticalMiles:(double) radians;

/**Converts nautical miles to radians.*/
+(double) nauticalMilesToRadians:(double) nauticalMiles;

/**Returns a point on a radial a given distance from an origin point.
 @param point Where x = longitude, y = latitude
 @param radial Angle in degrees.
 @param distance Distance in nautical miles.*/
+(CGPoint) pointOnRadial:(CGPoint) point
				  radial:(double) radial
				distance:(double) distance;

/**Returns a location on a radial a given distance from an origin location.
 @param point Where x = longitude, y = latitude
 @param radial Angle in degrees.
 @param distance Distance in nautical miles.*/
+(CLLocationCoordinate2D) locationOnRadial:(CLLocationCoordinate2D) location
									radial:(double) radial
								  distance:(double) distance;

/**Returns the degress heading you would need to take to go from point1 to point2.*/
+(double) courseFromPoint:(CGPoint) point1
				  toPoint:(CGPoint) point2;


//(vec2d origin, double radial, double distance)
/**Tesselates a route between two georaphic points into an array of points of nodeCount size.*/
+(NSArray*) tesselateRoute:(CGPoint) point1
					point2:(CGPoint) point2
				 nodeCount:(int) nodeCount;

/**Tesselates a route between two georaphic points into an array of points along the route separating each node by milesPerNode nautical miles.*/
+(NSArray*) tesselateRoute:(CGPoint) point1
					point2:(CGPoint) point2
			  milesPerNode:(double) milesPerNode;

/**Returns the point that is f/1 the distance between point1 and point2. When f = 0, point 1 will be returned, when f = 1, point 2 will be returned. This is used for route-line point tesselation. The units of point1 and point 2 should be degrees x=lon/y=lat. Returned point will be degrees x=lon/y=lat.*/
+(CGPoint) pointBetween:(CGPoint) point1
				 point2:(CGPoint) point2
			   fraction:(double) f;

/**Returns YES if x is a power of 2.*/
+(BOOL) isPowerOfTwo:(uint) x;

/**Returns the next power of 2.*/
+(int) nextPowerOfTwo:(int) x;

@end
