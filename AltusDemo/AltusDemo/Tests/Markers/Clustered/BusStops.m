//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "BusStops.h"
#import "BusStopData.h"
#import "../MarkerImageCreators/WayPointMarkerImage.h"

/////////////////////////////////////////////////////////////////////////////
@implementation BusStopsMemoryCached

- (id) init {
	if(self=[super init]){
		self.name = @"Bus Stops - Memory / Cached";
	}
	return self;
}

- (void) addMap{
    
    //Cache the marker image
    [self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"pinRed"]
                                          withName:@"pinRed"
                                   compressTexture:YES
                    nearestNeighborTextureSampling:NO];
    
	MEMarkerMapInfo* mapInfo = [[MEMarkerMapInfo alloc]init];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeMemoryMarker;
	mapInfo.zOrder = 50;
	mapInfo.meMarkerMapDelegate = self;
    mapInfo.clusterDistance = 40;
    mapInfo.maxLevel = 18;
    mapInfo.fadeEnabled = NO;
    mapInfo.markers = [[BusStopData getBusStopMarkers] copy];
    mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingPrecached;
    //For this loading strategy, we must set the cached image name
    for(MEMarker* marker in mapInfo.markers){
        marker.cachedImageName=@"pinRed";
        marker.anchorPoint = CGPointMake(7,35);
    }
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

- (void) removeMap{
    [self.meMapViewController removeMap:self.name
                             clearCache:YES];
}

- (void) beginTest{
	[self addMap];
    [self lookAtSanFrancisco];
}

- (void) endTest{
	[self removeMap];
}
@end

/////////////////////////////////////////////////////////////////////////////
@implementation BusStopsMemoryAsync

- (id) init {
	if(self=[super init]){
		self.name = @"Bus Stops - Memory / Async";
	}
	return self;
}

- (void) addMap{
	MEMarkerMapInfo* mapInfo = [[MEMarkerMapInfo alloc]init];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeMemoryMarker;
	mapInfo.zOrder = 50;
	mapInfo.meMarkerMapDelegate = self;
    mapInfo.clusterDistance = 40;
    mapInfo.maxLevel = 18;
    mapInfo.fadeEnabled = NO;
    mapInfo.markers = [BusStopData getBusStopMarkers];
    mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingAsynchronous;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

-(void)mapView:(MEMapView *)mapView
  updateMarker:(MEMarker *)marker
       mapName:(NSString *)mapName{
    
    CGPoint anchorPoint;
    marker.uiImage = [WayPointMarkerImage createCustomMarkerImage:marker.metaData
                                                      anchorPoint:&anchorPoint];
    marker.anchorPoint = anchorPoint;
	marker.nearestNeighborTextureSampling = YES;
}

- (void) removeMap{
    [self.meMapViewController removeMap:self.name
                             clearCache:YES];
}

- (void) beginTest{
	[self addMap];
    [self lookAtSanFrancisco];
}

- (void) endTest{
	[self removeMap];
}
@end


/////////////////////////////////////////////////////////////////////////////
@implementation BusStopsMemorySync

- (id) init {
	if(self=[super init]){
		self.name = @"Bus Stops - Memory / Sync";
	}
	return self;
}

- (void) addMap{
	MEMarkerMapInfo* mapInfo = [[MEMarkerMapInfo alloc]init];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeMemoryMarker;
	mapInfo.zOrder = 50;
	mapInfo.meMarkerMapDelegate = self;
    mapInfo.clusterDistance = 40;
    mapInfo.maxLevel = 18;
    mapInfo.fadeEnabled = NO;
    mapInfo.markers = [BusStopData getBusStopMarkers];
    mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingSynchronous;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

-(void)mapView:(MEMapView *)mapView
  updateMarker:(MEMarker *)marker
       mapName:(NSString *)mapName{
    CGPoint anchorPoint;
    marker.uiImage = [WayPointMarkerImage createCustomMarkerImage:marker.metaData
                                                      anchorPoint:&anchorPoint];
    marker.anchorPoint = anchorPoint;
	marker.nearestNeighborTextureSampling = YES;
}

- (void) removeMap{
    [self.meMapViewController removeMap:self.name
                             clearCache:YES];
}

- (void) beginTest{
	[self addMap];
    [self lookAtSanFrancisco];
}

- (void) endTest{
	[self removeMap];
}
@end
