//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MERefreshAllMapsTest.h"

@implementation MERefreshAllMapsTest

- (id) init
{
	if(self=[super init])
	{
		self.name=@"Refresh All Maps";
	}
	return self;
}

- (void) start
{
	for(MEMapInfo* mapInfo in self.meMapViewController.loadedMaps)
		[self.meMapViewController refreshMap:mapInfo.name];
}

@end



@implementation MERefreshDirtyAllMapsTest

- (id) init
{
	if(self=[super init])
	{
		self.name=@"Refresh Dirty All Maps";
	}
	return self;
}

- (void) start
{
	for(MEMapInfo* mapInfo in self.meMapViewController.loadedMaps)
		[self.meMapViewController refreshDirtyTiles:mapInfo.name];
}

@end