//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import "MEMarkerFastLoad.h"
#import "../METestCategory.h"
#import "MarkerTestData.h"

@implementation MEMarkerSynchronousLoad

- (id) init
{
	if(self = [super init])
	{
		self.name = @"Marker Synchronous Load Dynamic";
		self.markerImageLoadingStrategy = kMarkerImageLoadingSynchronous;
	}
	return self;
}

- (void) start
{
	[self.meTestCategory stopAllTests];
	
	self.isRunning = YES;
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeDynamicMarker;
	mapInfo.markerImageLoadingStrategy = self.markerImageLoadingStrategy;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.compressTextures = NO;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	MEMarkerAnnotation* marker =[[[MEMarkerAnnotation alloc]init]autorelease];
	marker.weight = 0;

	for(float x = -78.782509; x>-120; x-=5)
	{
		marker.coordinate = CLLocationCoordinate2DMake( 35.730439,x);
		marker.metaData = [NSString stringWithFormat:@"%f",x];
		[self.meMapViewController addMarkerToMap:self.name
								markerAnnotation:marker];
	}
	

}

- (void) stop
{
	[self.meMapViewController removeMap:self.name clearCache:YES];
	self.isRunning = NO;
}

- (void) mapView:(MEMapView *)mapView
updateMarkerInfo:(MEMarkerInfo *)markerInfo
		 mapName:(NSString *)mapName
{
	markerInfo.uiImage = [UIImage imageNamed:@"quotebubble"];
	markerInfo.anchorPoint = CGPointMake(43,279);
}

@end

//////////////////////////////////////////////////////////////
@implementation MEMarkerAsynchronousLoad

- (id) init
{
	if(self = [super init])
	{
		self.name = @"Marker Asynchronous Load Dynamic";
		self.markerImageLoadingStrategy = kMarkerImageLoadingAsynchronous;
	}
	return self;
}

@end


//////////////////////////////////////////////////////////////
@implementation MEMarkersFastPath

- (id) init
{
	if(self = [super init])
	{
		self.name = @"Fast Path - Not Clustered";
		self.markerWeight = 0;
		self.clusterDistance = 0;
		self.maxLevel = 20;
	}
	return self;
}

-(NSMutableArray*) createMarkers
{
	NSMutableArray* markers = [[[NSMutableArray alloc]init]autorelease];
	float density = 0.75;
	int count=0;
	for (float x = -122.0; x< -74.0; x+=density)
		for(float y = 25; y< 50; y+=density)
		{
			MEFastMarkerInfo* fastMarker = [[MEFastMarkerInfo alloc]init];
			fastMarker.cachedImageName=@"pinRed";
			fastMarker.location = CLLocationCoordinate2DMake(y,x);
			fastMarker.metaData = [NSString stringWithFormat:@"%f %f",x,y];
			fastMarker.weight = self.markerWeight;
			fastMarker.anchorPoint=CGPointMake(7,35);
			[markers addObject:fastMarker];
			[fastMarker release];
			count++;
		}
	return markers;
}

- (void) addMap
{
	//Cache the red-pin image.
	[self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"pinRed"]
										  withName:@"pinRed"
								   compressTexture:YES
					nearestNeighborTextureSampling:NO];
	
	
	
	//Add marker map as a fast memory marker map
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeMemoryMarkerFast;
	mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingPrecached;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.markers = [self createMarkers];
	mapInfo.zOrder = 20;
	mapInfo.clusterDistance = self.clusterDistance;
	mapInfo.maxLevel = self.maxLevel;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	NSLog(@"Added %d markers.", mapInfo.markers.count);
	
}

- (void) start
{
	if(self.isRunning)
		return;
	[self addMap];
	self.isRunning = YES;
}

- (void) stop
{
	if(!self.isRunning)
		return;
	[self.meMapViewController removeMap:self.name clearCache:YES];
	self.isRunning = NO;
}


@end

//////////////////////////////////////////////////////////////
@implementation MEMarkersFastPathClustered

- (id) init
{
	if(self = [super init])
	{
		self.name = @"Fast Path - Clustered";
		self.markerWeight = 10;
		self.clusterDistance = 30;
	}
	return self;
}

@end
