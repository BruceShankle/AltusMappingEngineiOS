//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "AltusTerrainPackage.h"

@implementation AltusTerrainPackage

-(id) init{
    if(self=[super init]){
        self.name = @"Altus Terrain Package";
    }
    return self;
}

- (void) beginTest{
    
    //Stop tests that obscure or affect this one
    [self.meTestManager stopBaseMapTests];
    
    //Get map package name
    NSString* packageFileName = [[NSBundle mainBundle] pathForResource:@"AltusTerrainPackage"
                                                                ofType:@"sqlite"];
    
    //Add the map
    [self.meMapViewController addPackagedMap:self.name packageFileName:packageFileName];
    [self.meMapViewController setMapZOrder:self.name zOrder:11];
}

- (void) endTest{
	[self.meMapViewController removeMap:self.name
							 clearCache:YES];
}
@end

