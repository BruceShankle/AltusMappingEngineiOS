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
@property (nonatomic, assign) uint maxTileRenderSize;
@property (nonatomic, assign) double tileLevelBias;
@property (nonatomic, assign) BOOL tileBiasSmoothingEnabled;
@property (nonatomic, assign) double panVelocityScale;
@property (nonatomic, assign) MEMapViewController* meMapViewController;

@property(nonatomic, readonly, retain) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic, readonly, retain) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property(nonatomic, readonly, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property(nonatomic, readonly, retain) UITapGestureRecognizer *tapZoomInGestureRecognizer;
@property(nonatomic, readonly, retain) UITapGestureRecognizer *tapZoomOutGestureRecognizer;

@property (nonatomic, assign, getter = isPanDecelerationEnabled) BOOL isPanDecelerationEnabled;
@property (nonatomic, assign) double panAcceleration;
@property (nonatomic, retain) UIColor* clearColor;

/** Sets the minimum distance in meters from the camera/viewer to the map */
@property (nonatomic, assign) double minimumZoom;
/** Sets the maximum distance in meters from the camera/viewer to the map */
@property (nonatomic, assign) double maximumZoom;

@property (nonatomic, getter=isPanEnabled) BOOL panEnabled;
@property (nonatomic, getter=isZoomEnabled) BOOL zoomEnabled;
@property (nonatomic, readonly) BOOL isRetinaDisplay;

- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate;
- (CLLocationCoordinate2D)convertPoint:(CGPoint)point;
- (double)distanceToHorizonFromPoint:(CGPoint)point;
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
