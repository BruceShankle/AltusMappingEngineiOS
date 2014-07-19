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
                                              withName:@"Places - Arial"];
    
    if(enabled){
        [labels start];
    }
    else
        [labels stop];
}

- (void) beginTest{
    
    //Stop tests that obscure or affect this one
    [self.meTestManager stopBaseMapTests];
    
    //Get map package name
    NSString* packageFileName = [[NSBundle mainBundle] pathForResource:@"AltusVectorPackage"
                                                           ofType:@"sqlite"];
    
    //Add the map
    [self.meMapViewController addPackagedMap:self.name packageFileName:packageFileName];
    
    //Set the zOrder
    [self.meMapViewController setMapZOrder:self.name zOrder:2];
    
    //Turn on labels
    [self enableLabels:YES];
}

- (void) endTest{
	[self.meMapViewController removeMap:self.name
							 clearCache:NO];
    
    //Turn off labels
    [self enableLabels:NO];
    
}
@end


///////////////////////////////////////////////////////////////////
@implementation AltusVectorPackageBenchmark

-(id) init{
    if(self=[super init]){
        self.name = @"AltusVectorPackage - Benchmark";
        self.initialFPS = 60;
        self.loadingFPS = 30;
    }
    return self;
}

- (void) enableLabels:(BOOL) enabled{
}

- (void) beginTest{
    
    [super beginTest];
    [self.meMapViewController setMapIsVisible:self.name isVisible:false];
    self.oldMapViewDelegate = self.meMapViewController.meMapView.meMapViewDelegate;
    self.meMapViewController.meMapView.meMapViewDelegate = self;
    //[self.meMapViewController setMapPriority:self.name priority:1];
    //self.meMapViewController.meMapView.tileLevelBias = 0.0;
    //self.meMapViewController.meMapView.tileBiasSmoothingEnabled = NO;
}

- (void) endTest{
    [super endTest];
    self.meMapViewController.meMapView.meMapViewDelegate = self.oldMapViewDelegate;
    self.oldMapViewDelegate = nil;
}

- (void) mapView:(MEMapView *)mapView willStartLoadingMap:(NSString*) mapName{
    
    NSLog(@"Will start loading: %@", mapName);
    
    if(self.oldMapViewDelegate){
        [self.oldMapViewDelegate mapView:mapView willStartLoadingMap:mapName];
    }
    
    if([mapName isEqualToString:self.name]){
        [self startBenchmarkTimer];
    }
    
    //self.meMapViewController.preferredFramesPerSecond = self.loadingFPS;
    self.mapsLoadingCount++;
}


- (void) mapView:(MEMapView *)mapView didFinishLoadingMap:(NSString*) mapName{
    
    NSLog(@"Did finish loading: %@", mapName);
    
    if(self.oldMapViewDelegate){
        [self.oldMapViewDelegate mapView:mapView didFinishLoadingMap:mapName];
    }
    
    if([mapName isEqualToString:self.name]){
        long elapsedTime = [self stopBenchMarkTimer];
        NSString* msg = [NSString stringWithFormat:@"Loading time: %lds",elapsedTime/1000];
        [self showAlert:msg timeout:5];
        NSLog(msg);
    }
    
    self.mapsLoadingCount--;
    if(self.mapsLoadingCount==0){
        //self.meMapViewController.preferredFramesPerSecond = self.initialFPS;
    }
}

@end


