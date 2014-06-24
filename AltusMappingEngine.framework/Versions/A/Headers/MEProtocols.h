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

/**Called when the user taps on a map.*/
- (void) mapView:(MEMapView *)mapView singleTapAt:(CGPoint) screenPoint withLocationCoordinate:(CLLocationCoordinate2D) locationCoordinate;

/**Called when the engine begins loading data for a map.*/
- (void) mapView:(MEMapView *)mapView willStartLoadingMap:(NSString*) mapName;

/**Called when the engine has finished loading map data -OR- all tile requests have been submitted to tile providers for virtual maps.*/
- (void) mapView:(MEMapView *)mapView didFinishLoadingMap:(NSString*) mapName;

/**For animated maps, called when the animation transitions to a paused state.*/
- (void) mapView:(MEMapView *)mapView animationPausedOnMap:(NSString*) mapName;

/**For animated maps, called between the paused and playing states when the engine is waiting on full frame sets from the tile provider. This special state can only be entered when the map is paused, play is called, and the necessary tiles are not in the cache.*/
- (void) mapView:(MEMapView *)mapView animationWaitingOnMap:(NSString*) mapName;

/**For animated maps, called when the engine has started cycling through animation frames.*/
- (void) mapView:(MEMapView *)mapView animationPlayingOnMap:(NSString*) mapName;

/**For animated maps, called when a frame change occurs.*/
- (void) mapView:(MEMapView *)mapView animationFrameChangedOnMap:(NSString*) mapName withFrame:(int)frame;

/**Called when the user has started panning the view.*/
- (void) panBegan:(MEMapView *) mapView;

/**Called when the panning is completed.*/
- (void) panEnded:(MEMapView *) mapView;

/**Called when a pinch operation starts.*/
- (void) pinchBegan:(MEMapView *) mapView;

/**Called when a pinch operation ends.*/
- (void) pinchEnded:(MEMapView *) mapView;

/**Called to determine if the engine should receive the given gesture.*/
- (BOOL) meGestureRecognizer : (UIGestureRecognizer *) gestureRecognizer shouldReceiveTouch : (UITouch *) touch;

/**Called to determine if the given gesture recognizer should begin.*/
- (BOOL) meGestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;

@end


@class MEMarker;

/**
 The MEMarkerMapDelegate protocol defines a set of methods that you can use to receive marker map related update messages. Implement this protocol when you add marker maps.
 */
@protocol MEMarkerMapDelegate<NSObject>

@optional
/**
 Called when the mapping engine needs information for a marker in a marker layer. When called, you should populate the provided MEMarkerInfo object. The engine will release the object, so you don't need to.
 @param mapView the MEMapView object that owns the marker.
 @param markerInfo Object for you to populate that describes the marker.
 @param mapName The name of the map.
 */
- (void) mapView:(MEMapView*)mapView
    updateMarker:(MEMarker*) marker
		 mapName:(NSString*) mapName;

/**
 Called when a marker is tapped on.
 */
- (void) tapOnMarker:(NSString*)metaData
		   onMapView:(MEMapView*)mapView
	   atScreenPoint:(CGPoint)point;

/**
 Called when a marker is tapped on.
 @param markerInfo Information about the marker that was tapped.
 @param mapView The MEMapView on which the tap occurred.
 @param mapName The name of the map.
 @param screenPoint The point on the screen on where the tap occurred.
 @param markerPoint The relative point within the marker where the tap occurred. Useful for markers that have button UI on them.
 */
- (void) tapOnMarker:(MEMarker*) markerInfo
		   onMapView:(MEMapView*) mapView
			 mapName:(NSString*) mapName
	   atScreenPoint:(CGPoint)screenPoint
	   atMarkerPoint:(CGPoint) markerPoint;

@end

/**
 The MEDynamicMarkerMapDelegate protocol defines a set of methods that you can use to receive dynamic marker map related update messages. Implement this protocol when you add dynamic marker maps.
 */
@protocol MEDynamicMarkerMapDelegate<NSObject>

@optional

/**
 Called when a dynamic marker is tapped on.
 @param markerName The unique name of the marker within the dynamic marker layer.
 @param mapView The MEMapView on which the tap occurred.
 @param mapName The name of the map.
 @param screenPoint The point on the screen on where the tap occurred.
 @param markerPoint The relative point within the marker where the tap occurred. Useful for markers that have button UI on them.
 */
- (void) tapOnDynamicMarker:(NSString*) markerName
				  onMapView:(MEMapView*) mapView
					mapName:(NSString*) mapName
			  atScreenPoint:(CGPoint) screenPoint
			  atMarkerPoint:(CGPoint) markerPoint;

@end

/**The MEVectorMapDelegate protocol defines a set of methods that you can use to receive vector map related update messages. Implement this protocol when you add dynamic vector maps and you need to receive vector map related notifications*/
@protocol MEVectorMapDelegate <NSObject>

@optional

/** Returns the number of pixels used as a buffer between vector line segments and hit test points.*/
- (double) lineSegmentHitTestPixelBufferDistance;

/** Returns the number of pixels used as a buffer between vector line vertices and hit test points.*/
- (double) vertexHitTestPixelBufferDistance;

/**Called when a hit (tap) is detected on a vector line segment.*/
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

/**Called whan a hit (tap) is detected on a polygon in a vector map layer that has enabled polygon hit testing.
 @param mapView The MEMapView object where the hit originated.
 @param An array of one or more MEVectorGeometryHit objects.*/
- (void) polygonHitDetected:(MEMapView*) mapView
                       hits:(NSArray*)polygonHits;


@end
