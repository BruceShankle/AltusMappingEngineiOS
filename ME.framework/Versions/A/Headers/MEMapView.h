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

/**Controls the tile render size. This is the maximum size of a tile on screen and defaults to 380 points. If you make this value smaller, the engine will render more details (in essence a higher detail level) for a given scene width. If you make this value larger, the engine will render less tiles for a given scene width. You will want to adjust this setting based on 1) the render size of your map view, 2) the amount of detail you desire, 3) bandwidth in cases in where you download tiles. Halving this value will effectively quadruple the number of tiles rendered.*/
@property (nonatomic, assign) uint maxTileRenderSize;

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

/** Converts a map coordinate to a point in the specified view.
 @param coordinate The map coordinate for which you want to find the corresponding point.
 @return The point (in the appropriate view or window coordinate system) corresponding to the specified latitude and longitude value.*/
- (CGPoint)convertMECoordinate:(MELocationCoordinate2D)coordinate;

///////////////////////////////////////////////////////////////
//Camera positioning
/** Changes the center coordinate of the map and optionally animates the change. This function assumes the rendering system is in 2D mode.
 @param coordinate The new center coordinate for the map.
 @param animated Specify YES if you want the map view to scroll to the new location or NO if you want the map to display the new location immediately.
 */
- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;

/**The map coordinate at the center of the map view. Changing the value in this property centers the map on the new coordinate without changing the current zoom level. Changing the value of this property updates the map view immediately. If you want to animate the change, use the setCenterCoordinate:animated: method instead.
 */
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;

//Location API
/**
 The current location in terms of geographic center and alitude. We intentionally do not use CLLocation because it is an object. Changing the value in this property centers the map on the new coordinate and 'zooms' to the given altiude contained in the location struct. If you want to animate the change, use the setLocation:animated: method instead.
 */
@property (nonatomic, assign) MELocation location;


/** Changes the center coordinate of the map and zoom and optionally animates the change. This function assumes the rendering system is in 2D mode.
 @param location The new center location to view the map from.
 @param animated Specify YES if you want the map view animate to the new location or NO if you want the map to display the new location immediately.
 */
- (void)setLocation:(MELocation) location
           animated:(BOOL)animated;

/** Similar to setLocation, but uses only 2 coordinates. Changes the center coordinate of the map and zoom and optionally animates the change. This function assumes the rendering system is in 2D mode. Makes the 2 coordiantes fit the view by moving the map. If it is not possible to actually view the 2 coordinates, the behavior is undefined.
 @param coordinate1 First coordinate that should be in view.
 @param coordinate2 Second coordinate that should be in view.
 @param animated Specify YES if you want the map view animate to the new location or NO if you want the map to display the new location immediately.*/
- (void)lookAtCoordinate:(CLLocationCoordinate2D) coordinate1
           andCoordinate:(CLLocationCoordinate2D) coordinate2
                animated:(BOOL)animated;

/** Returns the location needed to view the given bounds.*/
- (MELocation) locationThatFitsBounds:(MELocationBounds) bounds;

/** Returns a location at the minimum altitude to view all of the geographic points in the specified array. The locationThatFitsPoints API can be used to look at any set of aribrary points. If you provide points that cannot possibly be viewed from any vantage point, the behavior is undefined. You can use the encodeCoordinate and decodeCoordinate functions to wrap and uwrap CLLocationCoordinate2D structs for use with this function.
 @param points An array of NSValue objects that wrap CLLocationCoordinate2D objects.*/
- (MELocation) locationThatFitsPoints:(NSArray*) points;

/** Returns a CLLocationCoordinate that is wrapped inside an NSValue object.*/
- (CLLocationCoordinate2D) decodeCoordinate:(NSValue*) valueWrappedCoordinate;

/** Wraps a CLLocationCoordinate2D struct in an NSValue object.*/
- (NSValue*) encodeCoordinate:(CLLocationCoordinate2D) clLocation;

/** Set virtual camera's orientation.
 
 Changes the heading, roll, and pitch angles of the virtual camera.
 
 @param heading Heading in degrees. 0 to 360.
 @param roll Roll in degrees. -180 to 180.
 @param pitch Pitch angle in degrees -180 to 180.
 */
- (void) setCameraOrientation:(CGFloat) heading roll:(CGFloat) roll pitch:(CGFloat) pitch;

/** Zoom the view in as if the user has double-tapped / singled-touched on the view. The zoom will occur around the views center point.*/
- (void) zoomIn;

/** Zoom the view out as if the user has double-touch / single-tapped on the view. The zoom will occur around the views center point.*/

- (void) zoomOut;

/**Converts a point value to its cooresponding pixel value.*/
- (double) pointValueToPixelValue:(CGFloat)pointValue;


@end
