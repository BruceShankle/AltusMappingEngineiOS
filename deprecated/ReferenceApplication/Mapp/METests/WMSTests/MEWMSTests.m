//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MEWMSTests.h"
#import "MEWMSTileProvider.h"
#import "../METestManager.h"

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
	mapInfo.defaultTileName = @"grayGridTransparent";
	mapInfo.meMapViewController = self.meMapViewController;
	mapInfo.meTileProvider = [self createTileProvider];
	mapInfo.isSphericalMercator = NO;
	mapInfo.zOrder = 3;
	return mapInfo;
}

- (void) addMap {
	
	//Add default tile.
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"grayGrid"] withName:@"grayGrid" compressTexture:NO];
	
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"grayGridTransparent"] withName:@"grayGridTransparent" compressTexture:NO];
	
	//Create and add map.
	
	MEVirtualMapInfo* mapInfo = [self createMapInfo];
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	[self.meMapViewController setMapAlpha:mapInfo.name alpha:0.99];
	
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


- (void) start{
	[super start];
	[self.meTestManager setCopyrightNotice:@"Blue Marble (MODIS) - Source: LizardTech http://demo.lizardtech.com"];
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

- (void) start{
	[super start];
	[self.meTestManager setCopyrightNotice:@"Washington D.C. - Source: LizardTech http://demo.lizardtech.com"];
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
	tileProvider.wmsSRS = @"EPSG:3857";
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

- (void) start{
	[super start];
	[self.meTestManager setCopyrightNotice:@"Seattle, WA - Source: LizardTech http://demo.lizardtech.com"];
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

- (void) start{
	[super start];
	[self.meTestManager setCopyrightNotice:@"Oregon - Source: LizardTech http://demo.lizardtech.com"];
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
	tileProvider.wmsVersion = @"1.1.1";
	tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.shortName = @"WMS_Oregon";
	return tileProvider;
}

@end

///////////////////////////////////////////////////////////////////
@implementation MEWMSNationalAtlasStates

- (id) init {
	if(self=[super init]){
		self.name = @"National Atlas - States";
	}
	return self;
}

- (void) start{
	[super start];
	[self.meTestManager setCopyrightNotice:@"State Boundaries - Source: National Atlas http://www.nationalatlas.gov"];
	
}

-(MEVirtualMapInfo*) createMapInfo {
	MEVirtualMapInfo* mapInfo = [super createMapInfo];
	mapInfo.minX = -179.147;
	mapInfo.minY = 17.6744;
	mapInfo.maxX = 179.778;
	mapInfo.maxY = 71.3892;
	mapInfo.zOrder = 4;
	mapInfo.maxLevel = 19;
	
	[self lookAtUnitedStates];
	
	return mapInfo;
}

- (METileProvider*) createTileProvider {
	//Create and configure tile provider
	MEWMSTileProvider* tileProvider = [[[MEWMSTileProvider alloc]init]autorelease];
	tileProvider.wmsURL = @"http://webservices.nationalatlas.gov/wms/1million";
	tileProvider.wmsLayers = @"states1m";
	tileProvider.wmsVersion = @"1.1.1";
	tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.shortName = @"WMSNationalAtlasStates";
	tileProvider.wmsStyleString = @"default";
	return tileProvider;
}

@end

///////////////////////////////////////////////////////////////////
@implementation MEWMSNationalAtlasTreeCanopy

- (id) init {
	if(self=[super init]){
		self.name = @"National Atlas - Tree Canopy";
	}
	return self;
}

- (void) start{
	[super start];
	[self.meTestManager setCopyrightNotice:@"U.S. Tree Canopy - Source: National Atlas http://www.nationalatlas.gov"];
	
}

-(MEVirtualMapInfo*) createMapInfo {
	MEVirtualMapInfo* mapInfo = [super createMapInfo];
	
	mapInfo.minX = -179.998;
	mapInfo.minY = 17.06;
	mapInfo.maxX = -62.6641;
	mapInfo.maxY = 71.954;
	mapInfo.zOrder = 4;
	mapInfo.maxLevel = 19;
	
	[self lookAtUnitedStates];
	
	return mapInfo;
}

- (METileProvider*) createTileProvider {
	//Create and configure tile provider
	MEWMSTileProvider* tileProvider = [[[MEWMSTileProvider alloc]init]autorelease];
	tileProvider.wmsURL = @"http://webservices.nationalatlas.gov/wms/1million";
	tileProvider.wmsLayers = @"treecanopy";
	tileProvider.wmsVersion = @"1.1.1";
	tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.shortName = @"WMSNationalAtlasTreeCanopy";
	tileProvider.wmsStyleString = @"default";
	return tileProvider;
}

@end


///////////////////////////////////////////////////////////////////
@implementation MEWMSNationalAtlasPorts

- (id) init {
	if(self=[super init]){
		self.name = @"National Atlas - Ports";
	}
	return self;
}

- (void) start{
	[super start];
	[self.meTestManager setCopyrightNotice:@"U.S. Ports - Source: National Atlas http://www.nationalatlas.gov"];
	
}


-(MEVirtualMapInfo*) createMapInfo {
	MEVirtualMapInfo* mapInfo = [super createMapInfo];
	
	mapInfo.minX = -166.532;
	mapInfo.minY = 17.706;
	mapInfo.maxX = -64.7707;
	mapInfo.maxY = 66.8998;
	mapInfo.zOrder = 4;
	mapInfo.maxLevel = 19;
	
	[self lookAtUnitedStates];
	
	return mapInfo;
}

- (METileProvider*) createTileProvider {
	//Create and configure tile provider
	MEWMSTileProvider* tileProvider = [[[MEWMSTileProvider alloc]init]autorelease];
	tileProvider.wmsURL = @"http://webservices.nationalatlas.gov/wms/1million";
	tileProvider.wmsLayers = @"ports1m";
	tileProvider.wmsVersion = @"1.1.1";
	tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.shortName = @"WMSNationalAtlasPorts";
	tileProvider.wmsStyleString = @"default";
	return tileProvider;
}

@end

///////////////////////////////////////////////////////////////////
@implementation MEWMSNationalAtlasCitiesTowns

- (id) init {
	if(self=[super init]){
		self.name = @"National Atlas - Cities & Towns";
	}
	return self;
}

- (void) start{
	[super start];
	[self.meTestManager setCopyrightNotice:@"U.S. Cities & Towns - Source: National Atlas http://www.nationalatlas.gov"];
	
}


-(MEVirtualMapInfo*) createMapInfo {
	MEVirtualMapInfo* mapInfo = [super createMapInfo];
	
	mapInfo.minX = -166.532;
	mapInfo.minY = 17.706;
	mapInfo.maxX = -64.7707;
	mapInfo.maxY = 66.8998;
	mapInfo.zOrder = 5;
	mapInfo.maxLevel = 19;
	
	[self lookAtUnitedStates];
	
	return mapInfo;
}

- (METileProvider*) createTileProvider {
	//Create and configure tile provider
	MEWMSTileProvider* tileProvider = [[[MEWMSTileProvider alloc]init]autorelease];
	tileProvider.wmsURL = @"http://webservices.nationalatlas.gov/wms/map_reference";
	tileProvider.wmsLayers = @"citiestowns";
	tileProvider.wmsVersion = @"1.1.1";
	tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.shortName = @"WMSNationalAtlasCitiesTowns";
	tileProvider.wmsStyleString = @"default";
	return tileProvider;
}

@end

///////////////////////////////////////////////////////////////////
@implementation MEWMSNationalAtlasUrbanAreas

- (id) init {
	if(self=[super init]){
		self.name = @"National Atlas - Urban Areas";
	}
	return self;
}

- (void) start{
	[super start];
	[self.meTestManager setCopyrightNotice:@"U.S. Urban Areas - Source: National Atlas http://www.nationalatlas.gov"];
	
}


-(MEVirtualMapInfo*) createMapInfo {
	MEVirtualMapInfo* mapInfo = [super createMapInfo];
	
	mapInfo.minX = -166.532;
	mapInfo.minY = 17.706;
	mapInfo.maxX = -64.7707;
	mapInfo.maxY = 66.8998;
	mapInfo.zOrder = 4;
	mapInfo.maxLevel = 19;
	
	[self lookAtUnitedStates];
	
	return mapInfo;
}

- (METileProvider*) createTileProvider {
	//Create and configure tile provider
	MEWMSTileProvider* tileProvider = [[[MEWMSTileProvider alloc]init]autorelease];
	tileProvider.wmsURL = @"http://webservices.nationalatlas.gov/wms/map_reference";
	tileProvider.wmsLayers = @"usurban";
	tileProvider.wmsVersion = @"1.1.1";
	tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.shortName = @"WMSNationalAtlasUrbanAreas";
	tileProvider.wmsStyleString = @"default";
	return tileProvider;
}

@end

///////////////////////////////////////////////////////////////////
@implementation MEWMSNationalAtlas2008Election

- (id) init {
	if(self=[super init]){
		self.name = @"National Atlas - 2008 Election";
	}
	return self;
}

- (void) start{
	[super start];
	[self.meTestManager setCopyrightNotice:@"U.S. 2008 Presidential Election - Source: National Atlas http://www.nationalatlas.gov"];
	
}


-(MEVirtualMapInfo*) createMapInfo {
	MEVirtualMapInfo* mapInfo = [super createMapInfo];
	
	mapInfo.minX = -179.133;
	mapInfo.minY = 18.9155;
	mapInfo.maxX = 179.788;
	mapInfo.maxY = 71.398;
	mapInfo.zOrder = 3;
	mapInfo.maxLevel = 19;
	
	[self lookAtUnitedStates];
	
	return mapInfo;
}

- (METileProvider*) createTileProvider {
	//Create and configure tile provider
	MEWMSTileProvider* tileProvider = [[[MEWMSTileProvider alloc]init]autorelease];
	tileProvider.wmsURL = @"http://webservices.nationalatlas.gov/wms/history";
	tileProvider.wmsLayers = @"elcty08";
	tileProvider.wmsVersion = @"1.1.1";
	tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.shortName = @"WMSNationalAtlas2008Election";
	tileProvider.wmsStyleString = @"default";
	return tileProvider;
}

@end

///////////////////////////////////////////////////////////////////
@implementation MEWMSNationalAtlasPrecipitation

- (id) init {
	if(self=[super init]){
		self.name = @"National Atlas - Precipitation";
	}
	return self;
}

- (void) start{
	[super start];
	[self.meTestManager setCopyrightNotice:@"U.S. Precipitation 2009 to 2012 - Source: National Atlas http://www.nationalatlas.gov"];
	
}


-(MEVirtualMapInfo*) createMapInfo {
	MEVirtualMapInfo* mapInfo = [super createMapInfo];
	
	mapInfo.minX = -179.133;
	mapInfo.minY = 18.9155;
	mapInfo.maxX = 179.788;
	mapInfo.maxY = 71.398;
	mapInfo.zOrder = 3;
	mapInfo.maxLevel = 19;
	
	[self lookAtUnitedStates];
	
	return mapInfo;
}

- (METileProvider*) createTileProvider {
	//Create and configure tile provider
	MEWMSTileProvider* tileProvider = [[[MEWMSTileProvider alloc]init]autorelease];
	tileProvider.wmsURL = @"http://webservices.nationalatlas.gov/wms/history";
	tileProvider.wmsLayers = @"pr0509";
	tileProvider.wmsVersion = @"1.1.1";
	tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.shortName = @"WMSNationalAtlasPrecip";
	tileProvider.wmsStyleString = @"default";
	return tileProvider;
}

@end

