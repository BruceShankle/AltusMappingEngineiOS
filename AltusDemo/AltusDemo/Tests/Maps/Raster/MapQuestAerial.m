//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "MapQuestAerial.h"
#import "../../Utilities/MapFactory.h"

@implementation MapQuestAerial

-(id) init{
    if(self=[super init]){
        self.name = @"MapQuest Aerial - Raster";
        self.urlTemplate = @"http://otile1.mqcdn.com/tiles/1.0.0/sat/{z}/{x}/{y}.jpg";
    }
    return self;
}

- (void) beginTest{
    
    ///Stop tests that obscure or affect this one
    [self.meTestManager stopBaseMapTests];
    
    
    //Add the map
    [self.meMapViewController addMapUsingMapInfo:
     [MapFactory createInternetMapInfo:self.meMapViewController
                               mapName:self.name
                           urlTemplate:self.urlTemplate
                            subDomains:@""
                              maxLevel:20
                                zOrder:2
                            numWorkers:3
                           enableAlpha:NO]];
}

- (void) endTest{
	[self.meMapViewController removeMap:self.name
							 clearCache:NO];
}


@end
