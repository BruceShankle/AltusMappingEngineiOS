//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MEWMSTests.h"
#import "MEWMSTileProvider.h"

@implementation MEWMSTest

- (id) init {
	if(self=[super init]){
		self.name = @"MEWMSTest";
	}
	return self;
}

- (void) start {
	if(self.isRunning)
		return;
	[self addMap];
	self.isRunning = YES;
}

- (METileProvider*) createTileProvider {
	NSLog(@"You must override this function. Exiting.");
	exit(0);
}

-(MEVirtualMapInfo*) createMapInfo {
	MEVirtualMapInfo* mapInfo = [[[MEVirtualMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.maxLevel = 12;
	mapInfo.defaultTileName = @"grayGrid";
	mapInfo.meMapViewController = self.meMapViewController;
	mapInfo.meTileProvider = [self createTileProvider];
	mapInfo.isSphericalMercator = NO;
	mapInfo.zOrder = 3;
	return mapInfo;
}

- (void) addMap {
	
	//Add default tile.
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"grayGrid"] withName:@"grayGrid" compressTexture:NO];
	
	//Create and add map.
	[self.meMapViewController addMapUsingMapInfo:[self createMapInfo]];
	
}

- (void) removeMap {
	[self.meMapViewController removeMap:self.name clearCache:NO];
}

- (void) stop {
	if(!self.isRunning)
		return;
	[self removeMap];
	self.isRunning = NO;
}

@end

///////////////////////////////////////////////////////////////////
@implementation MEWMSBlueMarbleTest

- (id) init {
	if(self=[super init]){
		self.name = @"Blue Marble";
	}
	return self;
}

- (METileProvider*) createTileProvider {
	//Create and configure tile provider
	MEWMSTileProvider* tileProvider = [[[MEWMSTileProvider alloc]init]autorelease];
	tileProvider.wmsURL = @"http://demo.lizardtech.com/lizardtech/iserv/ows";
	tileProvider.wmsLayers = @"MODIS";
	tileProvider.wmsVersion = @"1.1.1";
	tileProvider.wmsFormat = @"image/jpeg";
	tileProvider.tileFileExtension = @"jpg";
	tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.shortName = @"WMS_BlueMarble";
	return tileProvider;
}

@end

///////////////////////////////////////////////////////////////////
@implementation MEWMSDCTest

- (id) init {
	if(self=[super init]){
		self.name = @"Washington, D.C.";
	}
	return self;
}

-(MEVirtualMapInfo*) createMapInfo {
	MEVirtualMapInfo* mapInfo = [super createMapInfo];
	mapInfo.minX = -77.643627;
	mapInfo.minY = 38.607604;
	mapInfo.maxX = -76.728874;
	mapInfo.maxY = 39.151198;
	mapInfo.zOrder = 4;
	mapInfo.maxLevel = 19;
	
	[self.meMapViewController.meMapView
	 lookAtCoordinate:CLLocationCoordinate2DMake(mapInfo.minY, mapInfo.minX)
	 andCoordinate:CLLocationCoordinate2DMake(mapInfo.maxY, mapInfo.maxX)
	 withHorizontalBuffer:0
	 withVerticalBuffer:0
	 animationDuration:1.0];
	
	return mapInfo;
}

- (METileProvider*) createTileProvider {
	//Create and configure tile provider
	MEWMSTileProvider* tileProvider = [[[MEWMSTileProvider alloc]init]autorelease];
	tileProvider.wmsURL = @"http://demo.lizardtech.com/lizardtech/iserv/ows";
	tileProvider.wmsLayers = @"DC";
	tileProvider.wmsSRS = @"EPSG:4326";
	tileProvider.wmsVersion = @"1.1.1";
	tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.shortName = @"WMS_DC";
	return tileProvider;
}

@end

///////////////////////////////////////////////////////////////////
@implementation MEWMSSeattleTest

- (id) init {
	if(self=[super init]){
		self.name = @"Seattle, WA";
	}
	return self;
}

-(MEVirtualMapInfo*) createMapInfo {
	MEVirtualMapInfo* mapInfo = [super createMapInfo];
	mapInfo.minX = -122.633049;
	mapInfo.minY = 46.991471;
	mapInfo.maxX = -121.982434;
	mapInfo.maxY = 48.007485;
	mapInfo.zOrder = 4;
	mapInfo.maxLevel = 19;
	
	[self.meMapViewController.meMapView
	 lookAtCoordinate:CLLocationCoordinate2DMake(mapInfo.minY, mapInfo.minX)
	 andCoordinate:CLLocationCoordinate2DMake(mapInfo.maxY, mapInfo.maxX)
	 withHorizontalBuffer:0
	 withVerticalBuffer:0
	 animationDuration:1.0];
	
	return mapInfo;
}

- (METileProvider*) createTileProvider {
	//Create and configure tile provider
	MEWMSTileProvider* tileProvider = [[[MEWMSTileProvider alloc]init]autorelease];
	tileProvider.wmsURL = @"http://demo.lizardtech.com/lizardtech/iserv/ows";
	tileProvider.wmsLayers = @"Seattle";
	tileProvider.wmsSRS = @"EPSG:4326";
	tileProvider.wmsVersion = @"1.1.1";
	tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.shortName = @"WMS_Seattle";
	return tileProvider;
}

@end

///////////////////////////////////////////////////////////////////
@implementation MEWMSOregonTest

- (id) init {
	if(self=[super init]){
		self.name = @"Oregon";
	}
	return self;
}

-(MEVirtualMapInfo*) createMapInfo {
	MEVirtualMapInfo* mapInfo = [super createMapInfo];
	mapInfo.minX = -124.635281;
	mapInfo.minY = 41.89403;
	mapInfo.maxX = -116.428491;
	mapInfo.maxY = 46.319715;
	mapInfo.zOrder = 4;
	mapInfo.maxLevel = 19;
	
	[self.meMapViewController.meMapView
	 lookAtCoordinate:CLLocationCoordinate2DMake(mapInfo.minY, mapInfo.minX)
	 andCoordinate:CLLocationCoordinate2DMake(mapInfo.maxY, mapInfo.maxX)
	 withHorizontalBuffer:0
	 withVerticalBuffer:0
	 animationDuration:1.0];
	
	return mapInfo;
}

- (METileProvider*) createTileProvider {
	//Create and configure tile provider
	MEWMSTileProvider* tileProvider = [[[MEWMSTileProvider alloc]init]autorelease];
	tileProvider.wmsURL = @"http://demo.lizardtech.com/lizardtech/iserv/ows";
	tileProvider.wmsLayers = @"Oregon";
	tileProvider.wmsSRS = @"EPSG:4326";
	tileProvider.wmsVersion = @"1.1.1";
	tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.shortName = @"WMS_Oregon";
	return tileProvider;
}

@end

