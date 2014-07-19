//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "DynamicLines.h"
#import "../METestConsts.h"
#import "../METestManager.h"
#import "../METestCategory.h"

@implementation DynamicLines
- (id) init {
	if(self=[super init]){
		self.name = @"Dynamic Lines";
	}
	return self;
}

- (void) createStyles{
    
    self.blueLineStyle = [[MELineStyle alloc]init];
    self.blueLineStyle.strokeWidth = 20.0;
    self.blueLineStyle.outlineWidth = 5.0;
    self.blueLineStyle.strokeColor = [[UIColor blueColor]colorWithAlphaComponent:0.50];
    self.blueLineStyle.outlineColor = [UIColor blackColor];
    
    self.yellowLineStyle = [[MELineStyle alloc]init];
    self.yellowLineStyle.strokeWidth = 5.0;
    self.yellowLineStyle.outlineWidth =1.0;
    self.yellowLineStyle.strokeColor = [[UIColor yellowColor]colorWithAlphaComponent:0.50];
    self.yellowLineStyle.outlineColor = [UIColor blackColor];
    
    self.redLineStyle = [[MELineStyle alloc]init];
    self.redLineStyle.strokeWidth = 5.0;
    self.redLineStyle.outlineWidth = 1.0;
    self.redLineStyle.strokeColor = [[UIColor redColor]colorWithAlphaComponent:0.50];
    self.redLineStyle.outlineColor = [UIColor blackColor];
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

- (void) updateMovingObject:(METestMovingObject*) movingObject
                elaspedTime:(float) elapsedTime{
    
    [movingObject update:elapsedTime];
    
    //Reverse direction to make it interesting....
    if(movingObject.rateOfTurn > 0 && movingObject.currentCourse >= 180){
        movingObject.rateOfTurn = -movingObject.rateOfTurn;
        movingObject.currentCourse = 180;
    }
    else if(movingObject.rateOfTurn < 0 && movingObject.currentCourse >= 180){
        movingObject.rateOfTurn = -movingObject.rateOfTurn;
        movingObject.currentCourse = 0;
    }
    else if(movingObject.rateOfTurn == 0){
        if(movingObject.distanceTraveled > 12000){
            movingObject.oldCourse = movingObject.currentCourse;
            movingObject.currentCourse+=12;
            movingObject.distanceTraveled = 0;
        }
    }
}

- (void) computePaths{
    
    self.redPath = [[NSMutableArray alloc]init];
    self.bluePath = [[NSMutableArray alloc]init];
    self.yellowPath = [[NSMutableArray alloc]init];
    
    METestMovingObject* redPlane;
    METestMovingObject* bluePlane;
    METestMovingObject* yellowPlane;
    
    //Add the red plane
    redPlane = [[METestMovingObject alloc]initWithName:@"redplane"
                                                   location:RDU_COORD
                                                      speed:500
                                                     course:1
                                                 rateOfTurn:5];
    
    //Add the blue plane
    bluePlane = [[METestMovingObject alloc]initWithName:@"blueplane"
                                                    location:SFO_COORD
                                                       speed:800
                                                      course:90
                                                  rateOfTurn:10];
    
    //Add the yellow plane
    yellowPlane = [[METestMovingObject alloc]initWithName:@"yellowplane"
                                                      location:CLLocationCoordinate2DMake(90, 0)
                                                         speed:900
                                                        course:22.5
                                                    rateOfTurn:0];
    
    for(int i=0; i<3600; i++){
        
        //Red
        [self.redPath addObject:[NSValue valueWithCGPoint:
                                 CGPointMake(redPlane.currentLocation.longitude,
                                             redPlane.currentLocation.latitude)]
         ];
        [self updateMovingObject:redPlane elaspedTime:1.0];
        
        //Blue
        [self.bluePath addObject:[NSValue valueWithCGPoint:
                                  CGPointMake(bluePlane.currentLocation.longitude,
                                              bluePlane.currentLocation.latitude)]
         ];
        [self updateMovingObject:bluePlane elaspedTime:1.0];
        
        //Yellow
        [self.yellowPath addObject:[NSValue valueWithCGPoint:
                                 CGPointMake(yellowPlane.currentLocation.longitude,
                                             yellowPlane.currentLocation.latitude)]];
        [self updateMovingObject:yellowPlane elaspedTime:1.0];
    }
    
}

- (void) addDynamicLines{
    [self.meMapViewController addDynamicLineToVectorMap:self.name
                                                 lineId:@"red"
                                                 points:self.redPath
                                                  style:self.redLineStyle];
    
    [self.meMapViewController addDynamicLineToVectorMap:self.name
                                                 lineId:@"blue"
                                                 points:self.bluePath
                                                  style:self.blueLineStyle];
    
    [self.meMapViewController addDynamicLineToVectorMap:self.name
                                                 lineId:@"yellow"
                                                 points:self.yellowPath
                                                  style:self.yellowLineStyle];
}

- (void) beginTest{
    
    //Add map
    [self addMapLayers];
    
    //Create line styles
    [self createStyles];
    
    //Compute paths
    [self computePaths];
    
    //Add lines
    [self addDynamicLines];
    
    [self lookAtSanFrancisco];
    [self.meMapViewController.meMapView setCenterCoordinate:CLLocationCoordinate2DMake(37.594, -122.237) animationDuration:0.5];
    
}

- (void) endTest{
    [self removeMapLayers];
    
}

@end
