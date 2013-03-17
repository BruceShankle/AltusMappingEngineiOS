//
//  MapZOrderTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 10/12/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MapZOrderTest.h"
#import "../METestManager.h"
#import "../METestCategory.h"

//////////////////////////////////////////////////////
@implementation MapZOrderUpCategory

- (MapZOrderTest*) createTest:(MEMapInfo*) mapInfo
{
	MapZOrderTest* test;
	test = [[[MapZOrderTest alloc]initWithMapInfo:mapInfo]autorelease];
	test.meTestCategory = self;
	test.meTestManager = self.meTestManager;
	test.meMapViewController = self.meMapViewController;
	[self.meTests addObject:test];
	return test;
}

- (void) addTestForMap:(MEMapInfo *)mapInfo
{
	MapZOrderTest* test = [self createTest:mapInfo];
	test.zorderDelta = 1;
}
@end

//////////////////////////////////////////////////////
@implementation MapZOrderDownCategory
- (void) addTestForMap:(MEMapInfo *)mapInfo
{
	MapZOrderTest* test = [self createTest:mapInfo];
	test.zorderDelta = -1;
}
@end

//////////////////////////////////////////////////////
@implementation MapZOrderTest
@synthesize meMapInfo;

- (id) initWithMapInfo:(MEMapInfo*) mapInfo
{
	if(self=[super init])
	{
		self.meMapInfo = mapInfo;
		self.name = [mapInfo.name lastPathComponent];
		self.zorderDelta = 1;
		self.bestFontSize = 13;
	}
	return self;
}

- (NSString*) label
{
	return [NSString stringWithFormat:@"%d", self.meMapInfo.zOrder];
}

- (void) userTapped
{
	//If we are decreasing and we're at zero exit...
	if(self.zorderDelta<0 && self.meMapInfo.zOrder==0)
		return;
	
	//Increment or decrement zorder
	self.meMapInfo.zOrder = self.meMapInfo.zOrder + self.zorderDelta;
	
	//Set map zorder
	[self.meMapViewController setMapZOrder:self.meMapInfo.name
									zOrder:self.meMapInfo.zOrder];
}

- (void) start {}
- (void) stop {}

- (void) dealloc
{
	self.meMapInfo = nil;
	[super dealloc];
}

@end
