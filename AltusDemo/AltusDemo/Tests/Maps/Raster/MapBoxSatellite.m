//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "MapBoxSatellite.h"
#import "../../Utilities/MapFactory.h"

@implementation MapBoxSatellite

-(id) init{
    if(self=[super init]){
        self.name = @"MapBox Satellite";
        self.urlTemplate = @"http://{s}.tiles.mapbox.com/v3/dxjacob.ho6k3ag9/{z}/{x}/{y}.jpg";
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
                              useCache:YES
                           enableAlpha:NO]];
}

- (void) endTest{
	[self.meMapViewController removeMap:self.name
							 clearCache:NO];
}
@end
