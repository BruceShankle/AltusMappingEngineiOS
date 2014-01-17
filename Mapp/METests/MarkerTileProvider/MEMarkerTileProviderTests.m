//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MEMarkerTileProviderTests.h"
#import "MEMarkerTileProvider.h"
#import "../../MapManager/MapManager.h"

@implementation MEMarkerVirtual

- (id) init {
	if(self=[super init]){
		self.name = @"Virtual Marker Map";
	}
	return self;
}

- (void) start {
	if(self.isRunning)
		return;
	
	//Create tile provider
	self.meMarkerTileProvider = [[[MEMarkerTileProvider alloc]init]autorelease];
	self.meMarkerTileProvider.meMapViewController = self.meMapViewController;
	
	//Create virtual map info
	MEVirtualMapInfo* mapInfo = [[[MEVirtualMapInfo alloc]init]autorelease];
	mapInfo.meMapViewController = self.meMapViewController;
	mapInfo.meTileProvider = self.meMarkerTileProvider;
	mapInfo.mapType = kMapTypeVirtualMarker;
	mapInfo.zOrder = 10;
	mapInfo.name = self.name;
	
	//Add map
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
    
	self.isRunning = YES;
}

- (void) stop {
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeMap:self.name clearCache:YES];
	self.isRunning = NO;
}
@end