//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "PolygonPerf.h"

@implementation PolygonPerfSlow

- (id) init {
	if(self=[super init]){
		self.name = @"Polygon Perf - Slow";
	}
	return self;
}

- (void) addMapLayers{
    MEVectorMapInfo* mapInfo = [[MEVectorMapInfo alloc]init];
    mapInfo.name = self.name;
    mapInfo.mapType = kMapTypeDynamicVector;
    mapInfo.meVectorMapDelegate = self;
    mapInfo.polygonHitDetectionEnabled = true;
    mapInfo.zOrder = 100;
    [self.meMapViewController addMapUsingMapInfo:mapInfo];
    [self.meMapViewController setTesselationThresholdForMap:self.name withThreshold:40];
}

- (void) removeMapLayers{
    [self.meMapViewController removeMap:self.name
                             clearCache:YES];
    
}

- (MEPolygonStyle*) createPolygonStyle{
    MEPolygonStyle* style = [[MEPolygonStyle alloc]init];
    style.strokeWidth = 4.0;
    style.outlineWidth = 1.0;
    style.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.8];
    style.fillColor = [[UIColor blueColor]colorWithAlphaComponent:0.2];
    style.shadowColor = [UIColor clearColor];
    return style;
}

- (void) addPoint:(NSMutableArray*) points
              lon:(double) lon
              lat:(double) lat{
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(lon, lat)]];
    
}

- (NSMutableArray*) makePolygon:(double) minLon
                         minLat:(double) minLat
                           size:(double) size{
    NSMutableArray* points = [[NSMutableArray alloc]init];
    [self addPoint:points lon:minLon lat:minLat];
    [self addPoint:points lon:minLon lat:minLat+size];
    [self addPoint:points lon:minLon+size  lat:minLat+size ];
    [self addPoint:points lon:minLon+size lat:minLat ];
    [self addPoint:points lon:minLon  lat:minLat ];
    return points;
}

//Adds polygons assuming they will each a unique style. This
//way is flexible, but inefficient because there will be many more
//draw calls
- (void) addWedge:(double) longitude
             size:(double) size
            style:(MEPolygonStyle*) style{
    for(float latitude=-90; latitude<90; latitude+=size){
        NSString* polygonId = [NSString stringWithFormat:@"%f %f", longitude, latitude];
        
        
        [self.meMapViewController addPolygonToVectorMap:self.name
                                              polygonId:polygonId
                                                 points:[self makePolygon:longitude
                                                                   minLat:latitude
                                                                     size:size-1.0]
                                                  style:style];
    }

}

- (void) polygonHitDetected:(MEMapView *)mapView hits:(NSArray *)polygonHits{
    NSString* alertMessage =@"Shapes Tapped:";
    
    for(MEVectorGeometryHit* polygonHit in polygonHits){
        
        //Append to alert message
        alertMessage = [NSString stringWithFormat:@"%@\n%@",
                        alertMessage,
                        [NSString stringWithFormat:@"%@ tapped at (%.3f,%.3f)",
                         polygonHit.shapeId,
                         polygonHit.location.longitude,
                         polygonHit.location.latitude]];
        
        //Send to log
        NSLog(@"Hit detected on map:%@ shapeId:%@ tap location: %f, %f",
              polygonHit.mapName,
              polygonHit.shapeId,
              polygonHit.location.latitude,
              polygonHit.location.longitude);
    }
    
    //Show a pop up with all polygons that were tapped
    [self showAlert:alertMessage timeout:2];
}

- (void) beginTest{
    [self.meTestCategory stopAllTests];
    [self addMapLayers];
    MEPolygonStyle* style = [self createPolygonStyle];
    double wedgeSize = 5.0;
    for(float longitude=-179.99; longitude<180; longitude+=wedgeSize){
        [self addWedge:longitude
                  size:wedgeSize
                 style:style];
    }
}

- (void) endTest{
    [self removeMapLayers];
}

@end

/////////////////////////////////////////////////////////////////////////////
@implementation PolygonPerfFast

- (id) init {
	if(self=[super init]){
		self.name = @"Polygon Perf - Fast";
	}
	return self;
}

//Adds polygons assuming they will each have the same style.
//This contrains the style flexibility, but is much more efficient
//because there are fewer draw calls. If polygons have the same style
//they should be given the same featureId if you have a lot of them.
- (void) addWedge:(double) longitude
             size:(double) size
        featureId:(unsigned int) featureId{
    for(float latitude=-90; latitude<90; latitude+=size){
        NSString* polygonId = [NSString stringWithFormat:@"%f %f",
                               longitude, latitude];
        [self.meMapViewController addPolygonToVectorMap:self.name
                                              polygonId:polygonId
                                                 points:[self makePolygon:longitude
                                                                   minLat:latitude
                                                                     size:size-1.0]
                                                  featureId:featureId];
    }
    
}

- (void) beginTest{
    [self.meTestCategory stopAllTests];
    [self addMapLayers];
    MEPolygonStyle* style = [self createPolygonStyle];
    [self.meMapViewController addPolygonStyleToVectorMap:self.name
                                               featureId:1
                                                   style:style];
    double wedgeSize = 5.0;
    for(float longitude=-180; longitude<180; longitude+=wedgeSize){
        [self addWedge:longitude
                  size:wedgeSize
                 featureId:1];
    }
}
@end
