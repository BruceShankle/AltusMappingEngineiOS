//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "ContentLoading.h"
#import "../METestManager.h"

@implementation ContentLoading
- (id) init {
	if(self=[super init]){
		self.name = @"Stress - Normal";
        self.tileBiasSmoothingEnabled = YES;
        self.tileLevelBias = 1.0;
        self.initialFPS = 60;
        self.loadingFPS = 60;
        self.maxTilesInFlight = 7;
	}
	return self;
}

-(NSArray*) getOtherTests{
    NSMutableArray* otherTests = [[NSMutableArray alloc]init];
    
    [otherTests addObject:[self.meTestManager testInCategory:@"Core"
                                                    withName:@"Stats"]];
    
    //A CPU intensive fractal pattern
    [otherTests addObject:[self.meTestManager testInCategory:@"Artistic"
                                                    withName:@"Fractal: Workers 4, Sleep 0, Pri Def"]];
    
    //This will load vector map and label layer...
    [otherTests addObject:[self.meTestManager testInCategory:@"Vector Maps"
                                                    withName:@"AltusVectorPackage"]];
    
    //Radar weather tiles from NOAA that are not cached on the device...
    [otherTests addObject:[self.meTestManager testInCategory:@"WMS Maps"
                                                    withName:@"NOAA RIDGERadar"]];
    
    //A long route with a clustered marker layer
    [otherTests addObject:[self.meTestManager testInCategory:@"User Interaction"
                                                    withName:@"Route Plotting"]];
    
    //A couple of hundred random circular polygons and some state polygons
    [otherTests addObject:[self.meTestManager testInCategory:@"Vector Maps"
                                                    withName:@"Polygons"]];
    
    //Map loaing stats
    [otherTests addObject:[self.meTestManager testInCategory:@"Core"
                                                    withName:@"Map Loading Stats"]];
    
    return otherTests;
    
}


-(void) beginTest{
    //Stop all other tests
    [self.meTestManager stopAllTests];
    [self.meMapViewController shutdown];
    self.meMapViewController.maxTilesInFlight = self.maxTilesInFlight;
    [self.meMapViewController initialize];
    self.meMapViewController.greenMode = NO;
    self.oldMapViewDelegate = self.meMapViewController.meMapView.meMapViewDelegate;
    self.meMapViewController.meMapView.meMapViewDelegate = self;
    self.meMapViewController.meMapView.tileLevelBias = self.tileLevelBias;
    self.meMapViewController.meMapView.tileBiasSmoothingEnabled = self.tileBiasSmoothingEnabled;
    self.meMapViewController.preferredFramesPerSecond = self.initialFPS;
    [self.meMapViewController.meMapView setLocation:MELocationMake(-85.475, 57.258, 13870485.394)
                                  animationDuration:0];
    if(self.otherTests==nil){
        self.otherTests = [self getOtherTests];
    }
    
    for(METest* test in self.otherTests){
        [test start];
    }
    
    self.isRunning = YES;
}

-(void) endTest{
    for(METest* test in self.otherTests){
        [test stop];
    }
    self.meMapViewController.meMapView.meMapViewDelegate = self.oldMapViewDelegate;
    self.oldMapViewDelegate = nil;
    
    [self.meMapViewController shutdown];
    self.meMapViewController.maxTilesInFlight = 7;
    [self.meMapViewController initialize];
    self.meMapViewController.meMapView.tileLevelBias = 1.0;
    self.meMapViewController.meMapView.tileBiasSmoothingEnabled = YES;
    self.meMapViewController.preferredFramesPerSecond = 60;
}

- (void) mapView:(MEMapView *)mapView willStartLoadingMap:(NSString*) mapName{
    
    if(self.oldMapViewDelegate){
        [self.oldMapViewDelegate mapView:mapView willStartLoadingMap:mapName];
    }
    
    self.mapsLoadingCount++;
    self.meMapViewController.preferredFramesPerSecond = self.loadingFPS;
}


- (void) mapView:(MEMapView *)mapView didFinishLoadingMap:(NSString*) mapName{
    
    if(self.oldMapViewDelegate){
        [self.oldMapViewDelegate mapView:mapView didFinishLoadingMap:mapName];
    }
    
    self.mapsLoadingCount--;
    if(self.mapsLoadingCount==0){
        self.meMapViewController.preferredFramesPerSecond = self.initialFPS;
    }
}
@end

//////////////////////////////////////////////////////////
@implementation ContentLoadingAdjustPriorities
- (id) init {
	if(self=[super init]){
		self.name = @"Stress - Adjusted Priorites";
	}
	return self;
}

-(void) beginTest{
    [super beginTest];
    
    //Adjust map priorities so that map loading feels more smooth
    
    //Pri 0 - Base vector map
    [self.meMapViewController setMapPriority:@"AltusVectorPackage" priority:1];
    
    //Pri 1 & 2 -  Route info
    [self.meMapViewController setMapPriority:@"Route Plotting" priority:2];
    [self.meMapViewController setMapPriority:@"Route Plotting - Markers" priority:3];
    
    //Pri 3 - Place labels
    [self.meMapViewController setMapPriority:@"Places - Arial" priority:4];
    
    //Pri 4 - Polygons
    [self.meMapViewController setMapPriority:@"Polygons" priority:5];
    
    //Pri 5 - Internet map
    [self.meMapViewController setMapPriority:@"NOAA RIDGERadar" priority:0];
    
    //Lowest priority - CPU intensive fractal
    [self.meMapViewController setMapPriority:@"Fractal: Workers 4, Sleep 0, Pri Def" priority:99];
}
@end

//////////////////////////////////////////////////////////
@implementation ContentLoadingNoBiasDynFPSAdjustPriorities
- (id) init {
	if(self=[super init]){
		self.name = @"Stress - Adjusted Priorites 2";
        self.tileBiasSmoothingEnabled = NO;
        self.tileLevelBias = 0;
        self.initialFPS = 60;
        self.loadingFPS = 15;
	}
	return self;
}
@end;

//////////////////////////////////////////////////////////
@implementation ContentLoadingNoBias
- (id) init {
	if(self=[super init]){
		self.name = @"Stress No Bias";
        self.tileBiasSmoothingEnabled = NO;
        self.tileLevelBias = 0;
	}
	return self;
}
@end;

//////////////////////////////////////////////////////////
@implementation ContentLoadingNoBiasDynFPS
- (id) init {
	if(self=[super init]){
		self.name = @"Stress No Bias, DynFPS";
        self.tileBiasSmoothingEnabled = NO;
        self.tileLevelBias = 0;
        self.initialFPS = 30;
        self.loadingFPS = 8;
	}
	return self;
}
@end;

//////////////////////////////////////////////////////////
@implementation ContentLoadingNoBiasDynFPSTIF
- (id) init {
	if(self=[super init]){
		self.name = @"Stress No Bias, DynFPS, TIF";
        self.tileBiasSmoothingEnabled = NO;
        self.tileLevelBias = 0;
        self.initialFPS = 30;
        self.loadingFPS = 8;
        self.maxTilesInFlight = 100;
	}
	return self;
}
@end;
