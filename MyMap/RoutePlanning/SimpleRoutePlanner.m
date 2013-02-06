//
//  SimpleRoutePlanner.m
//  MyMap
//
//  Created by Bruce Shankle III on 2/5/13.
//  Copyright (c) 2013 BA3, LLC. All rights reserved.
//
// Demonstrates how to use a dynamic marker map and dynamic vector map
// with the mapping engine to create a simple route planning system.
//
// * Implement a dynamic vector map layer to which points can be added and removed.
// * Implement a dynamic marker layer that puts a marker at the route end-points and intersections.
// * Implement simple route 'rubber banding' when a long-press event occurs.

#import "SimpleRoutePlanner.h"
#import "../LocationData.h"

@implementation SimpleRoutePlanner

- (id) init
{
	if(self=[super init])
	{
		self.vectorLayerName = @"routeVectors";
		self.markerLayerName = @"routeMarkers";
		self.routePoints = [[[NSMutableArray alloc]init]autorelease];
		self.lineStyle = [[[MELineStyle alloc]init]autorelease];
		self.lineStyle.strokeColor = [UIColor blueColor];
		self.lineStyle.strokeWidth = 5.0;
		self.longPress = [[[UILongPressGestureRecognizer alloc]
						   initWithTarget:self
						   action:@selector(handleLongPress:)]autorelease];
        self.longPress.minimumPressDuration = 2.0;
	}
	return self;
}

- (void) dealloc
{
	self.vectorLayerName = nil;
	self.markerLayerName = nil;
	self.meMapViewController = nil;
	self.routePoints = nil;
	self.lineStyle = nil;
	self.longPress = nil;
	[super dealloc];
}

- (void) addMaps
{
	//Add a dynamic vector map with a 40 nautical mile tesselation threshold
	MEVectorMapInfo* vectorMapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
	vectorMapInfo.meVectorMapDelegate = self;
	vectorMapInfo.zOrder = 100;
	vectorMapInfo.name = self.vectorLayerName;
	[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
	[self.meMapViewController setTesselationThresholdForMap:vectorMapInfo.name withThreshold:40];
	
	//Cache an image for the marker layer and create an anchor-point based on the image dimensions
	UIImage* markerImage = [UIImage imageNamed:@"route_endpoint"];
	self.routeMarkerAnchorPoint = CGPointMake(markerImage.size.width/2, markerImage.size.height/2);
	[self.meMapViewController addCachedImage:markerImage
									withName:@"route_endpoint"
							 compressTexture:NO];
	
}

- (void) removeMaps
{
	[self.meMapViewController removeMap:self.vectorLayerName clearCache:YES];
	[self.meMapViewController removeMap:self.markerLayerName clearCache:YES];
}

- (void) enable
{
	[self addMaps];
	
	[self clearRoute];
	
	//Add two points
	[self addWayPoint:RDU_COORD];
	[self addWayPoint:SFO_COORD];
	
	//Register gesture recognizer
	[self.meMapViewController.meMapView addGestureRecognizer:self.longPress];
}

-(void) addWayPoint:(CLLocationCoordinate2D) wayPoint
{
	[self.routePoints addObject:[NSValue valueWithCGPoint:CGPointMake(wayPoint.longitude, wayPoint.latitude)]];
	if(self.routePoints.count >= 2)
	{
		[self updateRoute];
	}
}

-(void) clearRoute
{
	[self.routePoints removeAllObjects];
	[self updateRoute];
}

- (void) disable
{
	[self removeMaps];
	
	//Unregister the gesture recognizer
    [self.meMapViewController.meMapView removeGestureRecognizer:self.longPress];
}

/**
Add a dynamic marker layer for route end points and intersections.
Here we use a fast dynamic marker map where all marker images
are pre-cached in the mapping engine for fastest possible display.
*/
- (void) updateRouteMarkers
{
	//Remove previous marker layer
	[self.meMapViewController removeMap:self.markerLayerName clearCache:YES];
	
	//Create a marker map object and populate it with relevant settings
	MEMarkerMapInfo* markerMapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	markerMapInfo.mapType = kMapTypeDynamicMarkerFast;
	markerMapInfo.zOrder = 101;
	markerMapInfo.name = self.markerLayerName;
	markerMapInfo.hitTestingEnabled = YES;
	markerMapInfo.meMarkerMapDelegate = self;
	markerMapInfo.markerImageLoadingStrategy = kMarkerImageLoadingPrecached;
	
	//Create an array of MEFastMarkerInfo objects
	//Each marker object must be properly configured
	NSMutableArray* markers = [[[NSMutableArray alloc]init]autorelease];
	for(int i=0; i<self.routePoints.count; i++)
    {
        NSValue* v = (NSValue*)[self.routePoints objectAtIndex:i];
        CGPoint point = [v CGPointValue];
		MEFastMarkerInfo* marker = [[MEFastMarkerInfo alloc]init];
		marker.location = CLLocationCoordinate2DMake(point.y, point.x);
		marker.cachedImageName = @"route_endpoint";
		marker.anchorPoint = self.routeMarkerAnchorPoint;
		marker.nearestNeighborTextureSampling = NO;
		marker.metaData = [NSString stringWithFormat:@"%d", i];
		[markers addObject:marker];
		[marker release];
	}
	
	//Set the array of markers on the map info object
	markerMapInfo.markers = markers;
	
	//Add the marker map
	[self.meMapViewController addMapUsingMapInfo:markerMapInfo];
}

- (void) updateRoute
{
	//Remove any previous line geometry for the route
	[self.meMapViewController clearDynamicGeometryFromMap:self.vectorLayerName];
	
	//Add the vector geometry for the route if there are enough points
	if(self.routePoints.count>=2)
	{
		[self.meMapViewController addDynamicLineToVectorMap:self.vectorLayerName
													 lineId:@"route"
													 points:self.routePoints
													  style:self.lineStyle];
	}
	
	[self updateRouteMarkers];
}

/**
 Called when a marker is tapped on.
 */
- (void) tapOnMarker:(NSString*)metaData
		   onMapView:(MEMapView*)mapView
	   atScreenPoint:(CGPoint)point
{
	NSLog(@"Marker tapped.");
}

/** Handle the long-press gesture recognizer.*/
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
	//Get the view point where the user is touching
    CGPoint viewPoint=[gesture locationInView:self.meMapViewController.meMapView];
    
	//Convert the view point to a coordinate
    CLLocationCoordinate2D coordinate=[self.meMapViewController.meMapView convertPoint:viewPoint];
    
	//If the coordinante is valid update the route
	if(coordinate.longitude!=0 && coordinate.latitude != 0)
	{
		[self clearRoute];
		[self addWayPoint:RDU_COORD];
		[self addWayPoint:coordinate];
		[self addWayPoint:SFO_COORD];
	}
}


/** Required: Returns the number of pixels used as a buffer between vector line segments and hit test points.*/
- (double) lineSegmentHitTestPixelBufferDistance
{
	return 10;
}

/** Required: Returns the number of pixels used as a buffer between vector line vertices and hit test points.*/
- (double) vertexHitTestPixelBufferDistance
{
	return 10;
}

@end
