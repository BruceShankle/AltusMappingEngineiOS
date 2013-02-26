//  Copyright (c) 2012 BA3, LLC. All rights reserved.

/**
 MEMapView displays maps, annotations and other content, and handles gestures (panning, zooming, scrolling, tapping) perfomed by the user. MEMapView's interface is similar to that of MKMapView and UIScrollView.
 */

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MEGeometry.h"
#import "MEGeographicBounds.h"
#import "MEProtocols.h"

@interface MEMapView : GLKView <UIGestureRecognizerDelegate>

/** Forces linker to link this file via NIB-only interfaces.*/
+ (void) forceLink; 

//Delegates

/**The receiver’s MEMapViewDelegate. A map view sends messages to its delegate regarding the loading of map data and changes in the portion of the map being displayed. The delegate also manages annotations. The delegate should implement the methods of the MEMapViewDelegate protocol.*/
@property (nonatomic, assign) id <MEMapViewDelegate> meMapViewDelegate;

////////////////////////////////////////////////
//Properties. Please keep them documented.

/**Controls the tile render size. This is the maximum size of a tile on screen and defaults to 380 points. If you make this value smaller, the engine will render more details (in essence a higher detail level) for a given scene width. If you make this value larger, the engine will render less tiles for a given scene width. You will want to adjust this setting based on:
 1) the render size of your map view
 2) the amount of detail you desire
 3) bandwidth in cases in where you download tiles
 4) memory on the device
 5) the size you have set the engine's cache size to
 6) the physical capabilities of the display (retina or non-retina)
 Halving this value will effectively quadruple the number of tiles rendered.
*/
@property (nonatomic, assign) uint maxTileRenderSize;

/** Controls the amount of bias towards a given level of detail for all map types. The default setting is 0 and no biasing will be applied. This value should be adjusted if you are:
 1) displaying spherical mercator maps that are rendered differently at different levels (i.e. a MapBox streetmap)
 2) the virtual camera will be viewing the planet from an extremely high altitude
 3) you desire to force a consistent level to be rendered at all times
 -or-
 a) You have a densely populated clustered marker map that you desire to force to a consistent level of detail
 
 If you are only displaying maps that are generated with meool from a single raster source or PDF you do not need to change this setting. Modifying this setting can result in increased CPU and memory utilization when the virtual camera is at a high altitude viewing the planet form orbit. Valid ranges are 0.0 to 1.0. This setting is ignored when in 3D mode. NOTE: Enabling this setting can result in potentially more tiles being loaded for virtual maps than are necessary for the current camera position.
 */
@property (nonatomic, assign) double tileLevelBias;

/** When tileLevelBias is greater than zero, setting this to YES limits level bias flip-flopping with smooth camera motion. NOTE: Enabling this setting can result in potentially more tiles being loaded for virtual maps than are necessary for the current camera position.
 */
@property (nonatomic, assign) BOOL tileBiasSmoothingEnabled;

/** Defaults to 1.0. Pan gesture velocity is multiplied by this value before the pan gesture is handled. Set to a value between 0 and 1.*/
@property (nonatomic, assign) double panVelocityScale;

///////////////////////////
//Gesture recognizers
/** The underlying gesture recognizer for pan gestures. Your application accesses this property when it wants to more precisely control which pan gestures are recognized. */
@property(nonatomic, readonly, retain) UIPanGestureRecognizer *panGestureRecognizer;

/** The underlying gesture recognizer for pinch gestures. Your application accesses this property when it wants to more precisely control which pinch gestures are recognized. */
@property(nonatomic, readonly, retain) UIPinchGestureRecognizer *pinchGestureRecognizer;

/** The underlying tap gesture recognizer for a single-tap event. This is used for hit-testing markers.*/
@property(nonatomic, readonly, retain) UITapGestureRecognizer *tapGestureRecognizer;

/** The underlying tap gesture recognizer for tap-to-zoom-in. By default this is a single-touch, double-tap. Your application accesses this property when it wants to more precisely control which tap gestures are recognized. */
@property(nonatomic, readonly, retain) UITapGestureRecognizer *tapZoomInGestureRecognizer;

/** The underlying tap gesture recognizer for tap-to-zoom-out. By default this is a double-touch, single-tap. Your application accesses this property when it wants to more precisely control which tap gestures are recognized.*/
@property(nonatomic, readonly, retain) UITapGestureRecognizer *tapZoomOutGestureRecognizer;

/** Enables or disables pan deceleration. Defaults to YES.*/
@property (nonatomic, assign, getter = isPanDecelerationEnabled) BOOL isPanDecelerationEnabled;

/** Controls the decay rate of pan deceleration. Defaults to -10.0.*/
@property (nonatomic, assign) double panDeceleration;

/** The color to clear the map view with before any rendering occurs. Defaults to black.*/
@property (nonatomic, retain) UIColor* clearColor;

//////////////////////////////////////////////////////////////
//Camera control
/** Minimum zoom value the camera system will allow. The min zoom is how 'close' the camera is allowed to get in 2D mode. This value is a multiple of the Earth's radius A value that is too low will allow for overzoom and magnification of pixels resulting in poorer image quality. A value of 0.0085 works weel for TACs. Default value is 0.0065.*/
@property (nonatomic, assign) double minimumZoom;

/** Maximum zoom value the camera system will allow. The max zoom is how 'far' away the camera is allowed to get in 2D mode. This value is a multiple of the Earth's radius. Default value is 1.5*/
@property (nonatomic, assign) double maximumZoom;

/** A Boolean value that determines whether panning is enabled. If the value of this property is YES , panning is enabled, and if it is NO , panning is disabled. The default is YES. When panning is disabled, the view does not process the pan gesture recognizer events. */
@property (nonatomic, getter=isPanEnabled) BOOL panEnabled;

/** A Boolean value that determines whether pinch-to-zoom is enabled. If the value of this property is YES , pinching and tapping to zoom is enabled, and if it is NO , pinching and tapping to zoom is disabled. The default is YES. When zoom is disabled, the view does not process the pinch or tap gesture recognizer events. */
@property (nonatomic, getter=isZoomEnabled) BOOL zoomEnabled;


/** A Boolean value that indicates if the currenty physical display is a retina display.*/
@property (nonatomic, readonly) BOOL isRetinaDisplay;


///////////////////////////////////////////////////////////////
//Point conversion
/** Converts a map coordinate to a point in the specified view.
 @param coordinate The map coordinate for which you want to find the corresponding point.
 @return The point (in the appropriate view or window coordinate system) corresponding to the specified latitude and longitude value.*/
- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate;

/**Converts a point in the specified view’s coordinate system to a map coordinate.
 @param point The point you want to convert.
 @return The view that serves as the reference coordinate system for the point parameter.
 */
- (CLLocationCoordinate2D)convertPoint:(CGPoint)point;

/**Get the distance to the horizon given a point in screen space
 @param point The point on screen to measure 
 @return distance to horizon with 0 being on the horizon and 1 being in the center of the earth.
 */
- (double)distanceToHorizonFromPoint:(CGPoint)point;

/** Converts a map coordinate to a point in the specified view.
 @param coordinate The map coordinate for which you want to find the corresponding point.
 @return The point (in the appropriate view or window coordinate system) corresponding to the specified latitude and longitude value.*/
- (CGPoint)convertMECoordinate:(MELocationCoordinate2D)coordinate;

///////////////////////////////////////////////////////////////
//Camera positioning
/** Changes the center coordinate of the map and optionally animates the change. This function assumes the rendering system is in 2D mode.
 @param coordinate The new center coordinate for the map.
 @param animationDuration Length of time to animate to new coodrindate. 0 to move instantly or stop prior animations
 */
- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate
		  animationDuration:(CGFloat) animationDuration;

/**The map coordinate at the center of the map view. Changing the value in this property centers the map on the new coordinate without changing the current zoom level. Changing the value of this property updates the map view immediately. If you want to animate the change, use the setCenterCoordinate:animationDuration: method instead.
 */
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;

//Location API
/**
 The current location in terms of geographic center and alitude. We intentionally do not use CLLocation because it is an object. Changing the value in this property centers the map on the new coordinate and 'zooms' to the given altiude contained in the location struct. If you want to animate the change, use the setLocation:animated: method instead.
 */
@property (nonatomic, assign) MELocation location;

/** Returns the current altitude in meters that the camera is above sea level.*/
@property (nonatomic, readonly) double altitude;

/** Changes the center coordinate of the map and zoom and optionally animates the change. This function assumes the rendering system is in 2D mode.
 @param location The new center location to view the map from.
 @param animationDuration Length of time to animate to the new position. Specify 0 for instant change.
 */
- (void)setLocation:(MELocation) location
  animationDuration:(CGFloat)animationDuration;

/** Similar to setLocation, but uses only 2 coordinates. Changes the center coordinate of the map and zoom and optionally animates the change. This function assumes the rendering system is in 2D mode. Makes the 2 coordiantes fit the view by moving the map. If it is not possible to actually view the 2 coordinates, the behavior is undefined.
 @param coordinate1 First coordinate that should be in view.
 @param coordinate2 Second coordinate that should be in view.
 @param horizontalBufferInPoints number of points from edge of left and right of the screen to use as padding
 @param verticalBufferInPoints number of points from the edge of the top and bottom of the screen to use as padding
 @param animationDuration The lenght of time to animate the camera to the new position. Specify 0 to make the change instantaneous.*/
- (void)lookAtCoordinate:(CLLocationCoordinate2D) coordinate1
           andCoordinate:(CLLocationCoordinate2D) coordinate2
    withHorizontalBuffer:(double)horizontalBufferInPoints
      withVerticalBuffer:(double)verticalBufferInPoints
	   animationDuration:(CGFloat) animationDuration;

/** Returns the location needed to view the given bounds.
 @param bounds geographics bounding box of the target region
 @param horizontalBufferInPoints number of points from edge of left and right of the screen to use as padding
 @param verticalBufferInPoints number of points from the edge of the top and bottom of the screen to use as padding
 */
- (MELocation) locationThatFitsBounds:(MELocationBounds) bounds
                 withHorizontalBuffer:(double)horizontalBufferInPoints
                   withVerticalBuffer:(double)verticalBufferInPoints;

/** Returns a location at the minimum altitude to view all of the geographic points in the specified array. The locationThatFitsPoints API can be used to look at any set of aribrary points. If you provide points that cannot possibly be viewed from any vantage point, the behavior is undefined. You can use the encodeCoordinate and decodeCoordinate functions to wrap and uwrap CLLocationCoordinate2D structs for use with this function.
 @param points An array of NSValue objects that wrap CLLocationCoordinate2D objects.
@param horizontalBufferInPoints number of points from edge of left and right of the screen to use as padding
@param verticalBufferInPoints number of points from the edge of the top and bottom of the screen to use as padding
 */
- (MELocation) locationThatFitsPoints:(NSArray*) points
                 withHorizontalBuffer:(double)horizontalBufferInPoints
                   withVerticalBuffer:(double)verticalBufferInPoints;

/** Returns a CLLocationCoordinate that is wrapped inside an NSValue object.*/
- (CLLocationCoordinate2D) decodeCoordinate:(NSValue*) valueWrappedCoordinate;

/** Wraps a CLLocationCoordinate2D struct in an NSValue object.*/
- (NSValue*) encodeCoordinate:(CLLocationCoordinate2D) clLocation;

/** Set virtual camera's orientation.
 
 Changes the heading, roll, and pitch angles of the virtual camera.
 
 @param heading Heading in degrees. 0 to 360.
 @param roll Roll in degrees. -180 to 180.
 @param pitch Pitch angle in degrees -180 to 180.
 @param animationDuration Length of time in seconds to animate the change. Use 0 for no animation.
 */
- (void) setCameraOrientation:(CGFloat) heading
						 roll:(CGFloat) roll
						pitch:(CGFloat) pitch
			animationDuration:(CGFloat) animationDuration;

/** Zoom the view in as if the user has double-tapped / singled-touched on the view. The zoom will occur around the views center point.*/
- (void) zoomIn;

/** Zoom the view out as if the user has double-touch / single-tapped on the view. The zoom will occur around the views center point.*/

- (void) zoomOut;

/** Converts a point value to its cooresponding pixel value.*/
- (double) pointValueToPixelValue:(CGFloat)pointValue;

/** Handles pan gesture. Default behaviour is to pan.*/
- (IBAction) panGestureHandler:(UIGestureRecognizer *)sender;

/** Handles pinch gesure. Default behaviour is to zoom in and out.*/
- (IBAction) pinchGestureHandler:(UIGestureRecognizer *)sender;

/** Handles tap gesture. Default behaviour is to do marker hit testing.*/
- (IBAction) tapGestureHandler:(UIGestureRecognizer *)sender;

/** Handles double-tap single press gesture. Default behaviour is to zoom in.*/
- (IBAction) tapZoomInGestureHandler:(UIGestureRecognizer *)sender;

/** Handles single-tap double press gesture. Default behaviour is to zoom out.*/
- (IBAction) tapZoomOutGestureHandler:(UIGestureRecognizer *)sender;

@end
