//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "Places.h"

@implementation Places

- (id) init {
	if(self=[super init]){
		self.name = @"Places";
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
	UIImage* image = [MEFontUtil newImageWithFont:@"ArialMT"
                                         fontSize:15
                                        fillColor:[UIColor blackColor]
                                      strokeColor:[UIColor whiteColor]
                                      strokeWidth:1.0
                                             text:marker.metaData];
	marker.uiImage = image;
	marker.anchorPoint = CGPointMake(image.size.width/2,
                                     image.size.height/2);
    marker.hitTestSize = image.size;
}

-(void) tapOnMarker:(NSString *)metaData
          onMapView:(MEMapView *)mapView
      atScreenPoint:(CGPoint)point{
    NSLog(@"You tapped on marker %@.", metaData);
}

@end
