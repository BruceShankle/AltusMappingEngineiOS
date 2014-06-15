//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "AltusRasterPackage.h"
#import "../../Utilities/MapFactory.h"

///////////////////////////////////////////////////////////////////////////
@implementation AltusRasterPackageNative

-(id) init{
    if(self=[super init]){
        self.name = @"Package - Native";
        self.pacakgeFileName = [[NSBundle mainBundle] pathForResource:@"AltusRasterPackage"
                                                               ofType:@"sqlite"];
    }
    return self;
}

- (void) addMap{
    [self.meMapViewController setMaxVirtualMapParentSearchDepth:20];
    [self.meMapViewController addPackagedMap:self.name
                             packageFileName:self.pacakgeFileName];
    [self.meMapViewController setMapZOrder:self.name zOrder:10];
}

- (void) removeMap{
    [self.meMapViewController removeMap:self.name
							 clearCache:YES];
}

//Don't enable if other test is running
-(BOOL) isEnabled{
    METest* otherTest = [self.meTestCategory testWithName:@"Package - Custom"];
    return(!otherTest.isRunning);
}

- (void) beginTest{
    [self addMap];
}

- (void) endTest{
    [self removeMap];
}
@end

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
@implementation AltusRasterPackageCustom

-(id) init{
    if(self=[super init]){
        self.name = @"Package - Custom";
        self.pacakgeFileName = [[NSBundle mainBundle] pathForResource:@"AltusRasterPackage"
                                                               ofType:@"sqlite"];
    }
    return self;
}

- (void) addMap{
    [self.meMapViewController setMaxVirtualMapParentSearchDepth:20];
    [self.meMapViewController addMapUsingMapInfo:
     [MapFactory createRasterPackageMapInfo:self.meMapViewController
                                    mapName:self.name
                            packageFileName:self.pacakgeFileName
                        isSphericalMercator:NO
                                     zOrder:10
                                 numWorkers:3]
     ];
}

- (void) removeMap{
    [self.meMapViewController removeMap:self.name
                             clearCache:YES];
}

//Don't enable if other test is running
-(BOOL) isEnabled{
    METest* otherTest = [self.meTestCategory testWithName:@"Package - Native"];
    return(!otherTest.isRunning);
}

- (void) beginTest{
    [self addMap];
}

- (void) endTest{
    [self removeMap];
}

@end
