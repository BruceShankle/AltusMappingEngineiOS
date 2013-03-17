//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import "MapIsVisibleTest.h"

//////////////////////////////////////////////////////
@implementation MapIsVisibleCategory

- (MapIsVisibleTest*) createTest:(MEMapInfo*) mapInfo
{
	MapIsVisibleTest* test;
	test = [[[MapIsVisibleTest alloc]initWithMapInfo:mapInfo]autorelease];
	test.meTestCategory = self;
	test.meTestManager = self.meTestManager;
	test.meMapViewController = self.meMapViewController;
	[self.meTests addObject:test];
	return test;
}

- (void) addTestForMap:(MEMapInfo *)mapInfo
{
	[self createTest:mapInfo];
}
@end

///////////////////////////////////////////////////////////
@implementation MapIsVisibleTest
- (id) initWithMapInfo:(MEMapInfo*) mapInfo
{
	if(self=[super init])
	{
		self.meMapInfo = mapInfo;
		self.name = [mapInfo.name lastPathComponent];
	}
	return self;
}

- (void) start{}
- (void) stop{}
- (BOOL) isRunning
{
	return [self.meMapViewController getMapIsVisible:self.meMapInfo.name];
}

- (void) userTapped
{
	[self.meMapViewController setMapIsVisible:self.meMapInfo.name isVisible:!self.isRunning];
}

@end
