//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "DynamicPolygons.h"
#import "../METestConsts.h"
#import "../METestManager.h"
#import "../METestCategory.h"

@implementation DynamicPolygons
- (id) init {
	if(self=[super init]){
		self.name = @"Dynamic Polygons";
	}
	return self;
}

- (MEPolygonStyle*) createPolygonStyle{
    
    MEPolygonStyle* style = [[MEPolygonStyle alloc]init];
    style.strokeWidth = 2.0;
    style.outlineWidth = 2.0;
    style.strokeColor = [UIColor blueColor];
    style.outlineColor = [UIColor whiteColor];
    style.shadowColor = [UIColor blackColor];
    style.shadowOffset = CGPointMake(2,2);
    style.fillColor = [[UIColor blueColor]colorWithAlphaComponent:0.50];
    return style;
}

- (MELineStyle*) createLineStyle{
    MELineStyle* lineStyle = [[MELineStyle alloc]init];
    lineStyle.strokeWidth = 5.0;
    lineStyle.outlineWidth =1.0;
    lineStyle.strokeColor = [UIColor yellowColor];
    lineStyle.outlineColor = [UIColor blackColor];
    return lineStyle;
}

- (void) addMapLayers{
    
    //Add a dynamic vector map layer.
    MEVectorMapInfo* mapInfo = [[MEVectorMapInfo alloc]init];
    mapInfo.name = self.name;
    mapInfo.mapType = kMapTypeDynamicVector;
    mapInfo.zOrder = 100;
    [self.meMapViewController addMapUsingMapInfo:mapInfo];
    
    
    //Set tesselation threshold
    [self.meMapViewController setTesselationThresholdForMap:self.name withThreshold:40];
    
}

- (void) removeMapLayers{
    //Remove vector map
    [self.meMapViewController removeMap:self.name
                             clearCache:YES];
    
}

- (void) addPoint:(NSMutableArray*) points
              lon:(double) lon
              lat:(double) lat{
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(lon, lat)]];
    
}

- (void) addDynamicPolygons{
    NSMutableArray* points = [[NSMutableArray alloc]init];
    
    /**Order 1.*/
    [self addPoint:points lon:170.0 lat:3.5];
    [self addPoint:points lon:180.0 lat:3.5];
    [self addPoint:points lon:180.0 lat:-5.0];
    [self addPoint:points lon:-171.072 lat:-5.0];
    [self addPoint:points lon:-172.938 lat:-9.464];
    [self addPoint:points lon:-174.281 lat:-12.487];
    [self addPoint:points lon:-174.718 lat:-13.456];
    [self addPoint:points lon:-175.527 lat:-15.225];
    [self addPoint:points lon:-175.673 lat:-15.54];
    [self addPoint:points lon:-175.828 lat:-15.9];
    [self addPoint:points lon:-176.811 lat:-18.149];
    [self addPoint:points lon:-176.981 lat:-18.53];
    [self addPoint:points lon:-178.469 lat:-21.8];
    [self addPoint:points lon:180.0 lat:-25.0];
    [self addPoint:points lon:177.333 lat:-25.0];
    [self addPoint:points lon:171.417 lat:-25.0];
    [self addPoint:points lon:168.0 lat:-28.0];
    [self addPoint:points lon:163.0 lat:-30.0];
    [self addPoint:points lon:163.0 lat:-24.0];
    [self addPoint:points lon:163.0 lat:-17.667];
    [self addPoint:points lon:161.25 lat:-14.0];
    [self addPoint:points lon:163.0 lat:-14.0];
    [self addPoint:points lon:166.875 lat:-11.8];
    [self addPoint:points lon:170.0 lat:-10.0];
    [self addPoint:points lon:170.0 lat:3.5];
    
   
   
    [self.meMapViewController addDynamicPolygonToVectorMap:self.name
                                                   shapeId:@"DynamicPolygon"
                                                    points:points
                                                     style:[self createPolygonStyle]];
    
    [self.meMapViewController addDynamicLineToVectorMap:self.name
                                                 lineId:@"Outline"
                                                 points:points
                                                  style:[self createLineStyle]];
}

- (void) beginTest{
    
    //Stop other tests
    [self.meTestCategory stopAllTests];
    
    //Add map
    [self addMapLayers];
    
    //Add polygons
    [self addDynamicPolygons];
    
    [self.meMapViewController.meMapView setCenterCoordinate:CLLocationCoordinate2DMake(-10, -180)
                                          animationDuration:0];
    
}

- (void) endTest{
    [self removeMapLayers];
    
}

@end

