//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import "MEMarkerHitTest.h"
#import "../METestConsts.h"


//////////////////////////////////////////////////////////////
@implementation MEMarkerHitTest

- (id) init
{
	if(self = [super init])
	{
		self.name = @"Marker Hit Test";
	}
	return self;
}

- (void) dealloc
{
	self.map1Name = nil;
	self.map2Name = nil;
	[super dealloc];
}

- (void) start
{
	if(self.isRunning)
		return;
	
	//Add first marker map with zorder of 50
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.zOrder = 50;
	mapInfo.mapType = kMapTypeDynamicMarker;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.compressTextures = NO;
	mapInfo.hitTestingEnabled = YES;
	
	self.map1Name = [NSString stringWithFormat:@"%@_Zorder_%d",
						  self.name,
						  mapInfo.zOrder];	
	mapInfo.name = self.map1Name;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];

	//Add second marker map with zorder of 51
	mapInfo.zOrder = 51;
	mapInfo.hitTestingEnabled = YES;
	self.map2Name = [NSString stringWithFormat:@"%@_Zorder_%d",
						  self.name,
						  mapInfo.zOrder];
	mapInfo.name = self.map2Name;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	//Add same marker to each map
	MEMarkerAnnotation* marker = [[[MEMarkerAnnotation alloc]init]autorelease];
	marker.coordinate = RDU_COORD;
	marker.metaData = @"RDU_Marker1";
	marker.weight = 0;
	[self.meMapViewController addMarkerToMap:self.map1Name
									  markerAnnotation:marker];
	
	marker.coordinate = CLLocationCoordinate2DMake(RDU_COORD.latitude+2.0, RDU_COORD.longitude+4.0);
	marker.metaData = @"RDU_Marker2";
	[self.meMapViewController addMarkerToMap:self.map2Name
									  markerAnnotation:marker];
	
	self.isRunning = YES;
}

-(void) mapView:(MEMapView *)mapView updateMarkerInfo:(MEMarkerInfo *)markerInfo mapName:(NSString *)mapName
{
	markerInfo.uiImage = [UIImage imageNamed:@"quotebubble"];
	markerInfo.anchorPoint = CGPointMake(43,279);
}



- (void) tapOnMarker:(MEMarkerInfo *)markerInfo
		   onMapView:(MEMapView *)mapView
			 mapName:(NSString *)mapName
	   atScreenPoint:(CGPoint)screenPoint
	   atMarkerPoint:(CGPoint)markerPoint
{
	NSLog(@"Marker %@ on map %@ was tapped at marker point %f,%f",
		  markerInfo.metaData,
		  mapName,
		  markerPoint.x,
		  markerPoint.y);
}

- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeMap:self.map1Name clearCache:YES];
	[self.meMapViewController removeMap:self.map2Name clearCache:YES];
	
	self.isRunning = NO;
}
@end


//////////////////////////////////////////////////////////////
@implementation MEMarkerHitTestSize

- (id) init
{
	if(self = [super init])
	{
		self.name = @"Marker Hit Test Sizing";
	}
	return self;
}

- (void) start
{
	if(self.isRunning)
		return;
	
	//Add first marker map with zorder of 50
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.zOrder = 50;
	mapInfo.mapType = kMapTypeDynamicMarker;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.compressTextures = NO;
	mapInfo.hitTestingEnabled = YES;
	mapInfo.name = self.name;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	//Add same marker to each map
	MEMarkerAnnotation* marker = [[[MEMarkerAnnotation alloc]init]autorelease];
	marker.coordinate = RDU_COORD;
	marker.metaData = @"RDU_Marker1";
	marker.weight = 0;
	[self.meMapViewController addMarkerToMap:self.name
							markerAnnotation:marker];
	
	
	
	self.isRunning = YES;
}


- (void) stop
{
	if(!self.isRunning)
		return;
	[self.meMapViewController removeMap:self.name clearCache:NO];
	self.isRunning = NO;
}

-(void) mapView:(MEMapView *)mapView updateMarkerInfo:(MEMarkerInfo *)markerInfo mapName:(NSString *)mapName
{
	markerInfo.uiImage = [UIImage imageNamed:@"pinRed"];
	markerInfo.anchorPoint = CGPointMake(7,35);
	markerInfo.hitTestSize = CGSizeMake(200,200);
	markerInfo.nearestNeighborTextureSampling = YES;
}

- (void) tapOnMarker:(MEMarkerInfo *)markerInfo
		   onMapView:(MEMapView *)mapView
			 mapName:(NSString *)mapName
	   atScreenPoint:(CGPoint)screenPoint
	   atMarkerPoint:(CGPoint)markerPoint
{
	NSLog(@"Marker %@ on map %@ was tapped at marker point %f,%f",
		  markerInfo.metaData,
		  mapName,
		  markerPoint.x,
		  markerPoint.y);
}

@end

