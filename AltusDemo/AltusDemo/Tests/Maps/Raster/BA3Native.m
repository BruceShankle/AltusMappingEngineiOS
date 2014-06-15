//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "BA3Native.h"

@implementation BA3NativeAcadia

-(id) init{
    if(self=[super init]){
        self.name = @"BA3 Native - Raster";
        self.alreadyZoomed = NO;
    }
    return self;
}

- (void) beginTest{
    
	//Stop tests that obscure or affect this one
    [self.meTestManager stopBaseMapTests];
	
    NSString* sqliteFile = [[NSBundle mainBundle] pathForResource:@"Acadia"
                                                           ofType:@"sqlite"];
    
    NSString* mapFile = [[NSBundle mainBundle] pathForResource:@"Acadia"
                                                        ofType:@"map"];
    
    [self.meMapViewController addMap:self.name
                   mapSqliteFileName:sqliteFile
                     mapDataFileName:mapFile
                    compressTextures:NO];
    
    [self.meMapViewController setMapZOrder:self.name zOrder:2];
    
    //Look at map bounds the first time this map is shown
    if(!self.alreadyZoomed){
        [self.meMapViewController.meMapView lookAtCoordinate:CLLocationCoordinate2DMake(44.2206,-68.503876)
                                               andCoordinate:CLLocationCoordinate2DMake(44.45633,-68.14682)
                                        withHorizontalBuffer:10
                                          withVerticalBuffer:10
                                           animationDuration:1.0];
        self.alreadyZoomed = YES;
    }
}

- (void) endTest{
	[self.meMapViewController removeMap:self.name
							 clearCache:NO];
}


@end
