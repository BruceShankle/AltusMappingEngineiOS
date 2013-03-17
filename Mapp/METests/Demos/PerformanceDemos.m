//
//  PerformanceDemo.m
//  Mapp
//
//  Created by Bruce Shankle III on 10/12/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "PerformanceDemos.h"
#import "../METestManager.h"
#import "../METestCategory.h"
#import <ME/ME.h>

//////////////////////////////////////////////////////
@implementation PlanetWatch
@synthesize demoStep;
@synthesize demoTime;

- (id) init
{
	if (self=[super init])
	{
		self.name = @"Planet Watch";
	}
	return self;
}

- (void) start
{
	if(self.isRunning)
		return;
	[self.meTestCategory stopAllTests];
	self.demoStep = 0;
	self.interval = 0.25;
    [super start];
	self.isRunning = YES;
}

- (void) cameraToLon:(double) lon lat:(double)lat alt:(double)alt
{
	MELocation loc;
	loc.altitude = alt;
	loc.center.longitude = lon;
	loc.center.latitude = lat;
	[self.meMapViewController.meMapView setLocation:loc animationDuration:1.0];
}

- (void) interpolateCamera:(int) step
{
	double speed = 1.0;
	double maxLat = 35;
	double wobble = 2;
	
	double longitude = -step * speed;
	double latitude = sin([MEMath toRadians:longitude] * wobble) * maxLat;
	
	
	int maxAlt = 25000000;
	int minAlt = 4000000;
	int altFreq = 5;
	double altitudeT = 0.5 * sin([MEMath toRadians:longitude] * altFreq) + 0.5;
	double altitude = minAlt + pow(altitudeT, 4) * (maxAlt - minAlt);
	
	[self cameraToLon:longitude lat:latitude alt:altitude];
}

- (void) timerTick
{
	self.demoStep++;
	self.demoTime += self.interval;
	[self interpolateCamera:self.demoStep];
}

- (void) stop
{
	[super stop];
	self.isRunning = NO;
}
@end


//////////////////////////////////////////////////////
@implementation PlanetWatchRaster
@synthesize otherTests;
@synthesize testIndex;

- (void) getTestFromCategory:(NSString*) categoryName testName:(NSString*) testName
{
	METest* meTest;
	meTest = [self.meTestManager testFromCategoryName:categoryName
										 withTestName:testName];
	if(meTest!=nil)
	{
		[self.otherTests addObject:meTest];
	}
}

- (void) findOtherTests
{
	[self getTestFromCategory:@"Internet Maps" testName:@"MapBox"];
	[self getTestFromCategory:@"Internet Maps" testName:@"MapBox LandCover"];
	[self getTestFromCategory:@"Internet Maps" testName:@"MapQuest"];
	[self getTestFromCategory:@"Internet Maps" testName:@"MapQuest Aerial"];
	[self getTestFromCategory:@"Internet Maps" testName:@"Open Street Maps"];
}

- (id) init
{
	if (self=[super init])
	{
		self.name = @"Planet Watch Raster";
		testIndex=0;
	}
	return self;
}

- (void) start
{
	self.otherTests = [[[NSMutableArray alloc]init]autorelease];
	[self findOtherTests];
	[super start];
}

- (void) dealloc
{
	self.otherTests = nil;
	[super dealloc];
}


- (void) stopAll
{
	for(METest* meTest in self.otherTests)
	{
		[meTest stop];
	}
}

- (void) switchMaps
{
	[self stopAll];
	METest* meTest = [self.otherTests objectAtIndex:self.testIndex];
	[meTest start];
	
	//Increment and/or reset index
	self.testIndex++;
	if(testIndex==self.otherTests.count)
		testIndex=0;
}

- (void) timerTick
{
	[super timerTick];
	double switchInterval = 10;
	
	if(self.demoTime > switchInterval)
	{
		self.demoTime = 0;
		[self switchMaps];
	}
}

@end


//////////////////////////////////////////////////////
@implementation PlanetWatchVector


- (void) findOtherTests
{
	[self getTestFromCategory:@"World Vector" testName:@"MapBox Style"];
	[self getTestFromCategory:@"World Vector" testName:@"Google Style"];
	[self getTestFromCategory:@"World Vector" testName:@"High Contrast Style"];
	[self getTestFromCategory:@"World Vector" testName:@"Purple Style"];
	[self getTestFromCategory:@"World Vector" testName:@"Geology.com Style"];
	[self getTestFromCategory:@"World Vector" testName:@"Invisible Style"];
}

- (id) init
{
	if (self=[super init])
	{
		self.name = @"Planet Watch Vector";
	}
	return self;
}


@end
