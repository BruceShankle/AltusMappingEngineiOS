//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#pragma once
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MEGeometry.h"

@class MEMapView;


/////////////////////////////////////////////////////////////////////////////
/**The MEMapViewDelegate protocol defines a set of optional methods that you can use to receive map-related update messages. Because many map operations require the MEMapView class to load data asynchronously, the map view calls these methods to notify your application when specific operations complete. The map view also uses these methods to request annotation information.
 */
@protocol MEMapViewDelegate <NSObject>
@optional

- (void) mapView:(MEMapView *)mapView singleTapAt:(CGPoint) screenPoint withLocationCoordinate:(CLLocationCoordinate2D) locationCoordinate;

- (void) mapView:(MEMapView *)mapView willStartLoadingMap:(NSString*) mapName;
- (void) mapView:(MEMapView *)mapView didFinishLoadingMap:(NSString*) mapName;
- (void) mapView:(MEMapView *)mapView animationFrameChangedOnMap:(NSString*) mapName withFrame:(int)frame;

- (void) panBegan:(MEMapView *) mapView;
- (void) panEnded:(MEMapView *) mapView;
- (void) pinchBegan:(MEMapView *) mapView;
- (void) pinchEnded:(MEMapView *) mapView;

- (BOOL) gestureRecognizer : (UIGestureRecognizer *) gestureRecognizer shouldReceiveTouch : (UITouch *) touch;

/*
 - (void)mapView:(MEMapView *)mapView locationWillChangeAnimated:(BOOL)animated;
 - (void)mapView:(MEMapView *)mapView locationDidChangeAnimated:(BOOL)animated;
 
 - (void)mapViewWillStartLoadingMap:(MEMapView *)mapView mapName:(NSString*) mapName;
 - (void)mapViewDidFinishLoadingMap:(MEMapView *)mapView mapName:(NSString*) mapName;
 */

/*Not implemented yet from RMMapViewDelegate
 - (void) afterMapTouch: (MEMapView*) map;
 - (void) beforeMapMove: (MEMapView*) map;
 - (void) afterMapMove: (MEMapView*) map ;
 - (void) beforeMapZoom: (MEMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center;
 - (void) afterMapZoom: (MEMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center;
 - (void) doubleTapOnMap: (MEMapView*) map At: (CGPoint) point;
 - (void) tapOnMarker: (MEMarker*) marker onMap: (MEMapView*) map;
 - (void) tapOnLabelForMarker: (MEMarker*) marker onMap: (MEMapView*) map;
 - (BOOL) mapView:(MEMapView *)map shouldDragMarker:(MEMarker *)marker withEvent:(UIEvent *)event;
 - (void) mapView:(MEMapView *)map didDragMarker:(MEMarker *)marker withEvent:(UIEvent *)event;
 - (void) dragMarkerPosition: (MEMarker*) marker onMap: (MEMapView*)map position:(CGPoint)position;
 
 */

@end

/*Protocol for objects that need to keep a 2D location in sync with the map view.*/
@protocol MESymbiote <NSObject>

@optional

/**Called by the mapping engine when the map view camera position has changed. If you implement this method, no other methods will be called as it is assumed the object knows it needs to update its screen position.*/
- (void) mapViewCameraDidChange;

/**Called by the mapping engine to get the current geographic coordinate of the object.*/
- (MELocationCoordinate2D) centerCoordinate;

/**Called by the mapping engine when the screen position of the object should change.*/
- (void) updateScreenPosition:(CGPoint) newPosition;

@end


@class MEMarkerInfo;
/**
 The MEMarkerMapDelegate protocol defines a set of methods that you can use to receive marker map related update messages. Implement this protocol when you add marker layers to maps.
 */
@protocol MEMarkerMapDelegate<NSObject>
@required
/**
 Called when the mapping engine needs information for a marker in a marker layer. When called, you should Create and populate an MEMarkerInfo object. The engine will release the object, so you don't need to.
 @param mapView the MEMapView object that owns the marker.
 @param markerInfo
 */
- (void) mapView:(MEMapView*)mapView
            updateMarkerInfo:(MEMarkerInfo*) markerInfo
		 mapName:(NSString*) mapName;

@optional

/**
 Called when a marker is tapped on.
 */
- (void) tapOnMarker:(NSString*)metaData
		   onMapView:(MEMapView*)mapView
	   atScreenPoint:(CGPoint)point;

/**
 Called when a marker is tapped on.
 */
- (void) tapOnMarker:(MEMarkerInfo*) markerInfo
		   onMapView:(MEMapView*) mapView
			 mapName:(NSString*) mapName
	   atScreenPoint:(CGPoint)point;
@end

/**The MEVectorMapDelegate protocol defines a set of methods that you can use to receive vector map related update messages. Implement this protocol when you add dynamic vector maps and you need to receive vector map related notifications*/
@protocol MEVectorMapDelegate <NSObject>

@required

/** Required: Returns the number of pixels used as a buffer between vector line segments and hit test points.*/
- (double) lineSegmentHitTestPixelBufferDistance;

/** Required: Returns the number of pixels used as a buffer between vector line vertices and hit test points.*/
- (double) vertexHitTestPixelBufferDistance;

@optional

/**Called when a hit is dected on a vector line segment.*/
- (void) lineSegmentHitDetected:(MEMapView*) mapView
						mapName:(NSString*) mapName
						shapeId:(NSString*) shapeId
					 coordinate:(CLLocationCoordinate2D) coordinate
			  segmentStartIndex:(int) segmentStartIndex
				segmentEndIndex:(int) segmentEndIndex;

/**Called when a hit is detected on a vector line vertex.*/
- (void) vertexHitDetected:(MEMapView*) mapView
				   mapName:(NSString*) mapName
				   shapeId:(NSString*) shapeId
				coordinate:(CLLocationCoordinate2D) coordinate
			   vertexIndex:(int) vertexIndex;

@end
