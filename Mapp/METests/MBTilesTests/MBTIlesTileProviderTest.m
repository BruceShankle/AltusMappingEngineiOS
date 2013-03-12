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

@implementation MBTilesNativeTest
- (id) init
{
    if(self = [super init])
    {
        self.name=@"Earthquakes - Native";
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
	mapInfo.zOrder = 2;
	mapInfo.maxLevel = 7;
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
    MBTilesTileProvider* mbTilesTilesProvider = [[[MBTilesTileProvider alloc]initWithDatabaseName:self.name]autorelease];
    mbTilesTilesProvider.meMapViewController = self.meMapViewController;
	
	//Create map info
	MEVirtualMapInfo* mapInfo = [[[MEVirtualMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.isSlippyMap = YES;
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
