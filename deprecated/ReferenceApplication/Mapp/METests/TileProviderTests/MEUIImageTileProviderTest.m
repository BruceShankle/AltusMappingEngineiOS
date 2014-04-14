//
//  MEUIImageTileProviderTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/17/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MEUIImageTileProviderTest.h"
#import "MEInternetTileProvider.h"
#import "METestCategory.h"

@implementation MEUIImageTileProviderTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"UIImage Tile Provider";
    }
    return self;
}


- (void) start
{
	[self.meTestCategory stopAllTests];
	MEMapBoxTileProvider* tileProvider = [[[MEMapBoxTileProvider alloc]init]autorelease];
	
	tileProvider.returnUIImages = YES;
    tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.isAsynchronous = NO;
	
	MEVirtualMapInfo* vMapInfo= [[[MEVirtualMapInfo alloc]init]autorelease];
	vMapInfo.name = self.name;
	vMapInfo.meTileProvider = tileProvider;
	vMapInfo.zOrder = 2;
	vMapInfo.maxLevel = 17;
	vMapInfo.contentType = kZoomDependent;
	
    
    self.isRunning = YES;
}

- (void) stop
{
    [self.meMapViewController removeMap:self.name
                                    clearCache:YES];
    self.isRunning = NO;
}

@end


////////////////////////////////////////////////////////////////////////////////////
@implementation MEAsyncUIImageTileProviderTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Async UIImage Tile Provider";
    }
    return self;
}

- (void) start
{
	
    MEAsyncInternetTileProvider* tileProvider = [[[MEAsyncInternetTileProvider alloc]init]autorelease];
    tileProvider.returnUIImages = YES; //This is what we are testing in this case.
    tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.isAsynchronous = YES;
	
	MEVirtualMapInfo* vMapInfo= [[[MEVirtualMapInfo alloc]init]autorelease];
	vMapInfo.name = self.name;
	vMapInfo.meTileProvider = tileProvider;
	vMapInfo.zOrder = 2;
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

