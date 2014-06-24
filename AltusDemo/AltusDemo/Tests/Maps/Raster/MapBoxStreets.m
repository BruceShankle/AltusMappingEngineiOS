//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "MapBoxStreets.h"
#import "../../Utilities/MapFactory.h"
@implementation MapBoxStreets

-(id) init{
    if(self=[super init]){
        self.name = @"MapBox Streets";
        self.urlTemplate = @"http://{s}.tiles.mapbox.com/v3/dxjacob.map-s5qr595q/{z}/{x}/{y}.png";
        self.useNetworkCache = YES;
    }
    return self;
}

- (void) beginTest{
    
    //Stop tests that obscure or affect this one
    [self.meTestManager stopBaseMapTests];
    
    //Add the map
    [self.meMapViewController addMapUsingMapInfo:
     [MapFactory createInternetMapInfo:self.meMapViewController
                               mapName:self.name
                           urlTemplate:self.urlTemplate
                            subDomains:@"a,b,c,d"
                              maxLevel:20
                                zOrder:2
                            numWorkers:3
                              useCache:self.useNetworkCache
                           enableAlpha:NO]];
}

- (void) endTest{
	[self.meMapViewController removeMap:self.name
							 clearCache:NO];
}
@end

@implementation MapBoxStreetsNoCache

-(id) init{
    if(self=[super init]){
        self.name = @"MapBox Streets - No Cache";
        self.useNetworkCache = NO;
    }
    return self;
}

- (void) endTest{
	[self.meMapViewController removeMap:self.name
							 clearCache:YES];
}

@end

