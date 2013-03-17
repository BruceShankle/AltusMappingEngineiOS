//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import "METemporalMarkerTests.h"
#import "MarkerTestData.h"
#import "METestCategory.h"

/////////////////////////////////////////////////////////////
//Test A: add 10 markers every 0.5 seconds
@implementation METemporalMarkerTestA

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Temporal Marker Test A";
		self.airportMarkers = [MarkerTestData loadAirportMarkers];
	}
	return self;
}

- (void) dealloc
{
	self.airportMarkers = nil;
	[super dealloc];
}

- (void) start
{
	if(self.isRunning)
		return;
	
	[self.meTestCategory stopAllTests];
	
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeDynamicMarker;
	mapInfo.zOrder = 21;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingSynchronous;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	[self lookAtUnitedStates];

	self.interval = 0.5;
	[super start];
}

- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeMap:self.name clearCache:YES];
	[super stop];
}

- (void) timerTick
{
	for(int i=0; i<10; i++)
	{
		MEMarkerAnnotation* annotation = [self.airportMarkers objectAtIndex:self.airportMarkerIndex];
		[self.meMapViewController addMarkerToMap:self.name markerAnnotation:annotation];
		self.airportMarkerIndex++;
		if(self.airportMarkerIndex==self.airportMarkers.count-1)
		{
			[self.timer invalidate];
			self.timer = nil;
		}
	}
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

/////////////////////////////////////////////////////////////
//Test B: add all markers from an existing db,
//then add 10 new markers every 0.5 second
@implementation METemporalMarkerTestB

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Temporal Marker Test B";
		self.airportMarkers = [MarkerTestData loadAirportMarkers];
		self.airportMarkerIndex = 1;
	}
	return self;
}

- (void) dealloc
{
	self.airportMarkers = nil;
	[super dealloc];
}

- (void) start
{
	if(self.isRunning)
		return;
	
	[self.meTestCategory stopAllTests];
	
	//Get 'half' (every other) airport marker
	NSMutableArray* markerSubset = [[[NSMutableArray alloc]init]autorelease];
	for(int i=1; i<self.airportMarkers.count-2; i+=2)
	{
		[markerSubset addObject:[self.airportMarkers objectAtIndex:i]];
	}
	
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeMemoryMarker;
	mapInfo.markers = markerSubset;
	mapInfo.clusterDistance = 60;
	mapInfo.maxLevel = 12;
	mapInfo.zOrder = 21;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingAsynchronous;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	[self lookAtUnitedStates];
	
	self.interval = 0.5;
	
	[super start];
}


- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeMap:self.name clearCache:YES];
	[super stop];
}

- (void) timerTick
{
	for(int i=0; i<10; i++)
	{
		MEMarkerAnnotation* annotation = [self.airportMarkers objectAtIndex:self.airportMarkerIndex];
		[self.meMapViewController addMarkerToMap:self.name markerAnnotation:annotation];
		self.airportMarkerIndex+=2;
		if(self.airportMarkerIndex==self.airportMarkers.count-1)
		{
			[self.timer invalidate];
			self.timer = nil;
			return;
		}
	}
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


/////////////////////////////////////////////////////////////
//Test C: add all markers from an existing db then
//update 10 existing markers every 0.5 second
@implementation METemporalMarkerTestC

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Temporal Marker Test C";
		self.airportMarkers = [MarkerTestData loadAirportMarkers];
		
		//Initialize the names of images we assign to each marker
		//To start with, all markers will be given a red pin.
		//When they are updated, they will be given a green pin.
		self.markerImageDictionary = [[[NSMutableDictionary alloc]init]autorelease];
		for(MEMarkerAnnotation* annotation in self.airportMarkers)
		{
			[self.markerImageDictionary setObject:@"pinRed" forKey:annotation.metaData];
		}
	}
	return self;
}

- (void) dealloc
{
	self.airportMarkers = nil;
	self.markerImageDictionary = nil;
	[super dealloc];
}

- (void) start
{
	if(self.isRunning)
		return;
	
	[self.meTestCategory stopAllTests];
	
	
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeMemoryMarker;
	mapInfo.markers = self.airportMarkers;
	mapInfo.clusterDistance = 60;
	mapInfo.maxLevel = 12;
	mapInfo.zOrder = 21;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingAsynchronous;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	[self lookAtUnitedStates];
	
	self.interval = 1.5;
	
	[super start];
}


- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeMap:self.name clearCache:YES];
	[super stop];
}

- (void) timerTick
{
	for(int i=0; i<10; i++)
	{
		MEMarkerAnnotation* annotation = [self.airportMarkers objectAtIndex:self.airportMarkerIndex];
		[self.meMapViewController refreshMarkerInMap:self.name metaData:annotation.metaData];
		self.airportMarkerIndex++;
		if(self.airportMarkerIndex==self.airportMarkers.count-1)
		{
			[self.timer invalidate];
			self.timer = nil;
			return;
		}
	}
	
	//TBD: remove this once the API for updating markers works.
	[self.meMapViewController refreshMap:self.name];
}


- (void) mapView:(MEMapView *)mapView
updateMarkerInfo:(MEMarkerInfo *)markerInfo
		 mapName:(NSString *)mapName
{
    //Return the image
	NSString* imageName = [self.markerImageDictionary objectForKey:markerInfo.metaData];
	markerInfo.uiImage = [UIImage imageNamed:imageName];
	markerInfo.anchorPoint = CGPointMake(7,35);
	
	//Swap the image name
	if([imageName isEqualToString:@"pinRed"])
		imageName=@"pinGreen";
	else
		imageName=@"pinRed";
	[self.markerImageDictionary setObject:imageName forKey:markerInfo.metaData];
	
}

@end


/////////////////////////////////////////////////////////////
//Test D: Mix of test B and C
@implementation METemporalMarkerTestD

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Temporal Marker Test D";
		NSMutableArray* allMarkers = [MarkerTestData loadAirportMarkers];
		
		//Split the markers into 2 distributed sets even and odd...
		self.airportMarkersEven = [[[NSMutableArray alloc]init]autorelease];
		self.airportMarkersOdd = [[[NSMutableArray alloc]init]autorelease];
		for(int i=0; i<allMarkers.count; i++)
		{
			if((i%2)==0)
				[self.airportMarkersEven addObject:[allMarkers objectAtIndex:i]];
			else
				[self.airportMarkersOdd addObject:[allMarkers objectAtIndex:i]];
		}
		
		//Initialize the names of images we assign to each marker
		//To start with, all markers will be given a red pin.
		//When they are updated, they will be given a green pin.
		self.markerImageDictionary = [[[NSMutableDictionary alloc]init]autorelease];
		for(MEMarkerAnnotation* annotation in allMarkers)
		{
			[self.markerImageDictionary setObject:@"pinRed" forKey:annotation.metaData];
		}
	}
	return self;
}

- (void) dealloc
{
	self.airportMarkersEven = nil;
	self.airportMarkersOdd = nil;
	self.markerImageDictionary = nil;
	[super dealloc];
}

- (void) start
{
	if(self.isRunning)
		return;
	
	[self.meTestCategory stopAllTests];
	
	//Add all of the odd-numbered markers on start
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeMemoryMarker;
	mapInfo.markers = self.airportMarkersOdd;
	mapInfo.clusterDistance = 60;
	mapInfo.maxLevel = 12;
	mapInfo.zOrder = 21;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingAsynchronous;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	[self lookAtUnitedStates];
	
	self.interval = 1.5;
	
	[super start];
}


- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeMap:self.name clearCache:YES];
	[super stop];
}

- (void) timerTick
{
	//Add 10 markers from the even set.
	for(int i=0; i<10; i++)
	{
		MEMarkerAnnotation* annotation = [self.airportMarkersEven objectAtIndex:self.airportMarkerEvenIndex];
		[self.meMapViewController addMarkerToMap:self.name markerAnnotation:annotation];
		self.airportMarkerEvenIndex++;
		
		//Stop timer at end?
		if(self.airportMarkerEvenIndex==self.airportMarkersEven.count-1)
		{
			[self.timer invalidate];
			self.timer = nil;
			return;
		}
	}
	
	//Update 10 markers from the odd set
	for(int i=0; i<10; i++)
	{
		MEMarkerAnnotation* annotation = [self.airportMarkersOdd objectAtIndex:self.airportMarkerOddIndex];
		[self.meMapViewController refreshMarkerInMap:self.name metaData:annotation.metaData];
		self.airportMarkerOddIndex++;
		
		//Stop timer at end?
		if(self.airportMarkerOddIndex==self.airportMarkersOdd.count-1)
		{
			[self.timer invalidate];
			self.timer = nil;
			return;
		}
	}
	
	//TBD: remove this once the API for updating markers works.
	[self.meMapViewController refreshMap:self.name];
}


- (void) mapView:(MEMapView *)mapView
updateMarkerInfo:(MEMarkerInfo *)markerInfo
		 mapName:(NSString *)mapName
{
    //Return the image
	NSString* imageName = [self.markerImageDictionary objectForKey:markerInfo.metaData];
	markerInfo.uiImage = [UIImage imageNamed:imageName];
	markerInfo.anchorPoint = CGPointMake(7,35);
	
	//Swap the image name
	if([imageName isEqualToString:@"pinRed"])
		imageName=@"pinGreen";
	else
		imageName=@"pinRed";
	[self.markerImageDictionary setObject:imageName forKey:markerInfo.metaData];
	
}



@end

