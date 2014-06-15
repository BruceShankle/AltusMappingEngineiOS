//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "Places.h"

@implementation Places

- (id) init {
	if(self=[super init]){
		self.name = @"Places - Arial";
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

- (void) beginTest{
	[self addMap];
}

- (void) endTest{
	[self removeMap];
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

///////////////////////////////////////////////////////////
@implementation PlacesAvenir

- (id) init {
	if(self=[super init]){
		self.name = @"Places - Avenir";
	}
	return self;
}

- (void) mapView:(MEMapView *)mapView
    updateMarker:(MEMarker *)marker
		 mapName:(NSString *)mapName{
    
    UIImage* image = [MEFontUtil newImageWithFontOutlined:@"AvenirNext-Bold"
                                                 fontSize:20.0
                                                fillColor:[UIColor colorWithRed:9/255.0
                                                                          green:49/255.0
                                                                           blue:56/255.0
                                                                          alpha:1.0]
                                              strokeColor:[UIColor whiteColor]
                                              strokeWidth:2.0
                                                     text:marker.metaData];
	marker.uiImage = image;
	marker.anchorPoint = CGPointMake(image.size.width/2,
                                     image.size.height/2);
    marker.hitTestSize = image.size;
}

@end
