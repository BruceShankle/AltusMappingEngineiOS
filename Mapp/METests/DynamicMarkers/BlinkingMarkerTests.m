//  Copyright (c) 2013 BA3, LLC. All rights reserved.

#import "BlinkingMarkerTests.h"
#import "../METestConsts.h"
#import "../METestCategory.h"

@implementation BlinkingMarkerTest

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Blinking Pin UImage/UImage";
		self.interval = 1.0;
		self.flipper = YES;
	}
	return self;
}

- (void) dealloc
{
	self.imageName = nil;
	[super dealloc];
}

- (void) addMarker
{
	MEDynamicMarker* marker = [[[MEDynamicMarker alloc]init]autorelease];
	marker.name = @"pin";
	marker.uiImage = [UIImage imageNamed:@"pinRed"];
	marker.compressTexture = NO;
	marker.location = RDU_COORD;
	marker.anchorPoint = CGPointMake(7,35);
	[self.meMapViewController addDynamicMarkerToMap:self.name dynamicMarker:marker];
	
}

- (void) addMap
{
	MEDynamicMarkerMapInfo* mapInfo = [[[MEDynamicMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.zOrder = 100;
	mapInfo.hitTestingEnabled = YES;
	mapInfo.meDynamicMarkerMapDelegate = self;
	mapInfo.meMapViewController = self.meMapViewController;
	
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
}

- (void) start
{
	if(self.isRunning)
		return;
	
	[self.meTestCategory stopAllTests];
	[self addMap];
	[self addMarker];
	
	[self startTimer];
	
	self.isRunning = YES;
}

- (void) updateMarker
{
	UIImage* pinImage = [UIImage imageNamed:self.imageName];
	[self.meMapViewController updateDynamicMarkerImage:self.name
											markerName:@"pin"
											   uiImage:pinImage
										   anchorPoint:CGPointMake(7,35)
												offset:CGPointMake(0,0)
									   compressTexture:NO];
	

}

- (void) timerTick
{
	self.flipper = !self.flipper;
	if(!self.flipper)
		self.imageName = @"pinGreen";
	else
		self.imageName = @"pinRed";
	[self updateMarker];

}

- (void) stop
{
	if(!self.isRunning)
		return;
	[self stopTimer];
	[self.meMapViewController removeMap:self.name clearCache:NO];
	self.isRunning = NO;
}

- (void) tapOnDynamicMarker:(NSString *)markerName
				  onMapView:(MEMapView *)mapView
					mapName:(NSString *)mapName
			  atScreenPoint:(CGPoint)screenPoint
			  atMarkerPoint:(CGPoint)markerPoint
{

	NSLog(@"Dynamic marker tap detected on map name: %@, marker name: %@, screen point:(%f, %f), image point:(%f, %f)",
		  mapName,
		  markerName,
		  screenPoint.x,
		  screenPoint.y,
		  markerPoint.x,
		  markerPoint.y);
}

@end

/////////////////////////////////////////////////////////////////
@implementation BlinkingMarkerCachedTest

- (id) init
{
	if(self=[super init])
		self.name = @"Blinking Pin Cached Img./Cached Img.";
	return self;
}

- (void) addMarker
{
	//Cache an image.
	[self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"pinRed"]
										  withName:@"blinkingMarker"
								   compressTexture:NO
					nearestNeighborTextureSampling:NO];
	
	MEDynamicMarker* marker = [[[MEDynamicMarker alloc]init]autorelease];
	marker.name = @"pin";
	marker.cachedImageName = @"blinkingMarker";
	marker.compressTexture = NO;
	marker.location = RDU_COORD;
	marker.anchorPoint = CGPointMake(7,35);
	[self.meMapViewController addDynamicMarkerToMap:self.name dynamicMarker:marker];
    
    

	
}

- (void) updateMarker
{
	//Update the cached marker
	[self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:self.imageName]
										  withName:@"blinkingMarker"
								   compressTexture:NO
					nearestNeighborTextureSampling:NO];
}

@end

/////////////////////////////////////////////////////////////////
@implementation BlinkingMarkerHybridTest
- (id) init
{
	if(self=[super init])
		self.name = @"Blinking Pin Cached Img. / UIImage";
	return self;
}

- (void) addMarker
{
	//Cache an image.
	[self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"pinRed"]
										  withName:@"pinRed"
								   compressTexture:NO
					nearestNeighborTextureSampling:NO];
	
	MEDynamicMarker* marker = [[[MEDynamicMarker alloc]init]autorelease];
	marker.name = @"pin";
	marker.cachedImageName = @"pinRed";
	marker.compressTexture = NO;
	marker.location = RDU_COORD;
	marker.anchorPoint = CGPointMake(7,35);
	[self.meMapViewController addDynamicMarkerToMap:self.name dynamicMarker:marker];
	
}

- (void) updateMarker
{
	if(self.flipper)
	{
		//Use a cached marker image
		[self.meMapViewController updateDynamicMarkerImage:self.name
												markerName:@"pin"
										   cachedImageName:@"pinRed"
											   anchorPoint:CGPointMake(7,35)
													offset:CGPointMake(0,0)];
	}
	else
	{
		//Use a non-cached marker image
		[self.meMapViewController updateDynamicMarkerImage:self.name
												markerName:@"pin"
												   uiImage:[UIImage imageNamed:@"pinGreen"]
											   anchorPoint:CGPointMake(7,35)
													offset:CGPointMake(0,0)
										   compressTexture:NO];
		
	}
}
@end

/////////////////////////////////////////////////////////////////
@implementation BlinkingMovingMarkerTest

- (id) init
{
	if(self=[super init])
		self.name = @"Blinking Pin w/Animation";
	return self;
}


- (void) updateMarker
{
	[super updateMarker];
	[self.meMapViewController updateDynamicMarkerLocation:self.name
											   markerName:@"pin"
												 location:self.location
										animationDuration:0.75];
}

- (void) timerTick
{
	[super timerTick];
	if(!self.flipper)
		self.location = SFO_COORD;
	else
		self.location = RDU_COORD;
	[self updateMarker];
	
}
@end;

/////////////////////////////////////////////////////////////////
@implementation BlinkingRotatingMarkerTest

- (id) init
{
	if(self=[super init])
		self.name = @"Blinking Pin w/Rotation";
	return self;
}


- (void) updateMarker
{
	[super updateMarker];
	[self.meMapViewController updateDynamicMarkerRotation:self.name
											   markerName:@"pin"
												 rotation:self.heading
										animationDuration:1.0];
	
}

- (void) timerTick
{
	[super timerTick];
	self.heading += 45;
	if(self.heading>=360)
		self.heading =0;
	
}
@end;
