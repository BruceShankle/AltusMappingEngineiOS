//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "AltusVectorPackage.h"

@implementation AltusVectorPackage

-(id) init{
    if(self=[super init]){
        self.name = @"AltusVectorPackage";
    }
    return self;
}

- (void) enableLabels:(BOOL) enabled{
    METest* labels= [self.meTestManager testInCategory:@"Markers"
                                              withName:@"Places"];
    
    if(enabled)
        [labels start];
    else
        [labels stop];
}

- (void) start{
    
    if(self.isRunning){
        return;
    }
    
    //Stop tests that obscure or affect this one
    [self.meTestManager stopBaseMapTests];
    
    //Get map package name
    NSString* packageFileName = [[NSBundle mainBundle] pathForResource:@"AltusVectorPackage"
                                                           ofType:@"sqlite"];
    
    //Add the map
    [self.meMapViewController addPackagedMap:self.name packageFileName:packageFileName];
    
    //Set the zOrder
    [self.meMapViewController setMapZOrder:self.name zOrder:2];
    
    [self lookAtUnitedStates];
    
    //Turn on labels
    [self enableLabels:YES];
    
	self.isRunning = YES;
}

- (void) stop{
    
    if(!self.isRunning){
        return;
    }
    
	[self.meMapViewController removeMap:self.name
							 clearCache:NO];
    
    //Turn off labels
    [self enableLabels:NO];
    
	self.isRunning = NO;
}

@end

