//  Copyright (c) 2014 BA3, LLC. All rights reserved.

#import "CustomClustering.h"

@implementation CustomMarkerProvider

- (id) init{
	if(self = [super init]){
		self.isAsynchronous = YES;
	}
	return self;
}

- (MEDynamicMarker*) createMarkerWithName:(NSString*)name
                              andLocation:(CLLocationCoordinate2D)location{
	MEDynamicMarker* marker = [[MEDynamicMarker alloc]init];
	marker.name = name;
	marker.cachedImageName = @"pinRed";
	marker.compressTexture = NO;
	marker.location = location;
	marker.anchorPoint = CGPointMake(7,35);
    return marker;
}

/**
 Called by the mapping engine when it needs markers for the area of a 'tile'.
 The bounds of a tile are:
 Lower-left lon,lat = minX,minY.
 Upper-right lon,lat = maxX,maxY.
 Tiles will never cross a merdian or antimerdian.
 Here you would serve up whichever marks should be visible
 in the given area.*/
- (void) requestTileAsync:(METileProviderRequest *)meTileRequest{
    
    double width = meTileRequest.maxX - meTileRequest.minX;
    double height = meTileRequest.maxY - meTileRequest.minY;
    
    NSMutableArray *markers = [[NSMutableArray alloc] init];
    for(double x=0.0; x<1; x+=0.2){
        for(double y=0.0; y<1; y+=0.2){
            double lon = meTileRequest.minX + x * width;
            double lat = meTileRequest.minY + y * height;
            NSString* name = [NSString stringWithFormat:@"%llu (%f, %f)", meTileRequest.uid, lon, lat];
            [markers addObject:[self createMarkerWithName:name//You can put some data in here if you want
                                              andLocation:CLLocationCoordinate2DMake(lat, lon)]];
        }
        
    }
    
    //Give the markers to the mapping engine.
    [self.meMapViewController markerTileLoadComplete:meTileRequest
                                         markerArray:[NSArray arrayWithArray:markers]];
    
}

@end


@implementation CustomClustering

- (id) init {
	if(self=[super init]){
		self.name = @"Custom Clustering";
	}
	return self;
}

- (void) start {
	if(self.isRunning)
		return;
	
    //Cache red pin image
    [self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"pinRed"]
                                          withName:@"pinRed"
                                   compressTexture:NO
                    nearestNeighborTextureSampling:NO];
    
	//Create virtual map info
	MEVirtualMapInfo* mapInfo = [[MEVirtualMapInfo alloc]init];
	mapInfo.meMapViewController = self.meMapViewController;
	mapInfo.meTileProvider = [[CustomMarkerProvider alloc]init];
    mapInfo.meTileProvider.meMapViewController = self.meMapViewController;
	mapInfo.mapType = kMapTypeVirtualMarker;
	mapInfo.zOrder = 10;
	mapInfo.name = self.name;
	
	//Add map
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
    
	self.isRunning = YES;
}

- (void) stop {
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeMap:self.name clearCache:YES];
	self.isRunning = NO;
}


@end
