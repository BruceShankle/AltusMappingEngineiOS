//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "MapQuestAerial.h"
#import "RasterTileProvider.h"

@implementation MapQuestAerial

-(id) init{
    if(self=[super init]){
        self.name = @"MapQuest Aerial - Raster";
        self.urlTemplate = @"http://otile1.mqcdn.com/tiles/1.0.0/sat/{z}/{x}/{y}.jpg";
    }
    return self;
}

- (void) start{
    
    if(self.isRunning){
        return;
    }
    
    //Stop tests that obscure or affect this one
    [self.meTestManager stopCategory:@"Terrain"];
    [self.meTestManager stopCategory:@"Maps"];
    
    //Create tile provider
    RasterTileProvider* tileProvider = [[RasterTileProvider alloc] initWithURLTemplate:self.urlTemplate
                                                                            queueCount:8];
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
