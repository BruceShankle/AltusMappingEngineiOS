//  Copyright (c) 2012 BA3, LLC. All rights reserved.

/**
 MEMapView displays maps, annotations and other content, and handles gestures (panning, zooming, scrolling, tapping) perfomed by the user.
 */
#pragma once
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MEGeometry.h"
#import "MEGeographicBounds.h"
#import "MEProtocols.h"

@class MEMapViewController;

@interface MEMapView : GLKView <UIGestureRecognizerDelegate>

+ (void) forceLink; 

/** A simple convenience property for keeping track of multiple views.*/
@property (atomic, retain) NSString* name;

@property (nonatomic, assign) id <MEMapViewDelegate> meMapViewDelegate;

/**The device independent point width and height for map tiles. The default is 380.0.*/
@property (nonatomic, assign) double tilePointSize;

/**The device dependent pixel width and height for a map tile.*/
@property (nonatomic, readonly) unsigned int tilePixelSize;

/**When set to 1.0, the mapping engine will force all levels to be coherent. In other words, if you have a raster street map, you can force it to always display a consistent. This results in more work for the engine and increased tile counts being displayed. Sometimes this can have a drastic impact on performance at certain viewing angles and distances. This should always be set to 0.0 when possible.*/
@property (nonatomic, assign) double tileLevelBias;

/**When tileLevelBias is greater than zero, setting this to YES limits level bias flip-flopping with smooth camera motion. NOTE: Enabling this setting can result in potentially more tiles being loaded for virtual maps than are necessary for the current camera position.*/
@property (nonatomic, assign) BOOL tileBiasSmoothingEnabled;

/**Scales the velocity of panning gestures up or down. Default is 1.0. If you increase this value, the user's gestures velocities will be multiplied by this value. Consider adjusting the panAcceleration before changing this value.*/
@property (nonatomic, assign) double panVelocityScale;

/**The MEMapViewController that is driving this view.*/
@property (nonatomic, assign) MEMapViewController* meMapViewController;

@property(nonatomic, readonly, retain) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic, readonly, retain) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property(nonatomic, readonly, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property(nonatomic, readonly, retain) UITapGestureRecognizer *tapZoomInGestureRecognizer;
@property(nonatomic, readonly, retain) UITapGestureRecognizer *tapZoomOutGestureRecognizer;

/**If set to YES, enables pan deceleration, othersie pan deceleration is disabled. Defaults to YES.*/
@property (nonatomic, assign, getter = isPanDecelerationEnabled) BOOL isPanDecelerationEnabled;

/**Controls the rate at which a panning gesture's velocity slows down once the user finishes the gesture. The default value is -10.0. If you increase this value, it has the affect of giving more momentum to panning gestures. If you set this value to 0, panning gestures will create a motion that will not stop and just continue.*/
@property (nonatomic, assign) double panAcceleration;

/**The color displayed when the screen is cleared with prior to drawing the map.*/
@property (nonatomic, retain) UIColor* clearColor;

/** Sets the minimum distance in meters from the camera/viewer to the map */
@property (nonatomic, assign) double minimumZoom;

/** Sets the maximum distance in meters from the camera/viewer to the map */
@property (nonatomic, assign) double maximumZoom;

/**If set to YES, the view can be panned, otherwise it panning is disabled. Defaults to YES.*/
@property (nonatomic, getter=isPanEnabled) BOOL panEnabled;

/**If set to YES, the view can be zoomed, otherwise it zooming is disabled. Defaults to YES.*/
@property (nonatomic, getter=isZoomEnabled) BOOL zoomEnabled;

/** The scaling factor used to convert points to pixels. This value is computed when the render target size changes. Until there is a valid render target (i.e. the engine is initialized and there is an OpenGL surface available) this value may be 0.*/
@property (readonly) CGFloat deviceScale;

/**Converts a geographic coordinate to a screen positiion.*/
- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate;

/**Converts a screen position to a geographic coordinate.*/
- (CLLocationCoordinate2D)convertPoint:(CGPoint)point;

/**Returns the distance from the screen coordinate to the horizon.*/
- (double)distanceToHorizonFromPoint:(CGPoint)point;

/**Helpfer funciton to convert an MELocationCoordinate2D into a CGPoint.*/
- (CGPoint)convertMECoordinate:(MELocationCoordinate2D)coordinate;

- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animationDuration:(CGFloat) animationDuration;

@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, assign) MELocation location;
@property (nonatomic, readonly) double altitude;

- (void)setLocation:(MELocation) location animationDuration:(CGFloat)animationDuration;
- (void)lookAtCoordinate:(CLLocationCoordinate2D) coordinate1 andCoordinate:(CLLocationCoordinate2D) coordinate2 withHorizontalBuffer:(double)horizontalBufferInPoints withVerticalBuffer:(double)verticalBufferInPoints animationDuration:(CGFloat) animationDuration;

- (MELocation) locationThatFitsBounds:(MELocationBounds) bounds withHorizontalBuffer:(double)horizontalBufferInPoints withVerticalBuffer:(double)verticalBufferInPoints;
- (MELocation) locationThatFitsPoints:(NSArray*) points withHorizontalBuffer:(double)horizontalBufferInPoints withVerticalBuffer:(double)verticalBufferInPoints;

- (CLLocationCoordinate2D) decodeCoordinate:(NSValue*) valueWrappedCoordinate;
- (NSValue*) encodeCoordinate:(CLLocationCoordinate2D) clLocation;
- (void) setCameraOrientation:(CGFloat) heading
						 roll:(CGFloat) roll
						pitch:(CGFloat) pitch
			animationDuration:(CGFloat) animationDuration;

/**For 3D mode, sets the camera's altitude in meters above sea level.*/
- (void) setCameraAltitude:(CGFloat) altitude
		 animationDuration:(CGFloat) animationDuration;


- (void) zoomIn;
- (void) zoomOut;
- (double) pointValueToPixelValue:(CGFloat)pointValue;
- (IBAction) panGestureHandler:(UIGestureRecognizer *)sender;
- (IBAction) pinchGestureHandler:(UIGestureRecognizer *)sender;
- (IBAction) tapGestureHandler:(UIGestureRecognizer *)sender;
- (IBAction) tapZoomInGestureHandler:(UIGestureRecognizer *)sender;
- (IBAction) tapZoomOutGestureHandler:(UIGestureRecognizer *)sender;

// force tap gesture handler
- (void) tapGestureAtPoint:(CGPoint)point;

-(void) addSubscriber:(MEMapView*) subscriber;
-(void) clearSubscribers;

@end
