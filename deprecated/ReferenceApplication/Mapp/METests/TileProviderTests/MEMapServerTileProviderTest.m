//
//  MEMapServerTileProviderTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/21/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MEMapServerTileProviderTest.h"
#import "MEMapServerTileProvider.h"
#import "MERemoteMapCatalog.h"
#import "METestCategory.h"

@implementation MEMapServerTileProviderTest
@synthesize meMapServerTileProvider;

- (id) init
{
    if(self = [super init])
    {
        self.name=@"BA3 Streamed 1";
    }
    return self;
}

- (void) dealloc
{
    self.meMapServerTileProvider = nil;
    self.mapName = nil;
    [super dealloc];
}

-(void) createTileProvider
{
    self.meMapServerTileProvider = [[MEMapServerTileProvider alloc]init];
    self.meMapServerTileProvider.meMapViewController = self.meMapViewController;
}

- (NSString*) label
{
    return @"files";
}

- (void) start
{
	[self.meTestCategory stopAllTests];
	
    //Load the catalog of remote maps (this is simply a JSON file embedded in the app)
    MERemoteMapCatalog* remoteMapCatalog = [[[MERemoteMapCatalog alloc]init]autorelease];
    
    //Load information about a remote map
    int remoteMapIndex;
    remoteMapIndex = 0;
    MERemoteMapInfo mapInfo = [remoteMapCatalog mapInfo:remoteMapIndex];
    NSString* mapDomain = [remoteMapCatalog mapDomain:remoteMapIndex];
    self.mapName = [remoteMapCatalog mapName:remoteMapIndex];
    
    //Create a tile provider that will stream the remote map
    [self createTileProvider];
    self.meMapServerTileProvider.mapDomain = mapDomain;
    self.meMapServerTileProvider.isAsynchronous = YES;
	
	MEVirtualMapInfo* vMapInfo = [[[MEVirtualMapInfo alloc]init]autorelease];
	vMapInfo.name = self.mapName;
	vMapInfo.meTileProvider = self.meMapServerTileProvider;
	vMapInfo.maxLevel = mapInfo.maxLevel;
	vMapInfo.zOrder = mapInfo.zorder;
	vMapInfo.minX = mapInfo.minX;
	vMapInfo.minY = mapInfo.minY;
	vMapInfo.maxX = mapInfo.maxX;
	vMapInfo.maxY = mapInfo.maxY;
	vMapInfo.borderPixelCount = mapInfo.borderSize;
	vMapInfo.loadingStrategy = kLowestDetailFirst;
	vMapInfo.contentType = kZoomIndependent;
	[self.meMapViewController addMapUsingMapInfo:vMapInfo];
    
    self.isRunning = YES;
}

- (void) stop
{
    [self.meMapViewController removeMap:self.mapName clearCache:YES];
    self.isRunning = NO;
}

@end

//Variation of the above test that returns UIImages to the engine
@implementation MEUIImageMapServerTileProviderTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"BA3 Streamed 2";
    }
    return self;
}

-(void) createTileProvider
{
    self.meMapServerTileProvider = [[MEMapServerTileProvider alloc]init];
    self.meMapServerTileProvider.meMapViewController = self.meMapViewController;
    self.meMapServerTileProvider.returnUIImages = YES;
}

- (NSString*) label
{
    return @"UIImages";
}

@end

@implementation MENSDataMapServerTileProviderTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"BA3 Streamed 3";
    }
    return self;
}

-(void) createTileProvider
{
    self.meMapServerTileProvider = [[MEMapServerTileProvider alloc]init];
    self.meMapServerTileProvider.meMapViewController = self.meMapViewController;
    self.meMapServerTileProvider.returnNSData = YES;
    self.meMapServerTileProvider.returnUIImages = NO;
}

- (NSString*) label
{
    return @"NSData";
}


@end
