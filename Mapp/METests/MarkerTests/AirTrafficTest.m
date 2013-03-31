//  Copyright (c) 2013 BA3, LLC. All rights reserved.

#import "AirTrafficTest.h"
#import "JSONKit.h"
#import "../TileProviderTests/MEFileDownloader.h"

@implementation AirPlane

- (id) init
{
	if(self=[super init])
	{
		self.visible = YES;
	}
	return self;
}

- (void) dealloc
{
	[_metaData release];
	[super dealloc];
}

@end

@implementation AirTrafficTest

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Air Traffic";
		self.interval = 10;
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
	[self timerTick];
	
}

- (void) stop
{
	if(!self.isRunning)
		return;
	self.isRunning=NO;
	[self stopTimer];
	[self.meMapViewController removeMap:self.name clearCache:YES];
	[self.airPlanes removeAllObjects];
	self.airPlanes = nil;
}


/*Download data from flightradar, parse it, store the flight data in self.airTrafficMarkers.*/
- (void) downloadAndParseFlights
{
	NSData* rawData = [MEFileDownloader downloadSync:@"http://db8.flightradar24.com/zones/na_c_all.js"];
	if(!self.isRunning)
		return;
	
	if(rawData!=nil)
	{
		NSRange range = NSMakeRange(12, [rawData length] - 14);
		NSData *trafficData = [rawData subdataWithRange:range];
		NSDictionary* planeDictionary = [trafficData objectFromJSONData];
		
		
		if(self.airPlanes==nil)
			self.airPlanes = [[[NSMutableDictionary alloc]init]autorelease];
		
		for(NSString* aKey in [planeDictionary allKeys])
		{
			if([aKey isEqualToString:@"full_count"])
				continue;
			
			if([aKey isEqualToString:@"version"])
				continue;
			
			//Get plane data from parsed JSON
			NSArray* planeData = [planeDictionary objectForKey:aKey];
			
			//See if we already have the airplane in our dictionary,
			//if not, create and add it.
			AirPlane* airPlane = [self.airPlanes objectForKey:aKey];
			if(airPlane==nil)
			{
				airPlane = [[[AirPlane alloc]init]autorelease];
				airPlane.metaData = aKey;
				airPlane.updated = YES;
				[self.airPlanes setObject:airPlane forKey:aKey];
			}
			
			//This code is to list all the JSON object elements
			/*
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
			 }
			*/
			
			NSNumber* lat = (NSNumber*)[planeData objectAtIndex:1];
			NSNumber* lon = (NSNumber*)[planeData objectAtIndex:2];
			NSNumber* hdg = (NSNumber*)[planeData objectAtIndex:3];
			NSNumber* alt = (NSNumber*)[planeData objectAtIndex:4];
			NSNumber* spd = (NSNumber*)[planeData objectAtIndex:5];
			NSString* type = (NSString*)[planeData objectAtIndex:8];
			NSNumber* timeStamp = (NSNumber*)[planeData objectAtIndex:10];
			NSString* carrierAndFlight = (NSString*)[planeData objectAtIndex:16];
			
			
			//Update the airplane?
			if(timeStamp.doubleValue!=airPlane.timeStamp)
			{
				airPlane.timeStamp = timeStamp.doubleValue;
				airPlane.altitude = alt.doubleValue;
				airPlane.speed = spd.doubleValue;
				airPlane.location = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
				airPlane.heading = hdg.doubleValue;
				airPlane.updated = YES;
				airPlane.staleCount = 0;
				airPlane.carrierAndFlight = carrierAndFlight;
				airPlane.airplaneType = type;
				airPlane.updated = YES;
			}
			else
			{
				airPlane.staleCount++;
			}
			
		}
		
	}
}

/*Adds a dynamic marker map with all the air traffic markers. Only called once, when map is first added.*/
- (void) addMap
{
	MEMarkerMapInfo* mapInfo=[[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.mapType = kMapTypeDynamicMarkerFast;
	mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingPrecached;
	NSMutableArray* fastMarkers = [[[NSMutableArray alloc]init]autorelease];
	for( NSString *aKey in [self.airPlanes allKeys] )
	{
		AirPlane* airPlane = [self.airPlanes objectForKey:aKey];
		airPlane.addedToMap = YES;
		MEFastMarkerInfo* fastMarker = [[[MEFastMarkerInfo alloc]init]autorelease];
		fastMarker.metaData = airPlane.metaData;
		fastMarker.location = airPlane.location;
		fastMarker.cachedImageName = @"blueplane";
		fastMarker.rotation = airPlane.heading;
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
	if(!self.isRunning)
		return;
	
	for( NSString *aKey in [self.airPlanes allKeys] )
	{
		AirPlane* airPlane = [self.airPlanes objectForKey:aKey];
		
		//If airplane was update by last download, then
		//update the absolute position of the airplane on the map
		if(airPlane.addedToMap && airPlane.updated && airPlane.visible)
		{
			[self.meMapViewController updateMarkerInMap:self.name
											   metaData:airPlane.metaData
											newLocation:airPlane.location
											newRotation:airPlane.heading
									  animationDuration:0];
			airPlane.updated = NO;
		}
		
		//If the plan has never been added to the map, add it.
		if(!airPlane.addedToMap)
		{
			MEMarkerAnnotation* markerAnnotation = [[[MEMarkerAnnotation alloc]init]autorelease];
			markerAnnotation.metaData = airPlane.metaData;
			markerAnnotation.coordinate = airPlane.location;
			[self.meMapViewController addMarkerToMap:self.name
									markerAnnotation:markerAnnotation];
			airPlane.addedToMap = YES;
			airPlane.updated = NO;
		}
		else if(airPlane.speed<=100 || airPlane.altitude<=1500 || airPlane.staleCount >=3)
		{
			airPlane.visible = NO;
			[self.meMapViewController hideMarkerInMap:self.name metaData:airPlane.metaData];
		}
		else
		{
			//Update heading
			[self.meMapViewController updateMarkerRotationInMap:self.name
													   metaData:airPlane.metaData
													newRotation:airPlane.heading];
			
			//Compute where the plane should be over the next interval
			double distanceTravelled = (airPlane.speed * (self.interval-1.0)) / 3600.0;
			
			CGPoint newLocation = [MEMath pointOnRadial:CGPointMake(airPlane.location.longitude,
																	airPlane.location.latitude)
												 radial:airPlane.heading
											   distance:distanceTravelled];
			airPlane.location = CLLocationCoordinate2DMake(newLocation.y, newLocation.x);
			
			//Animate the airplane to where it should be
			[self.meMapViewController updateMarkerInMap:self.name
											   metaData:airPlane.metaData
											newLocation:airPlane.location
											newRotation:airPlane.heading
									  animationDuration:self.interval];
		}
		
		
		
		
	}
	[self startTimer];
}

- (void) mapView:(MEMapView *)mapView
updateMarkerInfo:(MEMarkerInfo *)markerInfo
		 mapName:(NSString *)mapName
{
	AirPlane* airPlane = [self.airPlanes objectForKey:markerInfo.metaData];
	if(airPlane!=nil)
	{
		markerInfo.cachedImageName = @"blueplane";
		markerInfo.anchorPoint = self.bluePlaneAnchorPoint;
		markerInfo.rotation = airPlane.heading;
		markerInfo.rotationType = kMarkerRotationTrueNorthAligned;
	}
}

- (void) draw
{
	if(![self.meMapViewController containsMap:self.name])
		[self addMap];
	
	[self updateMap];
}

- (void) update
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		//Download data in the background
		[self downloadAndParseFlights];
		
		//Kick off update in the forground
		dispatch_async(dispatch_get_main_queue(), ^{
			[self draw];
		});
		
	});
}

- (void) timerTick
{
	[self stopTimer];
	[self update];
}

@end
