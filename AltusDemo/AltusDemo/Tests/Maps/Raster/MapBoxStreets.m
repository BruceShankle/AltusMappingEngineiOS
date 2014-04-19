//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "MapBoxStreets.h"
#import "RasterTileProvider.h"

@implementation MapBoxStreets

-(id) init{
    if(self=[super init]){
        self.name = @"MapBox Streets - Raster";
        self.urlTemplate = @"http://{s}.tiles.mapbox.com/v3/dxjacob.map-s5qr595q/{z}/{x}/{y}.png";
    }
    return self;
}

- (void) start{
    
    if(self.isRunning){
        return;
    }
    
    //Stop tests that obscure or affect this one
    [self.meTestManager stopBaseMapTests];
    
    //Create tile provider
    RasterTileProvider* tileProvider = [[RasterTileProvider alloc]initWithURLTemplate:self.urlTemplate
                                                                           queueCount:8];
    
    //Add subdomains
    [tileProvider.subDomains addObject:@"a"];
    [tileProvider.subDomains addObject:@"b"];
    [tileProvider.subDomains addObject:@"c"];
    [tileProvider.subDomains addObject:@"d"];
    
    tileProvider.meMapViewController = self.meMapViewController;
    
    //Create virtual map info
    MEVirtualMapInfo* virtualMapInfo = [[MEVirtualMapInfo alloc]init];
    virtualMapInfo.name = self.name;
    virtualMapInfo.maxLevel = 20;
    virtualMapInfo.isSphericalMercator = YES;
    virtualMapInfo.meTileProvider = tileProvider;
    virtualMapInfo.meMapViewController = self.meMapViewController;
    virtualMapInfo.zOrder = 2;
    virtualMapInfo.loadingStrategy = kHighestDetailOnly;
    virtualMapInfo.contentType = kZoomDependent;
    
    //Add the map
    [self.meMapViewController addMapUsingMapInfo:virtualMapInfo];
	
	self.isRunning = YES;
}

- (void) stop{
    
    if(!self.isRunning){
        return;
    }
    
	[self.meMapViewController removeMap:self.name
							 clearCache:NO];
	self.isRunning = NO;
}


@end
