//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "AltusRasterPackage.h"

@implementation AltusRasterPackage

-(id) init{
    if(self=[super init]){
        self.name = @"AltusRasterPackage";
    }
    return self;
}

- (void) start{
    
    if(self.isRunning){
        return;
    }
    
    //Get map package name
    NSString* packageFileName = [[NSBundle mainBundle] pathForResource:@"AltusRasterPackage"
                                                                ofType:@"sqlite"];
    
    //Add the map
    [self.meMapViewController setMaxVirtualMapParentSearchDepth:20];
    [self.meMapViewController addPackagedMap:self.name packageFileName:packageFileName];
    [self.meMapViewController setMapZOrder:self.name zOrder:10];
    [self.meMapViewController setMapAlpha:self.name  alpha:0.5];
       
    
	self.isRunning = YES;
}

- (void) stop{
    
    if(!self.isRunning){
        return;
    }
    
	[self.meMapViewController removeMap:self.name
							 clearCache:YES];
    
	self.isRunning = NO;
}

@end

