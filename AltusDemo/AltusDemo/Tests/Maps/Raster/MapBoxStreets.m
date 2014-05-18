//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "MapBoxStreets.h"
#import "../../Utilities/MapFactory.h"
@implementation MapBoxStreets

-(id) init{
    if(self=[super init]){
        self.name = @"MapBox Streets - Raster";
        
        //self.urlTemplate = @"https://www.mygdc.com/new/mapserver_proxy.php?product=vfr_usa_near&location=cache&z={z}&x={x}&y={y}.png";
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
    
    //Add the map
    [self.meMapViewController addMapUsingMapInfo:
     [MapFactory createInternetMapInfo:self.meMapViewController
                               mapName:self.name
                           urlTemplate:self.urlTemplate
                            subDomains:@"a,b,c,d"
                              maxLevel:11
                                zOrder:2
                            numWorkers:3
                           enableAlpha:NO]];
	
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
