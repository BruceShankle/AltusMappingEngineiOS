//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "Stats.h"

@implementation Stats

- (id) init {
	if(self=[super init]){
        self.name=@"Stats";
        self.interval = 0.1;
	}
	return self;
}

-(void) addUI{
    if(self.lblStats==nil){
        self.lblStats = [[UILabel alloc]initWithFrame:CGRectMake(10,50,300,300)];
        [self.lblStats setTextColor:[UIColor whiteColor]];
        [self.lblStats setBackgroundColor:[UIColor clearColor]];
        self.lblStats.shadowColor = [UIColor blackColor];
        self.lblStats.shadowOffset=CGSizeMake(2.0,2.0);
        self.lblStats.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.lblStats.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.lblStats.layer.shadowRadius = 1.0;
        self.lblStats.layer.shadowOpacity = 1.0;
        self.lblStats.adjustsFontSizeToFitWidth=NO;
        [self.lblStats setFont:[UIFont boldSystemFontOfSize:18.0f]];
        self.lblStats.numberOfLines = 15;
        self.lblStats.lineBreakMode = NSLineBreakByWordWrapping;
        [self.meMapViewController.meMapView addSubview:self.lblStats];
        [self.meMapViewController.meMapView bringSubviewToFront:self.lblStats];
    }
}

-(void) removeUI{
    [self.lblStats removeFromSuperview];
    self.lblStats = nil;
}

-(void) beginTest{
    [self addUI];
    [self startTimer];
}

-(void) timerTick{
    CLLocationCoordinate2D currentLocation = self.meMapViewController.meMapView.centerCoordinate;
    MEInfo* meInfo = self.meMapViewController.meInfo;
    NSString* cameraIsMoving;
    if(meInfo.cameraIsMoving){
        cameraIsMoving=@"Yes";
    }
    else{
        cameraIsMoving=@"No";
    }
    
    self.lblStats.text=[NSString stringWithFormat:
                        @"FPS:  %f\n"
                        "Draw Calls:  %d\n"
                        "RAM:  %.1f MB\n"
                        "Cache:  %.1f MB\n"
                        "Tile Count:  %d\n"
                        "Tiles In Flight:  %d\n"
                        "Multi-Tiles:  %d\n"
                        "QTotal:  %d\n"
                        "Center:  (%.3f, %.3f)\n"
                        "Visible Tiles:  %d\n"
                        "Animation Count:  %d\n"
                        "Updateables Count:  %d\n"
                        "Camera Moving:  %@",
                        meInfo.frameRate,
                        meInfo.drawCallsPerFrame,
                        (float)meInfo.appMemoryUsage / 1000000.0f,
                        (float)meInfo.tileCacheMemorySize / 1000000.0f,
                        meInfo.tileCacheTileCount,
                        meInfo.inFlightTileCount,
                        meInfo.multiInFlightTileCount,
                        meInfo.totalWorkerCount,
                        currentLocation.longitude,
                        currentLocation.latitude,
                        meInfo.visibleTileCount,
						meInfo.animationCount,
						meInfo.updateablesCount,
						cameraIsMoving];
}

-(void) endTest{
    [self removeUI];
}

@end
