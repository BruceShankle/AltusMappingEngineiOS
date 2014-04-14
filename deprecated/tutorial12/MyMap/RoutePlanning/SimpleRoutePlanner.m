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
	
	//Create a dynamic marker map object and populate it with relevant settings
	MEDynamicMarkerMapInfo* markerMapInfo = [[[MEDynamicMarkerMapInfo alloc]init]autorelease];
	markerMapInfo.zOrder = 101;
	markerMapInfo.name = self.markerLayerName;
	markerMapInfo.hitTestingEnabled = YES;
	markerMapInfo.meDynamicMarkerMapDelegate = self;
	
	//Add the marker map
	[self.meMapViewController addMapUsingMapInfo:markerMapInfo];
	
	//Clear and update the line geometry for the route.
	[self clearRoute];
	[self addWayPoint:SFO_COORD];
	[self addWayPoint:RDU_COORD];
	[self updateRoute];
	
	//Add markers for the route end-points.
	MEDynamicMarker* marker = [[[MEDynamicMarker alloc]init]autorelease];
	
	//SFO
	marker.name=@"SFO";
	marker.location = SFO_COORD;
	marker.uiImage = [UIImage imageNamed:@"route_endpoint"];
	marker.anchorPoint = CGPointMake(marker.uiImage.size.width/2.0, marker.uiImage.size.height/2.0);
	[self.meMapViewController addDynamicMarkerToMap:self.markerLayerName
									  dynamicMarker:marker];
	
	//RDU
	marker.name = @"RDU";
	marker.location = RDU_COORD;
	[self.meMapViewController addDynamicMarkerToMap:self.markerLayerName
									  dynamicMarker:marker];
	
	//Add and hide a marker for where the user will be touching.
	//We'll show and move this one around when the user does a long-press
	marker.name = @"TOUCHPOINT";
	marker.location = RDU_COORD;
	[self.meMapViewController addDynamicMarkerToMap:self.markerLayerName
									  dynamicMarker:marker];
	[self.meMapViewController hideDynamicMarker:self.markerLayerName
									 markerName:@"TOUCHPOINT"];
	
	
	
}

- (void) removeMaps
{
	[self.meMapViewController removeMap:self.vectorLayerName clearCache:YES];
	[self.meMapViewController removeMap:self.markerLayerName clearCache:YES];
}

- (void) enable
{
	[self addMaps];
	
	//Register gesture recognizer
	[self.meMapViewController.meMapView addGestureRecognizer:self.longPress];

}

-(void) addWayPoint:(CLLocationCoordinate2D) wayPoint
{
	[self.routePoints addObject:[NSValue valueWithCGPoint:CGPointMake(wayPoint.longitude, wayPoint.latitude)]];
}

-(void) clearRoute
{
	[self.routePoints removeAllObjects];
}

- (void) disable
{
	[self removeMaps];
	
	//Unregister the gesture recognizer
    [self.meMapViewController.meMapView removeGestureRecognizer:self.longPress];
}


- (void) updateRoute
{
	//Update the dynamic vector map that represents the route lines.
	
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
	
	//Show and move th touch-point marker.
	if(self.routePoints.count>=3)
	{
		[self.meMapViewController showDynamicMarker:self.markerLayerName
										 markerName:@"TOUCHPOINT"];
		[self.meMapViewController updateDynamicMarkerLocation:self.markerLayerName
												   markerName:@"TOUCHPOINT"
													 location:self.touchPointLocation
											animationDuration:0];
	}
}

/**
 Called when a marker is tapped on.
 */
- (void) tapOnDynamicMarker:(NSString *)markerName
				  onMapView:(MEMapView *)mapView
					mapName:(NSString *)mapName
			  atScreenPoint:(CGPoint)screenPoint
			  atMarkerPoint:(CGPoint)markerPoint
{
	NSLog(@"Route marker was tapped on.");
}

/** Handle the long-press gesture recognizer.*/
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
	//Get the view point where the user is touching
    CGPoint viewPoint=[gesture locationInView:self.meMapViewController.meMapView];
    
	//Convert the view point to a coordinate and store it
	self.touchPointLocation = [self.meMapViewController.meMapView convertPoint:viewPoint];
    
	//If the coordinante is valid update the route
	if(self.touchPointLocation.longitude!=0 && self.touchPointLocation.latitude != 0)
	{
		[self clearRoute];
		[self addWayPoint:RDU_COORD];
		[self addWayPoint:self.touchPointLocation];
		[self addWayPoint:SFO_COORD];
		[self updateRoute];
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
