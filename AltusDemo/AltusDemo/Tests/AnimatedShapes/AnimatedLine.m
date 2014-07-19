//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "AnimatedLine.h"
#import "../METestConsts.h"
#import "../METestManager.h"
#import "../METestCategory.h"

@implementation AnimatedLine
- (id) init {
	if(self=[super init]){
		self.name = @"Animated Line";
        self.vehicleMarkerMapName = @"Animated Line Marker";
        self.wayPointMarkerMapName = @"Animated Line Marker";
        self.clipMarkerMapName = @"Animated Line Clip Markers";
        self.interval = 1.0;
        self.accumulate = NO;
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

- (void) cacheMarkerImage:(NSString*) name{
	[self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:name]
										  withName:name
								   compressTexture:NO
					nearestNeighborTextureSampling:NO];
}

- (void) cacheMarkerImages{
	[self cacheMarkerImage:@"redplane"];
	[self cacheMarkerImage:@"blueplane"];
    [self cacheMarkerImage:@"yellowplane"];
    [self cacheMarkerImage:@"whitecircle_solid"];
    [self cacheMarkerImage:@"bluecircle_solid"];
    [self cacheMarkerImage:@"bluecircle_semitransparent"];
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
    
	//Add marker map for vehicles
	MEDynamicMarkerMapInfo* markerMapInfo = [[MEDynamicMarkerMapInfo alloc]init];
	markerMapInfo.name = self.vehicleMarkerMapName;
	markerMapInfo.zOrder = 102;
	markerMapInfo.hitTestingEnabled = YES;
	markerMapInfo.meDynamicMarkerMapDelegate = self;
	markerMapInfo.fadeInTime = 0.0;
	markerMapInfo.fadeOutTime = 0.0;
	[self.meMapViewController addMapUsingMapInfo:markerMapInfo];
    

    //Add marker map for waypoints
	markerMapInfo.name = self.wayPointMarkerMapName;
	markerMapInfo.zOrder = 101;
	[self.meMapViewController addMapUsingMapInfo:markerMapInfo];
    
    //Add a non-visible marker map used to 'clip' the vector lines
    markerMapInfo.name = self.clipMarkerMapName;
	[self.meMapViewController addMapUsingMapInfo:markerMapInfo];
    [self.meMapViewController setMapIsVisible:self.clipMarkerMapName isVisible:NO];
    
    //Set the clip map of the vector lines
    [self.meMapViewController addClipMapToMap:self.name
                                  clipMapName:self.clipMarkerMapName];
    
    
}

- (void) removeMapLayers{
    //Remove vector map
    [self.meMapViewController removeMap:self.name
                             clearCache:YES];
    
    //Remove vehicle marker map
    [self.meMapViewController removeMap:self.vehicleMarkerMapName
                             clearCache:YES];
    
    //Remove waypoint marker map
    [self.meMapViewController removeMap:self.wayPointMarkerMapName
                             clearCache:YES];
    
    //Remove clip marker map
    [self.meMapViewController removeMap:self.clipMarkerMapName
                             clearCache:YES];
    
}

- (void) addMovingObject:(METestMovingObject*) movingObject{
    MEMarker* marker = [[MEMarker alloc]init];
    marker.uniqueName = movingObject.name;
    marker.cachedImageName = movingObject.name;
    marker.location = movingObject.currentLocation;
    marker.rotation = movingObject.currentCourse;
    marker.rotationType = kMarkerRotationTrueNorthAligned;
    marker.anchorPoint = self.markerAnchorPoint;
    [self.meMapViewController addDynamicMarkerToMap:self.vehicleMarkerMapName
                                      dynamicMarker:marker];
    
    //Add circle to marker beginning of route
    marker.cachedImageName=@"whitecircle_solid";
    marker.rotation = 0;
    marker.rotationType = kMarkerRotationScreenEdgeAligned;
    marker.uniqueName = [NSString stringWithFormat:@"CircleFor_%@", movingObject.name];
    marker.anchorPoint = CGPointMake(19/2.0, 19/2.0);
    [self.meMapViewController addDynamicMarkerToMap:self.wayPointMarkerMapName
                                      dynamicMarker:marker];
    
    //Add clip marker
    [self.meMapViewController addDynamicMarkerToMap:self.clipMarkerMapName
                                      dynamicMarker:marker];
}

- (void) addMovingObjects{
    //Store plane image anchor point (mid point)
    UIImage* imgBluePlane = [UIImage imageNamed:@"blueplane"];
    self.markerAnchorPoint = CGPointMake(imgBluePlane.size.width/2.0,
                                         imgBluePlane.size.height/2.0);
    
    //Add the red plane
    self.redPlane = [[METestMovingObject alloc]initWithName:@"redplane"
                                                   location:RDU_COORD
                                                      speed:500
                                                     course:1
                                                 rateOfTurn:5];
    
    //Add the blue plane
    self.bluePlane = [[METestMovingObject alloc]initWithName:@"blueplane"
                                                    location:SFO_COORD
                                                       speed:800
                                                      course:90
                                                  rateOfTurn:10];
    
    //Add the yellow plane
    self.yellowPlane = [[METestMovingObject alloc]initWithName:@"yellowplane"
                                                      location:CLLocationCoordinate2DMake(90, 0)
                                                         speed:900
                                                        course:22.5
                                                    rateOfTurn:0];
    
    [self addMovingObject:self.redPlane];
    [self addMovingObject:self.bluePlane];
    [self addMovingObject:self.yellowPlane];
}

- (void) initializePaths{
    self.redPath = [[NSMutableArray alloc]init];
    self.bluePath = [[NSMutableArray alloc]init];
    self.yellowPath = [[NSMutableArray alloc]init];
}

//Append another point onto an array of points
- (void) appendLocationToPath:(NSMutableArray*) pointArray
                     location:(CLLocationCoordinate2D) location{
    [pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(location.longitude,
                                                                location.latitude)]];
    
}

- (void) beginTest{
    
    //Stop other tests in this category
    [self.meTestCategory stopAllTests];
    
    //Create a timer
    self.meTimer = [[METimer alloc]init];
    
    
    //Initialize path storage
    [self initializePaths];
    
    //Create line styles
    [self createStyles];
    
    //Cache marker iamegs
    [self cacheMarkerImages];
    
    //Add map
    [self addMapLayers];
    
    //Add moving objects
    [self addMovingObjects];
    
    //Start our high precision timer (NOTE: this is not the same as the test timer)
    [self.meTimer start];
    
    //Start timer (so we'll get some sort of update from the os)
    [self startTimer];
}

- (void) endTest{
    [self removeMapLayers];
    [self.meTimer stop];
}

//Adds a semi-transparent blue marker and a 'clip' marker at the given coordinate
- (void) addWayPoint:(CLLocationCoordinate2D) location
            withName:(NSString*) name{
    
    MEMarker* marker = [[MEMarker alloc]init];
    marker.uniqueName = name;
    marker.cachedImageName = @"bluecircle_semitransparent";
    marker.location = location;
    marker.rotation=0;
    marker.rotationType = kMarkerRotationScreenEdgeAligned;
    marker.anchorPoint = CGPointMake(19/2.0, 19/2.0);
    [self.meMapViewController addDynamicMarkerToMap:self.wayPointMarkerMapName
                                      dynamicMarker:marker];
    
    marker.cachedImageName = @"bluecircle_solid";
    [self.meMapViewController addDynamicMarkerToMap:self.clipMarkerMapName
                                      dynamicMarker:marker];
}

- (void) updateMovingObject:(METestMovingObject*) movingObject
                elaspedTime:(float) elapsedTime
                  lineStyle:(MELineStyle*) lineStyle{
    
    [movingObject update:elapsedTime];
    
    //Reverse direction to make it interesting....
    if(movingObject.rateOfTurn > 0 && movingObject.currentCourse >= 180){
        movingObject.rateOfTurn = -movingObject.rateOfTurn;
        movingObject.currentCourse = 180;
        [self addWayPoint:movingObject.currentLocation
                 withName:[NSString stringWithFormat:@"%f", [METest randomDouble:0 max:10000]]];
    }
    else if(movingObject.rateOfTurn < 0 && movingObject.currentCourse >= 180){
        movingObject.rateOfTurn = -movingObject.rateOfTurn;
        movingObject.currentCourse = 0;
        [self addWayPoint:movingObject.currentLocation
                 withName:[NSString stringWithFormat:@"%f", [METest randomDouble:0 max:10000]]];
    }
    else if(movingObject.rateOfTurn == 0){
        if(movingObject.distanceTraveled > 12000){
            movingObject.oldCourse = movingObject.currentCourse;
            movingObject.currentCourse+=12;
            movingObject.distanceTraveled = 0;
        }
    }
    
    //Update marker rotation
    [self.meMapViewController updateDynamicMarkerRotation:self.vehicleMarkerMapName
                                               markerName:movingObject.name
                                                 rotation:movingObject.currentCourse
                                        animationDuration:elapsedTime/2.0];
    
    //Animate marker to new position
    [self.meMapViewController updateDynamicMarkerLocation:self.vehicleMarkerMapName
                                               markerName:movingObject.name
                                                 location:movingObject.currentLocation
                                        animationDuration:elapsedTime];
    
    //Animate a 'bread crumb' trail that appears behind the marker
    [self.meMapViewController addDynamicLineToVectorMap:self.name
                                                 lineId:movingObject.name
                                          startLocation:movingObject.oldLocation
                                            endLocation:movingObject.currentLocation
                                                  style:lineStyle
                                      animationDuration:elapsedTime];
}

- (void) drawAccumulatedPaths{
    
    [self.meMapViewController clearDynamicGeometryFromMap:self.name];
    
    [self.meMapViewController addDynamicLineToVectorMap:self.name
                                                 lineId:self.redPlane.name
                                                 points:self.redPath
                                                  style:self.redLineStyle];
    
    [self.meMapViewController addDynamicLineToVectorMap:self.name
                                                 lineId:self.bluePlane.name
                                                 points:self.bluePath
                                                  style:self.blueLineStyle];
    
    [self.meMapViewController addDynamicLineToVectorMap:self.name
                                                 lineId:self.yellowPlane.name
                                                 points:self.yellowPath
                                                  style:self.yellowLineStyle];
    
}

- (void) updateMovingObjects:(float) elapsedTime{
    [self updateMovingObject:self.redPlane
                 elaspedTime:elapsedTime
                   lineStyle:self.redLineStyle];
    [self appendLocationToPath:self.redPath
                      location:self.redPlane.oldLocation];
    
    [self updateMovingObject:self.bluePlane
                 elaspedTime:elapsedTime
                   lineStyle:self.blueLineStyle];
    [self appendLocationToPath:self.bluePath
                      location:self.bluePlane.oldLocation];
    
    [self updateMovingObject:self.yellowPlane
                 elaspedTime:elapsedTime
                   lineStyle:self.yellowLineStyle];
    [self appendLocationToPath:self.yellowPath
                      location:self.yellowPlane.oldLocation];
    
    if(self.accumulate){
        [self drawAccumulatedPaths];
    }
}

- (void) timerTick{
    long millis = [self.meTimer stop];
    [self.meTimer reset];
    [self updateMovingObjects: millis/1000.0];
    [self.meTimer start];
}

//User tapped on a marker
- (void) tapOnDynamicMarker:(NSString *)markerName
				  onMapView:(MEMapView *)mapView
					mapName:(NSString *)mapName
			  atScreenPoint:(CGPoint)screenPoint
			  atMarkerPoint:(CGPoint)markerPoint{
	
	NSLog(@"Dynamic marker tap detected on map name: %@, marker name: %@, screen point:(%f, %f), longitude:%f latitude:%f",
		  mapName,
		  markerName,
		  screenPoint.x,
		  screenPoint.y,
		  markerPoint.x,
		  markerPoint.y);
}
@end

@implementation AnimatedLineAccumulate
- (id) init {
	if(self=[super init]){
		self.name = @"Animated Line - Accumulate";
	}
	return self;
}
@end

