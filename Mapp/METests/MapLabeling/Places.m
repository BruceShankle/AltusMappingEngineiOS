//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "Places.h"
#import "../METestCategory.h"

@implementation Places

- (id) init {
	if(self=[super init]){
		self.name = @"Places - Plain Style";
	}
	return self;
}

- (void) start{
	if(self.isRunning){
		return;
	}
	
	//Turn off all other label layers
	[self.meTestCategory stopAllTests];
	
	//Add marker layer
	[self addMarkerMap];
	
	self.isRunning = YES;
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
	[self removeMarkerMap];
	self.isRunning = NO;
}

- (void) addMarkerMap{
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeFileMarker;
	mapInfo.sqliteFileName = [[NSBundle mainBundle] pathForResource:@"Places"
															 ofType:@"sqlite"];
	mapInfo.zOrder = 21;
	mapInfo.meMarkerMapDelegate = self;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

- (void) removeMarkerMap{
	[self.meMapViewController removeMap:self.name clearCache:NO];
}

- (void) mapView:(MEMapView *)mapView
updateMarkerInfo:(MEMarkerInfo *)markerInfo
		 mapName:(NSString *)mapName{
	UIImage* image = [MEFontUtil newImageWithFont:@"ArialMT"
						fontSize:15
					   fillColor:[UIColor blackColor]
					 strokeColor:[UIColor whiteColor]
					 strokeWidth:1.0
							text:markerInfo.metaData];
	markerInfo.uiImage = image;
	markerInfo.anchorPoint = CGPointMake(image.size.width/2,
										image.size.height/2);
	
	
}

@end
