//
//  MEInvisibleTileProviderTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/17/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MEInvisibleTileProviderTest.h"
#import <ME/ME.h>


///////////////////////////////////////////////////////////////////
//Test Invisible available tiles
@implementation MEInvisibleTileProvider
-(void) requestTile:(METileProviderRequest *)meTileRequest
{
	meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
    return;
}
@end;

@implementation MEInvisibleTileProviderTest
- (id) init
{
    if(self = [super init])
    {
        self.name=@"Invisible Tiles";
    }
    return self;
}

- (void) start
{
    MEInvisibleTileProvider* tileProvider = [[[MEInvisibleTileProvider alloc]init]autorelease];
	tileProvider.isAsynchronous = NO;
   
	MEVirtualMapInfo* vMapInfo= [[[MEVirtualMapInfo alloc]init]autorelease];
	vMapInfo.name = self.name;
	vMapInfo.meTileProvider = tileProvider;
	vMapInfo.zOrder = 3;
	vMapInfo.maxLevel = 17;
	vMapInfo.contentType = kZoomDependent;
	[self.meMapViewController addMapUsingMapInfo:vMapInfo];
    
    self.isRunning = YES;
}
- (void) stop
{
    [self.meMapViewController removeMap:self.name
									clearCache:YES];
    self.isRunning = NO;
}
@end


////////////////////////////////////////////////////
//Intermittent tile provider
//The purpose of this tiler provider is to sometimes
//return nothing for a tile and the engine should re-request it
//at a future point in time. This is to simulate
//connection timeouts or changing wifi connections
@implementation MEIntermittentTileProvider
@synthesize returnTiles;

-(id) init
{
    if(self=[super init])
        self.returnTiles=NO;
    return self;
}

-(void) requestTile:(METileProviderRequest *)meTileRequest
{
    self.returnTiles = !self.returnTiles;
    
    if(self.returnTiles)
    {
        [super requestTile:meTileRequest];
        return;
    }
    
    return;
}

@end

///////////////////////////////////////////////////////////////////
//Test Unvailable tiles
//The purpose of this tiler provider is to sometimes
//return an image and sometimes indicate a tile is not availble.
//The engine should not request it again.
@implementation MEUnavailableTileProvider
-(void) requestTile:(METileProviderRequest *)meTileRequest
{
    self.returnTiles = !self.returnTiles;
    
    if(self.returnTiles)
    {
        [super requestTile:meTileRequest];
        return;
    }
    else
    {
		meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
    }
    return;
}

@end

@implementation MEUnavailableTileProviderTest
- (id) init
{
    if(self = [super init])
    {
        self.name=@"Unavailble Tiles";
    }
    return self;
}

- (void) start
{
    MEUnavailableTileProvider* tileProvider = [[[MEUnavailableTileProvider alloc]init]autorelease];
	tileProvider.isAsynchronous = NO;
	
	MEVirtualMapInfo* vMapInfo= [[[MEVirtualMapInfo alloc]init]autorelease];
	vMapInfo.name = self.name;
	vMapInfo.meTileProvider = tileProvider;
	vMapInfo.zOrder = 3;
	vMapInfo.maxLevel = 17;
	vMapInfo.contentType = kZoomIndependent;
	[self.meMapViewController addMapUsingMapInfo:vMapInfo];
    
    
    self.isRunning = YES;
}

- (void) stop
{
    [self.meMapViewController removeMap:self.name clearCache:YES];
    self.isRunning = NO;
}

@end

@implementation MEIntermittentTileProviderTest
- (id) init
{
    if(self = [super init])
    {
        self.name=@"Intermittent Tiles";
    }
    return self;
}

- (void) start
{
    MEIntermittentTileProvider* tileProvider = [[[MEIntermittentTileProvider alloc]init]autorelease];
	tileProvider.isAsynchronous = NO;
	tileProvider.meMapViewController = self.meMapViewController;
	
	MEVirtualMapInfo* vMapInfo= [[[MEVirtualMapInfo alloc]init]autorelease];
	vMapInfo.name = self.name;
	vMapInfo.meTileProvider = tileProvider;
	vMapInfo.zOrder = 4;
	vMapInfo.maxLevel = 17;
	vMapInfo.contentType = kZoomIndependent;
	[self.meMapViewController addMapUsingMapInfo:vMapInfo];

    self.isRunning = YES;
}
- (void) stop
{
    [self.meMapViewController removeMap:self.name
									clearCache:YES];
    self.isRunning = NO;
}
@end

