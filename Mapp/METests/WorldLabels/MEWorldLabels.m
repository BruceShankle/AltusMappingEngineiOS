//  Copyright (c) 2013 BA3, LLC. All rights reserved.

#import "MEWorldLabels.h"

@implementation MEWorldLabels

- (id) init {
	if(self=[super init]){
		self.name = @"World Labels";
	}
	return self;
}

- (void) addMap {
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeFileMarker;
	mapInfo.zOrder = 100;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.sqliteFileName = [NSString stringWithFormat:@"%@/Markers.sqlite",[METest getDocumentsPath]];
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

- (void) start {
	if(self.isRunning){
		return;
	}
	[self addMap];
	self.isRunning = YES;
}

- (void) stop {
	if(!self.isRunning){
		return;
	}
	[self.meMapViewController removeMap:self.name clearCache:YES];
	self.isRunning = NO;
}

// Implement MEMarkerMapDelegate methods
- (void) mapView:(MEMapView *)mapView
updateMarkerInfo:(MEMarkerInfo *)markerInfo
		 mapName:(NSString *)mapName
{
	/*
	self.fontNameCountry=@"Arial-BoldMT";
	self.fontCountryFillColor = [UIColor blackColor];
	self.fontCountrySize = 17.0;
	
	self.fontNameCity = @"ArialMT";
	self.fontCityFillColor = [UIColor blackColor];
	self.fontCitySize = 13.0;
	
	self.fontNameState = @"ArialMT";
	self.fontStateFillColor = [MEImageUtil makeColor:130 g:130 b:130 a:255];
	self.fontStateSize = 14.0;
	
	
	self.fontStrokeColor = [MEImageUtil makeColor:255 g:255 b:255 a:255];
	self.fontStrokeWidth = 0;*/
	
	//Scale marker font size based on population
    float fontSize = 13.0f;
    UIColor* fillColor = [UIColor blackColor];
    UIColor* strokeColor = [UIColor whiteColor];
    //Have the mapping engine create a label for us
    UIImage* textImage=[MEFontUtil createImageWithFontOutlined:@"ArialMT"
													  fontSize:fontSize
													 fillColor:fillColor
												   strokeColor:strokeColor
												   strokeWidth:0
														  text:markerInfo.metaData];
    
    //Craete an anhor point based on the image size
    CGPoint anchorPoint = CGPointMake(textImage.size.width / 2.0,
                                      textImage.size.height / 2.0);
    //Update the marker info
	markerInfo.uiImage = textImage;
	markerInfo.anchorPoint = anchorPoint;
	[textImage release];
	
}


@end
