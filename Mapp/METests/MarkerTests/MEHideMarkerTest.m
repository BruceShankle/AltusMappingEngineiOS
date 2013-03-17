//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import "MEHideMarkerTest.h"
#import "MarkerTestData.h"
#import "../METestCategory.h"


//////////////////////////////////////////////////
@implementation MEHideMarkerTest

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Tap-To-Hide Markers";
		self.airportMarkerIndex = 1;
	}
	return self;
}

- (void) dealloc
{
	self.airportMarkers = nil;
	[super dealloc];
}

- (void) addMap
{
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeMemoryMarker;
	mapInfo.markers = self.airportMarkers;
	mapInfo.clusterDistance = 60;
	mapInfo.maxLevel = 12;
	mapInfo.zOrder = 21;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingAsynchronous;
	mapInfo.hitTestingEnabled = YES;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

- (void) start
{
	if(self.isRunning)
		return;
	
	self.airportMarkers = [MarkerTestData loadAirportMarkers];
	[self.meTestCategory stopAllTests];
	
	[self addMap];
	[self lookAtUnitedStates];
	
	self.isRunning = YES;
	
}


- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeMap:self.name clearCache:YES];
}


-(void) tapOnMarker:(MEMarkerInfo *)markerInfo onMapView:(MEMapView *)mapView mapName:(NSString *)mapName atScreenPoint:(CGPoint)screenPoint atMarkerPoint:(CGPoint)markerPoint
{
	[self.meMapViewController hideMarkerInMap:mapName metaData:markerInfo.metaData];
}

- (void) mapView:(MEMapView *)mapView
updateMarkerInfo:(MEMarkerInfo *)markerInfo
		 mapName:(NSString *)mapName
{
    //Return the image
	markerInfo.uiImage = [UIImage imageNamed:@"pinRed"];
	markerInfo.anchorPoint = CGPointMake(7,35);
}

@end

//////////////////////////////////////////////////
@implementation MERemoveMarkerTest

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Tap-To-Remove Markers";
	}
	return self;
}

- (void) start
{
	[self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"pinRed"] withName:@"pinRed" compressTexture:NO nearestNeighborTextureSampling:NO];
	if(self.isRunning)
		return;
	
	self.airportMarkers = [MarkerTestData loadAirportMarkers];
	[self.meTestCategory stopAllTests];

	//Load subset of markers
	if(!self.markerSubset)
	{
		self.markerSubset = [[[NSMutableArray alloc]init]autorelease];
		
		for(int i=0; i<self.airportMarkers.count; i+=100)
		{
			if(i<self.airportMarkers.count-1)
				[self.markerSubset addObject:[self.airportMarkers objectAtIndex:i]];
		}
	}
	
	[self addMap];
	
	self.interval = 0.5;
	self.markerIndex = 0;
	[self startTimer];
	
}


- (void) stop
{
	[super stop];
	[self stopTimer];
}

- (void) timerTick
{
	self.markerIndex++;
	if(self.markerIndex==self.markerSubset.count)
		self.markerIndex=0;
	MEMarkerAnnotation* markerAnnotation=[self.markerSubset objectAtIndex:self.markerIndex];
	
	//Add the current marker
	[self.meMapViewController addMarkerToMap:self.name markerAnnotation:markerAnnotation];
	
	//Remove the last one
	if(self.markerIndex>0)
	{
		markerAnnotation=[self.markerSubset objectAtIndex:self.markerIndex-1];
		[self.meMapViewController removeMarkerFromMap:self.name markerMetaData:markerAnnotation.metaData];
		
	}
}

- (void) addMap
{
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeDynamicMarker;
	//mapInfo.markers = self.markerSubset;
	mapInfo.clusterDistance = 0;
	mapInfo.maxLevel = 12;
	mapInfo.zOrder = 21;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingSynchronous;
	mapInfo.hitTestingEnabled = YES;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

-(void) tapOnMarker:(MEMarkerInfo *)markerInfo onMapView:(MEMapView *)mapView mapName:(NSString *)mapName atScreenPoint:(CGPoint)screenPoint atMarkerPoint:(CGPoint)markerPoint
{
	[self.meMapViewController removeMarkerFromMap:mapName markerMetaData:markerInfo.metaData];
}

- (void) mapView:(MEMapView *)mapView
updateMarkerInfo:(MEMarkerInfo *)markerInfo
		 mapName:(NSString *)mapName
{
	markerInfo.cachedImageName=@"pinRed";
	markerInfo.anchorPoint = CGPointMake(7,35);
}

@end
