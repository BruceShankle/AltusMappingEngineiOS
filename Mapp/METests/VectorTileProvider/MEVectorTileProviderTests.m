//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MEVectorTileProviderTests.h"
#import "MEVectorTileProvider.h"

@implementation MEVectorTPSimpleLines

- (id) init {
	if(self=[super init]){
		self.name = @"Simple Lines";
	}
	return self;
}

- (void) start {
	if(self.isRunning)
		return;
	
	//Create tile provider
	self.meVectorTileProvider = [[[MEVectorTileProvider alloc]init]autorelease];
	self.meVectorTileProvider.meMapViewController = self.meMapViewController;
	
	//Create virtual map info
	MEVirtualMapInfo* mapInfo = [[[MEVirtualMapInfo alloc]init]autorelease];
	mapInfo.meMapViewController = self.meMapViewController;
	mapInfo.meTileProvider = self.meVectorTileProvider;
	mapInfo.mapType = kMapTypeVirtualVector;
	mapInfo.zOrder = 10;
	mapInfo.name = self.name;
	
	//Add map
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
		
	//Add styles
	MEPolygonStyle* style=[[[MEPolygonStyle alloc]init]autorelease];
	style.strokeWidth = 1;
	style.strokeColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.5];
	[self.meMapViewController addPolygonStyleToVectorMap:self.name featureId:1 style:style];
	style.strokeColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.1];
	[self.meMapViewController addPolygonStyleToVectorMap:self.name featureId:2 style:style];
	
	self.isRunning = YES;
}

- (void) stop {
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeMap:self.name clearCache:NO];
	self.isRunning = NO;
}
@end
