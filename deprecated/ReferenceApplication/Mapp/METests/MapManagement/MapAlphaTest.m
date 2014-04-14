//
//  MapAlphaTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 10/12/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MapAlphaTest.h"

#import "../METestManager.h"
#import "../METestCategory.h"

//////////////////////////////////////////////////////
@implementation MapAlphaUpCategory

- (MapAlphaTest*) createTest:(MEMapInfo*) mapInfo
{
	MapAlphaTest* test;
	test = [[[MapAlphaTest alloc]initWithMapInfo:mapInfo]autorelease];
	test.meTestCategory = self;
	test.meTestManager = self.meTestManager;
	test.meMapViewController = self.meMapViewController;
	[self.meTests addObject:test];
	return test;
}

- (void) addTestForMap:(MEMapInfo *)mapInfo
{
	MapAlphaTest* test = [self createTest:mapInfo];
	test.alphaDelta = 0.1;
}
@end

//////////////////////////////////////////////////////
@implementation MapAlphaDownCategory
- (void) addTestForMap:(MEMapInfo *)mapInfo
{
	MapAlphaTest* test = [self createTest:mapInfo];
	test.alphaDelta = -0.1;
}
@end

//////////////////////////////////////////////////////
@implementation MapAlphaTest
@synthesize meMapInfo;

- (id) initWithMapInfo:(MEMapInfo*) mapInfo
{
	if(self=[super init])
	{
		self.meMapInfo = mapInfo;
		self.name = [mapInfo.name lastPathComponent];
		self.alphaDelta = 0.1;
		self.bestFontSize = 13;
	}
	return self;
}

- (NSString*) label
{
	return [NSString stringWithFormat:@"%.02f", self.meMapInfo.alpha];
}

- (void) userTapped
{
	//If we are decreasing and we're at zero exit...
	if(self.alphaDelta<0 && self.meMapInfo.alpha==0)
		return;
	
	//Increment or decrement alpha
	self.meMapInfo.alpha = self.meMapInfo.alpha + self.alphaDelta;
	
	//Clamp
	if(self.meMapInfo.alpha > 1)
		self.meMapInfo.alpha = 1;
	if(self.meMapInfo.alpha < 0)
		self.meMapInfo.alpha = 0;
	
	//Set map alpha
	[self.meMapViewController setMapAlpha:self.meMapInfo.name
									alpha:self.meMapInfo.alpha];
}

- (void) start {}
- (void) stop {}

- (void) dealloc
{
	self.meMapInfo = nil;
	[super dealloc];
}

@end
