//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "WMSTests.h"
#import "../../METestManager.h"
#import "../../Utilities/WMSTileDownloader.h"
#import "../../Utilities/TileFactory.h"

@implementation WMSTest

- (WMSTileDownloader*) createTileWorker {
	NSLog(@"You must override this function. Exiting.");
	exit(0);
}

-(MEVirtualMapInfo*) createMapInfo {
    
    //Create tile factory and workers
    TileFactory* newFactory = [[TileFactory alloc]init];
    newFactory.targetQueuePriority = DISPATCH_QUEUE_PRIORITY_BACKGROUND;
    newFactory.meMapViewController = self.meMapViewController;
    for(int i=0; i<3; i++){
        [newFactory addWorker:[self createTileWorker]];
    }
    
    //Create virtual map info object
	MEVirtualMapInfo* mapInfo = [[MEVirtualMapInfo alloc]init];
	mapInfo.name = self.name;
	mapInfo.maxLevel = 20;
    mapInfo.meTileProvider = newFactory;
	mapInfo.zOrder = 3;
    mapInfo.isSphericalMercator = NO;
    mapInfo.loadingStrategy = kHighestDetailOnly;
    mapInfo.contentType = kZoomIndependent;
    
	return mapInfo;
}

- (void) beginTest {
	//Create and add map.
	MEVirtualMapInfo* mapInfo = [self createMapInfo];
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

- (void) endTest {
	[self.meMapViewController removeMap:self.name
                             clearCache:NO];
}
@end

///////////////////////////////////////////////////////////////////
@implementation NOAARadar

- (id) init {
	if(self=[super init]){
		self.name = @"NOAA RIDGERadar";
	}
	return self;
}

-(MEVirtualMapInfo*) createMapInfo {
	MEVirtualMapInfo* mapInfo = [super createMapInfo];
	mapInfo.minX = -165.507222;
	mapInfo.minY = 18.083333;
	mapInfo.maxX = 76.923333;
	mapInfo.maxY = 70.488889;
	mapInfo.zOrder = 4;
	mapInfo.maxLevel = 20;
	return mapInfo;
}


- (TileWorker*) createTileWorker {
	//Create and configure tile provider
	WMSTileDownloader* tileDownloader = [[WMSTileDownloader alloc]init];
	tileDownloader.wmsURL = @"http://gis.srh.noaa.gov/arcgis/services/RIDGERadar/MapServer/WMSServer";
	tileDownloader.wmsLayers = @"0";
	tileDownloader.wmsFormat = @"image/png";
    tileDownloader.wmsStyleString=@"default";
    tileDownloader.enableAlpha=YES;
    tileDownloader.useCache=NO;
    tileDownloader.useWMSStyle=YES;
    tileDownloader.convertTo3857=NO;
    tileDownloader.wmsCRS=@"CRS:84";
	return tileDownloader;
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


- (TileWorker*) createTileWorker {
	//Create and configure tile provider
	WMSTileDownloader* tileDownloader = [[WMSTileDownloader alloc]init];
	tileDownloader.wmsURL = @"http://demo.lizardtech.com/lizardtech/iserv/ows";
	tileDownloader.wmsLayers = @"MODIS";
	tileDownloader.wmsVersion = @"1.1.1";
	tileDownloader.wmsFormat = @"image/jpeg";
    tileDownloader.enableAlpha=NO;
	return tileDownloader;
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

- (TileWorker*) createTileWorker {
	//Create and configure tile provider
	WMSTileDownloader* tileDownloader = [[WMSTileDownloader alloc]init];
	tileDownloader.wmsURL = @"http://demo.lizardtech.com/lizardtech/iserv/ows";
	tileDownloader.wmsLayers = @"DC";
	tileDownloader.wmsSRS = @"EPSG:3857";
	tileDownloader.wmsVersion = @"1.1.1";
	return tileDownloader;
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

- (TileWorker*) createTileWorker {
	//Create and configure tile provider
	WMSTileDownloader* tileDownloader = [[WMSTileDownloader alloc]init];
	tileDownloader.wmsURL = @"http://demo.lizardtech.com/lizardtech/iserv/ows";
	tileDownloader.wmsLayers = @"Seattle";
	tileDownloader.wmsVersion = @"1.1.1";
	return tileDownloader;
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

- (TileWorker*) createTileWorker {
	//Create and configure tile provider
	WMSTileDownloader* tileDownloader = [[WMSTileDownloader alloc]init];
	tileDownloader.wmsURL = @"http://demo.lizardtech.com/lizardtech/iserv/ows";
	tileDownloader.wmsLayers = @"Oregon";
	tileDownloader.wmsVersion = @"1.1.1";
	return tileDownloader;
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

- (TileWorker*) createTileWorker {
	//Create and configure tile provider
	WMSTileDownloader* tileDownloader = [[WMSTileDownloader alloc]init];
	tileDownloader.wmsURL = @"http://webservices.nationalatlas.gov/wms/1million";
	tileDownloader.wmsLayers = @"states1m";
	tileDownloader.wmsVersion = @"1.1.1";
	tileDownloader.wmsStyleString = @"default";
	return tileDownloader;
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

- (TileWorker*) createTileWorker {
	//Create and configure tile provider
	WMSTileDownloader* tileDownloader = [[WMSTileDownloader alloc]init];
	tileDownloader.wmsURL = @"http://webservices.nationalatlas.gov/wms/1million";
	tileDownloader.wmsLayers = @"treecanopy";
	tileDownloader.wmsVersion = @"1.1.1";
	tileDownloader.wmsStyleString = @"default";
	return tileDownloader;
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

- (TileWorker*) createTileWorker {
	//Create and configure tile provider
	WMSTileDownloader* tileDownloader = [[WMSTileDownloader alloc]init];
	tileDownloader.wmsURL = @"http://webservices.nationalatlas.gov/wms/1million";
	tileDownloader.wmsLayers = @"ports1m";
	tileDownloader.wmsVersion = @"1.1.1";
	tileDownloader.wmsStyleString = @"default";
	return tileDownloader;
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

- (TileWorker*) createTileWorker {
	//Create and configure tile provider
	WMSTileDownloader* tileDownloader = [[WMSTileDownloader alloc]init];
	tileDownloader.wmsURL = @"http://webservices.nationalatlas.gov/wms/map_reference";
	tileDownloader.wmsLayers = @"citiestowns";
	tileDownloader.wmsVersion = @"1.1.1";
	tileDownloader.wmsStyleString = @"default";
	return tileDownloader;
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

- (TileWorker*) createTileWorker {
	//Create and configure tile provider
	WMSTileDownloader* tileDownloader = [[WMSTileDownloader alloc]init];
	tileDownloader.wmsURL = @"http://webservices.nationalatlas.gov/wms/map_reference";
	tileDownloader.wmsLayers = @"usurban";
	tileDownloader.wmsVersion = @"1.1.1";
	tileDownloader.wmsStyleString = @"default";
	return tileDownloader;
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

- (TileWorker*) createTileWorker {
	//Create and configure tile provider
	WMSTileDownloader* tileDownloader = [[WMSTileDownloader alloc]init];
	tileDownloader.wmsURL = @"http://webservices.nationalatlas.gov/wms/history";
	tileDownloader.wmsLayers = @"elcty08";
	tileDownloader.wmsVersion = @"1.1.1";
	tileDownloader.wmsStyleString = @"default";
	return tileDownloader;
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

- (TileWorker*) createTileWorker {
	//Create and configure tile provider
	WMSTileDownloader* tileDownloader = [[WMSTileDownloader alloc]init];
	tileDownloader.wmsURL = @"http://webservices.nationalatlas.gov/wms/history";
	tileDownloader.wmsLayers = @"pr0509";
	tileDownloader.wmsVersion = @"1.1.1";
	tileDownloader.wmsStyleString = @"default";
	return tileDownloader;
}

@end

