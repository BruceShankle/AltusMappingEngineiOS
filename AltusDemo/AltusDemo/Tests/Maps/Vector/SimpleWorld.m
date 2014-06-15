//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "SimpleWorld.h"

@implementation SimpleWorld

-(id) init{
    if(self=[super init]){
        self.name = @"Simple";
        self.packageFileName = [[NSBundle mainBundle] pathForResource:@"SimpleWorld"
                                                               ofType:@"sqlite"];
        self.showLabels = YES;
    }
    return self;
}

- (void) enableLabels:(BOOL) enabled{
    METest* labels= [self.meTestManager testInCategory:@"Markers"
                                              withName:@"Places - Avenir"];
    
    if(enabled)
        [labels start];
    else
        [labels stop];
}

- (void) addMap{
    //Add the map
    [self.meMapViewController addPackagedMap:self.name packageFileName:self.packageFileName];
    
    //Turn on labels
    if(self.showLabels){
        [self enableLabels:YES];
    }
}

- (void) removeMap{
    [self.meMapViewController removeMap:self.name
							 clearCache:YES];
    
    //Turn off labels
    if(self.showLabels){
        [self enableLabels:NO];
    }
}

- (void) beginTest{
    //Stop tests that obscure or affect this one
    [self.meTestManager stopBaseMapTests];
    [self addMap];
}

- (void) endTest{
	[self removeMap];
}
@end


/////////////////////////////////////////////////////////////////////////////
@implementation SimpleWorldBenchmarkBias

-(id) init{
    if(self=[super init]){
        self.name = @"Simple Benchmark - Bias On";
        self.tileBiasSmoothingEnabled = YES;
        self.tileLevelBias = 1.0;
        self.showLabels = NO;
    }
    return self;
}

- (void) beginTest{
    
    [self setMessageText:@"Loading..."];
    
    //Store old bias settings
    self.oldTileBiasSmoothingEnabled = self.meMapViewController.meMapView.tileBiasSmoothingEnabled;
    self.oldTileLevelBias=self.meMapViewController.meMapView.tileLevelBias;
    
    //Update bias settings
    self.meMapViewController.meMapView.tileBiasSmoothingEnabled = self.tileBiasSmoothingEnabled;
    self.meMapViewController.meMapView.tileLevelBias = self.tileLevelBias;
    
    //Move camera to a location where lots of tiles will be displayed
    self.meMapViewController.meMapView.location = MELocationMake(-85.874322,
                                                                 66.259353,
                                                                 13456455);
    
    [self.meTestManager stopBaseMapTests];
    self.oldDelegate = self.meMapViewController.meMapView.meMapViewDelegate;
    self.meMapViewController.meMapView.meMapViewDelegate = self;
    [self addMap];
}

- (void) mapView:(MEMapView *)mapView willStartLoadingMap:(NSString *)mapName{
    [self startBenchmarkTimer];
}

- (void) mapView:(MEMapView *)mapView didFinishLoadingMap:(NSString*) mapName{
    long elapsed = [self stopBenchMarkTimer];
    [self setMessageText:[NSString stringWithFormat:@"%ld ms", elapsed]];
    [self removeMap];
    if(self.isRunning){
        [self addMap];
    }
}

- (void) endTest{
    [super endTest];
    //Restore biasing to former values
    self.meMapViewController.meMapView.tileLevelBias = self.oldTileLevelBias;
    self.meMapViewController.meMapView.tileBiasSmoothingEnabled = self.oldTileBiasSmoothingEnabled;
    self.meMapViewController.meMapView.meMapViewDelegate = self.oldDelegate;
}

@end

/////////////////////////////////////////////////////////////////////////////
@implementation SimpleWorldBenchmarkNoBias
-(id) init{
    if(self=[super init]){
        self.name = @"Simple Benchmark - Bias Off";
        self.tileLevelBias = 0;
        self.tileBiasSmoothingEnabled = NO;
    }
    return self;
}
@end
