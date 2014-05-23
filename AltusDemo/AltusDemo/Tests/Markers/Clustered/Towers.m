//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "Towers.h"

@implementation Towers

- (id) init {
	if(self=[super init]){
		self.name = @"Towers";
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
    
    [self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"pinRed"]
                                          withName:@"pinRed"
                                   compressTexture:YES
                    nearestNeighborTextureSampling:NO];
	[self addMap];
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


- (void) mapView:(MEMapView *)mapView
    updateMarker:(MEMarker *)marker
		 mapName:(NSString *)mapName{
	
    //Scale marker font size based on population
    float fontSize = 8.6f;
    UIColor* fillColor = [UIColor whiteColor];
    UIColor* strokeColor = [UIColor blackColor];
	NSString* label;
	if(marker.metaData.length==0){
		label = @"N/A";
	}
	else{
		label = marker.metaData;
	}
    //Have the mapping engine create a label for us
    UIImage* textImage=[MEFontUtil newImageWithFontOutlined:@"Helvetica-Bold"
                                                   fontSize:fontSize
                                                  fillColor:fillColor
                                                strokeColor:strokeColor
                                                strokeWidth:0
                                                       text:label];
    
    //Craete an anhor point based on the image size
    CGPoint anchorPoint = CGPointMake(textImage.size.width / 2.0,
                                      textImage.size.height / 2.0);
    //Update marker info
	marker.uiImage = textImage;
	marker.anchorPoint = anchorPoint;
	marker.nearestNeighborTextureSampling = YES;
}



@end
