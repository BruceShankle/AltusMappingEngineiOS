//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MEMarkerDatabaseCacheTest.h"
#import "MarkerTestData.h"
#import "MEMarkerTests.h"

@implementation MEMarkerDatabaseCacheTest

- (id) init
{
	if(self=[super init])
	{
		self.name = @"DB Cache Test";
		MEAirportMarkersToDiskCache* t = [[[MEAirportMarkersToDiskCache alloc]init]autorelease];
		self.airportMarkers = [t airportMarkers];
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
	
	self.tickCount = -1;
	self.interval = 2;
	
	[super start];
}

- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeMap:self.name clearCache:YES];
	
	[super stop];
}

- (void)mapView:(MEMapView *)mapView updateMarkerInfo:(MEMarkerInfo *)markerInfo mapName:(NSString *)mapName
{
	if(self.tickCount < 1)
		markerInfo.uiImage = [UIImage imageNamed:@"pinRed"];
	else
		markerInfo.uiImage = [UIImage imageNamed:@"pinGreen"];
	
	markerInfo.anchorPoint = CGPointMake(7,35);
}

- (void) deleteDatabase
{
	//Delete the old database
	[[NSFileManager defaultManager] removeItemAtPath:[MarkerTestData airportMarkerCachePath] error:nil];
	
}

- (void) createAndAddMarkerMap:(int) startIndex endIndex:(int) endIndex
{
	//Get a subset of the markers
	NSMutableArray* markers = [NSMutableArray array];
	for(int i=startIndex; i<endIndex; i++)
		[markers addObject:[self.airportMarkers objectAtIndex:i]];
	
	//Add the marker map	
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeFileMarkerCreate;
	mapInfo.sqliteFileName = [MarkerTestData airportMarkerCachePath];
	mapInfo.zOrder = 20;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.markers = markers;
	mapInfo.clusterDistance = 80;
	mapInfo.maxLevel = 12;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
    self.isRunning = YES;
}

- (void) timerTick
{
	self.tickCount++;
	
	switch(self.tickCount)
	{
		case 0:
			[self.meMapViewController removeMap:self.name clearCache:YES];
			[self createAndAddMarkerMap:0 endIndex:self.airportMarkers.count / 2];
			break;
			
		case 1:
			[self deleteDatabase];
			break;
			
		case 2:
			[self.meMapViewController removeMap:self.name clearCache:YES];
			[self createAndAddMarkerMap:self.airportMarkers.count / 2 endIndex:self.airportMarkers.count - 1];
			break;
			
		case 3:
			[self deleteDatabase];
			
		default:
			self.tickCount = -1;
	}
	
	
}

@end
