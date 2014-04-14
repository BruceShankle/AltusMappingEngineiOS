//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "Towers.h"

@implementation Towers

- (id) init {
	if(self=[super init]){
		self.name = @"Towers";
        self.interval = 1;
	}
	return self;
}

- (void) addMap{
	
	MEMarkerMapInfo* mapInfo = [[MEMarkerMapInfo alloc]init];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeFileMarker;
	mapInfo.sqliteFileName = [[NSBundle mainBundle] pathForResource:@"Towers"
															 ofType:@"sqlite"];
	mapInfo.zOrder = 50;
	mapInfo.meMarkerMapDelegate = self;
    mapInfo.fadeEnabled = false;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
    
}

- (void) removeMap{
    [self.meMapViewController removeMap:self.name clearCache:YES];
}

- (void) start{
	if(self.isRunning){
		return;
	}
    
    [self.meMapViewController shutdown];
    self.meMapViewController.coreCacheSize = 22000000.0 * 1;
	[self.meMapViewController initialize];
    
    [self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"Tower"]
                                          withName:@"Tower"
                                   compressTexture:YES
                    nearestNeighborTextureSampling:NO];
	[self addMap];
	[self startTimer];
	self.isRunning = YES;
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
    [self stopTimer];
	[self removeMap];
	self.isRunning = NO;
}

- (void) timerTick{
    [self removeMap];
    [self addMap];
}

- (void) mapView:(MEMapView *)mapView
updateMarkerInfo:(MEMarkerInfo *)markerInfo
		 mapName:(NSString *)mapName{
	markerInfo.cachedImageName=@"Tower";
	markerInfo.anchorPoint = CGPointMake(14,25);
}

@end
