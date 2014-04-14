//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface MEGeographicBounds : NSObject
{
	CLLocationCoordinate2D _southWestPoint;
	CLLocationCoordinate2D _northEastPoint;
}
/**The 'min' geographic point of the bounds.*/
@property (nonatomic, assign) CLLocationCoordinate2D southWestPoint;
/**The 'max' geographic point of the bounds.*/
@property (nonatomic, assign) CLLocationCoordinate2D northEastPoint;

/** If non-zero, expresses the slippy-maps x coordinate of the tile.*/
@property (nonatomic, assign) int slippyX;
/** If non-zero, expresses the slippy-maps y coordinate of the tile.*/
@property (nonatomic, assign) int slippyY;
/** If non-zero, expresses the slippy-maps zoom level of the tile.*/
@property (nonatomic, assign) int slippyZoom;


/**Width in arc hours.*/
@property (nonatomic, readonly, getter = getArcHourWidth) CLLocationDistance arcHourWidth;
/**Height in arc hours.*/
@property (nonatomic, readonly, getter = getArcHourHeight) CLLocationDistance arcHourHeight;
/**Width times height in square arc hours.*/
@property (nonatomic, readonly, getter = getArcHourArea) float arcHourArea;

-(id) initWithLocations:(CLLocationCoordinate2D) southWestPoint northEastPoint:(CLLocationCoordinate2D) northEastPoint;
-(id) initWithBounds:(MEGeographicBounds*) bounds;
-(BOOL) contains:(CLLocationCoordinate2D) location;
-(BOOL) equals:(MEGeographicBounds*) compareTo;
-(MEGeographicBounds*) copy;

@end
