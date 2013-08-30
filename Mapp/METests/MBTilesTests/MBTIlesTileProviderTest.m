//
//  MBTIlesTileProviderTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/22/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MBTIlesTileProviderTest.h"
#import "MBTilesTileProvider.h"
#import "../METestCategory.h"
#import "../METestManager.h"


@implementation MBTilesNativeTestDC
- (id) init
{
    if(self = [super init])
    {
        self.name=@"Washington D.C.";
    }
    return self;
}

- (void) start
{
	[self.meTestCategory stopAllTests];
	NSString* databaseFile = [ [NSBundle mainBundle] pathForResource:@"open-streets-dc-15"
															  ofType:@"mbtiles"];
	
	[self.meMapViewController addMBTilesMap:self.name
								   fileName:databaseFile
							defaultTileName:@"grayGrid"
							  imageDataType:kImageDataTypePNG
							compessTextures:NO
									 zOrder:2];
	
	//Zoom in on washington dc
	[self.meMapViewController.meMapView lookAtCoordinate:
	 CLLocationCoordinate2DMake(38.848,-77.1127)
										   andCoordinate:
	 CLLocationCoordinate2DMake(38.933,-76.9665)
									withHorizontalBuffer:20
									  withVerticalBuffer:20
									   animationDuration:1.0];
	
	
	self.isRunning = YES;
}

- (void) stop
{
	[self.meMapViewController removeMap:self.name
							 clearCache:YES];
	self.isRunning = NO;
}

@end


@implementation MBTilesNativeTest1
- (id) init
{
    if(self = [super init])
    {
        self.name=@"Earthquakes - Native 1";
    }
    return self;
}

- (void) start
{
	[self.meTestCategory stopAllTests];
	NSString* databaseFile = [[NSBundle mainBundle] pathForResource:@"Earthquakes"
															 ofType:@"mbtiles"];
	
	[self.meMapViewController addMBTilesMap:self.name
								   fileName:databaseFile
							defaultTileName:@"grayGrid"
							  imageDataType:kImageDataTypePNG
							compessTextures:NO
									 zOrder:2];
	
	self.isRunning = YES;
}

- (void) stop
{
	[self.meMapViewController removeMap:self.name
							 clearCache:YES];
	self.isRunning = NO;
}

@end


@implementation MBTilesNativeTest2
- (id) init
{
    if(self = [super init])
    {
        self.name=@"Earthquakes - Native 2";
    }
    return self;
}

- (void) start
{
	[self.meTestCategory stopAllTests];
	NSString* databaseFile = [[NSBundle mainBundle] pathForResource:@"Earthquakes"
															 ofType:@"mbtiles"];
	
	MEMBTilesMapInfo* mapInfo = [[[MEMBTilesMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.sqliteFileName = databaseFile;
	mapInfo.imageDataType = kImageDataTypePNG;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	self.isRunning = YES;
}

- (void) stop
{
	[self.meMapViewController removeMap:self.name
							 clearCache:YES];
	self.isRunning = NO;
}

@end

@implementation MBTIlesTileProviderTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Earthquakes - Tile External Provider";
    }
    return self;
}

- (void) start
{
	[self.meTestCategory stopAllTests];
	
	//Create tile provider
    MBTilesTileProvider* mbTilesTilesProvider = [[[MBTilesTileProvider alloc]initWithDatabaseName:@"Earthquakes"]autorelease];
    mbTilesTilesProvider.meMapViewController = self.meMapViewController;
	
	//Create map info
	MEVirtualMapInfo* mapInfo = [[[MEVirtualMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.isSphericalMercator = YES;
	mapInfo.zOrder = 5;
	mapInfo.maxLevel = 7;
	mapInfo.contentType = kZoomIndependent;
	mapInfo.loadingStrategy = kLowestDetailFirst;
	mapInfo.meTileProvider = mbTilesTilesProvider;
	
	//Add map
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
    self.isRunning = YES;
}

- (void) stop
{
    [self.meMapViewController removeMap:self.name clearCache:YES];
    self.isRunning = NO;
}

@end
