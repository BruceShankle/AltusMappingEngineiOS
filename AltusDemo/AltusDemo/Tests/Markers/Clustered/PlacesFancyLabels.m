//  Copyright (c) 2014 BA3, LLC. All rights reserved.
//Demonstrates a clustered marker layer with fancy custom labels.
//Feel free to use this code or portions of it as you wish your applications.

#import "PlacesFancyLabels.h"
#import "../MarkerImageCreators/WayPointMarkerImage.h"

@implementation PlacesFancyLabels

- (id) init {
	if(self=[super init]){
		self.name = @"Places - Fancy Labels";
	}
	return self;
}

- (void) addMap{
	
	MEMarkerMapInfo* mapInfo = [[MEMarkerMapInfo alloc]init];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeFileMarker;
	mapInfo.sqliteFileName = [[NSBundle mainBundle] pathForResource:@"Places"
															 ofType:@"sqlite"];
	mapInfo.zOrder = 100;
	mapInfo.meMarkerMapDelegate = self;
    mapInfo.hitTestingEnabled = YES;
    mapInfo.fadeOutTime = 1.0;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
    
}

- (void) removeMap{
    [self.meMapViewController removeMap:self.name clearCache:NO];
}

- (void) start{
	if(self.isRunning){
		return;
	}
	[self addMap];
	self.isRunning = YES;
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
	[self removeMap];
	self.isRunning = NO;
}


- (void) mapView:(MEMapView *)mapView
    updateMarker:(MEMarker *)marker
		 mapName:(NSString *)mapName{
	
    //Create a custom marker image (and get is anchor point)
    CGPoint anchorPoint;
    UIImage* markerImage = [WayPointMarkerImage createCustomMarkerImage:marker.metaData
                                                            anchorPoint:&anchorPoint];
    
    //Return the custom marker image and anchor point to the mapping engine
    marker.uiImage = markerImage;
    marker.anchorPoint = anchorPoint;
}

-(void) tapOnMarker:(NSString *)metaData
          onMapView:(MEMapView *)mapView
      atScreenPoint:(CGPoint)point{
    NSLog(@"You tapped on marker %@.", metaData);
}

@end

