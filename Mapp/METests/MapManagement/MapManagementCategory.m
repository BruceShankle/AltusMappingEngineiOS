//
//  MapManagementCategory.m
//  Mapp
//
//  Created by Bruce Shankle III on 10/12/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MapManagementCategory.h"

@implementation MapManagementCategory

- (id) init
{
	if(self=[super init])
	{
		self.containsDynamicTestArray = YES;
	}
	return self;
}

- (void) addTestForMap:(MEMapInfo*) mapInfo
{
	
}

- (void) updateTestArray
{
	self.meTests = nil;
	self.meTests = [[[NSMutableArray alloc]init]autorelease];
	NSArray* mapArray = [self.meMapViewController loadedMaps];
	for(MEMapInfo* mapInfo in mapArray)
	{
		[self addTestForMap:mapInfo];
	}
}

@end
