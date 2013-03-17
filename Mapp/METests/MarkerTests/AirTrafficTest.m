//  Copyright (c) 2013 BA3, LLC. All rights reserved.

#import "AirTrafficTest.h"
#import "JSONKit.h"
#import "../TileProviderTests/MEFileDownloader.h"

@implementation AirTrafficMarker

- (void) dealloc
{
	[_metaData release];
}

@end

@implementation AirTrafficTest

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Air Traffic";
		self.interval = 2;
	}
	return self;
}

- (void) start
{
	if(self.isRunning)
		return;
	self.isRunning=YES;
	
	//Cache the blue plane
	UIImage* bluePlaneImage = [UIImage imageNamed:@"blueplanesmall"];
	self.bluePlaneAnchorPoint = CGPointMake(bluePlaneImage.size.width/2.0, bluePlaneImage.size.height/2.0);
	
	[self.meMapViewController addCachedMarkerImage:bluePlaneImage
										  withName:@"blueplane"
								   compressTexture:NO
					nearestNeighborTextureSampling:NO];
	[self startTimer];

}

- (void) stop
{
	if(!self.isRunning)
		return;
	self.isRunning=NO;
	[self stopTimer];
}


/*Download data from flightradar, parse it, store the flight data in self.airTrafficMarkers.*/
- (void) getData
{
	NSData* rawData = [MEFileDownloader downloadSync:@"http://db8.flightradar24.com/zones/na_c_all.js"];
	if(rawData!=nil)
	{
		NSRange range = NSMakeRange(12, [rawData length] - 14);
		NSData *trafficData = [rawData subdataWithRange:range];
		NSDictionary* planeDictionary = [trafficData objectFromJSONData];
		if(self.airTrafficMarkers==nil)
			self.airTrafficMarkers = [[[NSMutableArray alloc]init]autorelease];
		[self.airTrafficMarkers removeAllObjects];
		for(NSString* aKey in [planeDictionary allKeys])
		{
			if([aKey isEqualToString:@"full_count"])
				continue;
			
			if([aKey isEqualToString:@"version"])
				continue;
			
			NSArray* planeData = [planeDictionary objectForKey:aKey];
			
			/*
			 //This code is to list all the jsob object elements
			NSLog(@"Entry:%@", aKey);
			int i=0;
			for(id item in planeData)
			{
				if([item isKindOfClass:[NSNumber class]])
				{
					NSNumber* number=(NSNumber*)item;
					NSLog(@"Item %d=%f", i, [number doubleValue]);
				}
				
				if([item isKindOfClass:[NSString class]])
				{
					NSLog(@"Item %d=%@", i, item);
				}
				i++;
			}*/
			
			NSNumber* lat = (NSNumber*)[planeData objectAtIndex:1];
			NSNumber* lon = (NSNumber*)[planeData objectAtIndex:2];
			NSNumber* hdg = (NSNumber*)[planeData objectAtIndex:3];
			
			AirTrafficMarker* airTrafficMarker = [[[AirTrafficMarker alloc]init]autorelease];
			airTrafficMarker.metaData = aKey;
			airTrafficMarker.location = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
			airTrafficMarker.heading = hdg.doubleValue;
			[self.airTrafficMarkers addObject:airTrafficMarker];
		}
		
	}
}

/*Adds a dynamic marker map with all the air traffic markers. Only called once, when map is first added.*/
- (void) addMap
{
	MEMarkerMapInfo* mapInfo=[[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeDynamicMarkerFast;
	mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingPrecached;
	NSMutableArray* fastMarkers = [[[NSMutableArray alloc]init]autorelease];
	for(AirTrafficMarker* airTrafficMarker in self.airTrafficMarkers)
	{
		MEFastMarkerInfo* fastMarker = [[[MEFastMarkerInfo alloc]init]autorelease];
		fastMarker.metaData = airTrafficMarker.metaData;
		fastMarker.location = airTrafficMarker.location;
		fastMarker.cachedImageName = @"blueplane";
		fastMarker.rotation = airTrafficMarker.heading;
		fastMarker.rotationType = kMarkerRotationTrueNorthAligned;
		fastMarker.anchorPoint = self.bluePlaneAnchorPoint;
		[fastMarkers addObject:fastMarker];
	}
	mapInfo.markers = fastMarkers;
	mapInfo.zOrder = 100;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

/*Updates markers in the air traffic marker layer.*/
- (void) updateMap
{
	for(AirTrafficMarker* airTrafficMarker in self.airTrafficMarkers)
	{
		[self.meMapViewController updateMarkerInMap:self.name
										   metaData:airTrafficMarker.metaData
										newLocation:airTrafficMarker.location
										newRotation:airTrafficMarker.heading
								  animationDuration:2];
	}
}

- (void) drawData
{
	if(![self.meMapViewController containsMap:self.name])
	{
		[self addMap];
		return;
	}
	[self updateMap];
}

- (void) timerTick
{
	[self stopTimer];
	[self getData];
	[self drawData];
	[self startTimer];
}

@end
