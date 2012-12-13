//
//  InternetMaps.m
//  Mapp
//
//  Created by Bruce Shankle III on 9/27/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MEInternetMaps.h"
#import "MEInternetTileProvider.h"

////////////////////////////////////////////////////////////////////////
@implementation MEInternetMap

@synthesize maxLevel;
@synthesize compressTextures;

- (id) init
{
    if(self = [super init])
    {
		self.maxLevel=17;
		self.zoomIndependent = NO;
        self.name=@"ME Internet Map";
		self.zOrder = 2;
		self.compressTextures = NO;
    }
    return self;
}

+(NSString*) tileCacheRoot
{
	return @"MEInternetMapTests";
}
-(METileProvider*) createTileProvider
{
	NSLog(@"MEInternetMapTest:createTileProvider:You should override this");
	exit(0);
}

- (void) show
{
	//Create the tile provider (overridden by sub-classes)
	MEInternetTileProvider* tileProvider = [self createTileProvider];
	tileProvider.tileCacheRoot = [MEInternetMap tileCacheRoot];
    tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.isAsynchronous = NO;
	
	//Add a virtual map using the tile provider
	MEVirtualMapInfo* vMapInfo = [[[MEVirtualMapInfo alloc]init]autorelease];
	vMapInfo.name = self.name;
	vMapInfo.meTileProvider = tileProvider;
	vMapInfo.isSlippyMap = YES;
	vMapInfo.zOrder = self.zOrder;
	vMapInfo.maxLevel = self.maxLevel;
	//vMapInfo.defaultTileName = @"grayGrid";
	vMapInfo.loadingStrategy = kHighestDetailOnly;
	if(self.zoomIndependent)
		vMapInfo.contentType = kZoomIndependent;
	else
		vMapInfo.contentType = kZoomDependent;
	vMapInfo.compressTextures = self.compressTextures;
	[self.meMapViewController addMapUsingMapInfo:vMapInfo];
	
	
	[tileProvider release];
}

- (void) mapView:(MEMapView *)mapView didFinishLoadingMap:(NSString *)mapName
{
	if(self.loadInvisible)
	{
		NSLog(@"Setting map to visible after loading is complete.");
		[self.meMapViewController setMapIsVisible:self.name isVisible:YES];
		self.loadInvisible = NO;
	}
}

- (void) hide
{
    [self.meMapViewController removeMap:self.name
                                    clearCache:NO];
}

@end

////////////////////////////////////////////////////////////////////////
@implementation MEMapBoxMap

- (id) init
{
    if(self = [super init])
    {
        self.name=@"MapBox";
    }
    return self;
}

-(MEInternetTileProvider*) createTileProvider
{
	return [[MEMapBoxTileProvider alloc]init];
}
@end

////////////////////////////////////////////////////////////////////////
@implementation MEMapBoxLandCoverStreetMap

- (id) init
{
    if(self = [super init])
    {
        self.name=@"MapBox LandCover";
    }
    return self;
}

-(MEInternetTileProvider*) createTileProvider
{
	return [[MEMapBoxLandCoverTileProvider alloc]init];
}
@end

////////////////////////////////////////////////////////////////////////
@implementation MEMapBoxLandSatMap

- (id) init
{
    if(self = [super init])
    {
        self.name=@"MapBox LandSat";
    }
    return self;
}

-(MEInternetTileProvider*) createTileProvider
{
	return [[MEMapBoxLandSatTileProvider alloc]init];
}
@end