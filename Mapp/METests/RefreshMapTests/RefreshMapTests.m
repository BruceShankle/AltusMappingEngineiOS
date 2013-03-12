
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "RefreshMapTests.h"

//Tests adding an in-marker map and then changing all of its markers
@implementation RefreshMemoryMarkerMapTest

-(id) init
{
	if(self = [super init])
	{
		self.name = @"Map Refresh - Markers In Memory";
		self.useRedMarker = YES;
	}
	return self;
}

- (void) start
{
	self.interval = 3.0;
	
	const double US_NORTHMOST = 49.0 + 23.0/60.0 + 4.1/3600.0;	//Lake Woods, Minnesoa
	const double US_SOUTHMOST = 24.0 + 31.0/60.0 + 15.0/3600.0;	//Ballast Key, Florida
	const double US_EASTMOST = -66.0 - 56.0 / 60.0 - 59.2/3600.0;	//West Quoddy Head, Maine
	const double US_WESTMOST = -124.0 - 46.0 / 60.0 - 18.1/3600.0; //Cape Alava, Washington
	
	NSMutableArray* markerArray = [[[NSMutableArray alloc]init]autorelease];
	
	int markerid = 1;
	for(float x = US_WESTMOST; x<US_EASTMOST; x++)
		for(float y = US_SOUTHMOST; y<US_NORTHMOST; y++)
		{
			MEMarkerAnnotation* marker = [[[MEMarkerAnnotation alloc]init]autorelease];
			marker.coordinate = CLLocationCoordinate2DMake(y,x);
			marker.metaData = [NSString stringWithFormat:@"%d", markerid];
			markerid++;
			marker.weight = 10;
			[markerArray addObject:marker];
		}
	
	NSLog(@"Adding %d markers", markerArray.count);
	
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.mapType = kMapTypeMemoryMarker;
	mapInfo.clusterDistance = 40;
	mapInfo.name = self.name;
	mapInfo.zOrder = 100;
	mapInfo.markers = markerArray;
	mapInfo.maxLevel = 10;
	mapInfo.meMarkerMapDelegate = self;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	//start timer
	[super start];
	
	self.isRunning = YES;
}

// Implement MEMarkerMapDelegate methods
- (void) mapView:(MEMapView *)mapView
updateMarkerInfo:(MEMarkerInfo *)markerInfo
		 mapName:(NSString *)mapName
{
	int markerid = [markerInfo.metaData intValue];
	NSString* imageName;
	if(self.useRedMarker)
	{
		if(markerid % 2 == 0)
			imageName = @"pinRed";
		else
			imageName = @"pinGreen";
	}
	else
	{
		if(markerid % 2 == 0)
			imageName = @"pinGreen";
		else
			imageName = @"pinRed";
	}
    //Return the image
	markerInfo.uiImage = [UIImage imageNamed:imageName];
	markerInfo.anchorPoint = CGPointMake(7,35);
}


- (void) timerTick
{
	self.useRedMarker = !self.useRedMarker;
	if(self.useRedMarker)
		NSLog(@"Use red marker.");
	else
		NSLog(@"Use green marker.");
	
	[self.meMapViewController refreshMap:self.name];
	
}

- (void) stop
{
	[self.meMapViewController removeMap:self.name clearCache:NO];
	[super stop];
	
	self.isRunning = NO;

}

- (void) userTapped
{
	if(!self.isRunning)
		[self start];
	else
		[self stop];
}



@end
