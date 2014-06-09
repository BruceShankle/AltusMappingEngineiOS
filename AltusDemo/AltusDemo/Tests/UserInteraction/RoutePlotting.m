//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "RoutePlotting.h"
#import "../METestConsts.h"
#import "../Markers/MarkerImageCreators/WayPointMarkerImage.h"

@implementation RoutePlotting

- (id) init {
	if(self=[super init]){
		self.name = @"Route Plotting";
        self.markerMapName = @"Route Plotting - WayPoints";
	}
	return self;
}

- (NSArray*) createWayPoints:(double) xoffset yoffset:(double) yoffset{
    
    NSMutableArray* wayPoints = [[NSMutableArray alloc]init];
    
    wayPoints = [[NSMutableArray alloc]init];
    
    [wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(149.825+xoffset, 39.153+yoffset)
                               ]];
    [wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(160+xoffset, 42+yoffset)
                               ]];
    [wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(170+xoffset, 45+yoffset)
                               ]];
    [wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(180+xoffset, 48+yoffset)
                               ]];
    [wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-170+xoffset, 50+yoffset)
                               ]];
    [wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-160+xoffset, 52+yoffset)
                               ]];
    [wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-150+xoffset, 53+yoffset)
                               ]];
    [wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-140+xoffset, 52+yoffset)
                               ]];
    [wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-134.4+xoffset, 51+yoffset)
                               ]];
    return wayPoints;
}

//Add a vector map with a 40 nautical mile tesselation threshold
- (void) addVectorMap{
    
    //Initial points of route
    self.wayPoints = [self createWayPoints:0 yoffset:0];
    
    
    //"lats":["35.322","36","38","38","36","32","23.943"],
    //"lons":["145.997","150","160","170","180","-170","-160.763"]
    
    
    //Create and add dynamic vector map
	MEVectorMapInfo* vectorMapInfo = [[MEVectorMapInfo alloc]init];
	vectorMapInfo.name = self.name;
	vectorMapInfo.zOrder = 100;
	[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
    [self.meMapViewController setTesselationThresholdForMap:vectorMapInfo.name withThreshold:40];
    
    //Create vector line style
	self.vectorLineStyle = [[MELineStyle alloc]init];
	self.vectorLineStyle.strokeColor = [UIColor blueColor];
	self.vectorLineStyle.outlineColor = [UIColor blackColor];
	self.vectorLineStyle.strokeWidth = 4;
	self.vectorLineStyle.outlineWidth = 1;
    
    [self updateVectorMap];
}

//Remove and redraw vector lines
- (void) updateVectorMap{
	[self.meMapViewController clearDynamicGeometryFromMap:self.name];
    
    [self.meMapViewController addDynamicLineToVectorMap:self.name
                                                 lineId:@"route"
                                                 points:self.wayPoints
                                                  style:self.vectorLineStyle];
    
    for(int i=1; i< 50; i++){
        NSString* lineID = [NSString stringWithFormat:@"North_line %d", i];
        NSArray* wayPoints = [self createWayPoints:0 yoffset:0.5 * i];
        [self.meMapViewController addDynamicLineToVectorMap:self.name
                                                     lineId:lineID
                                                     points:wayPoints
                                                      style:self.vectorLineStyle];
    }
    
    for(int i=1; i< 50; i++){
        NSString* lineID = [NSString stringWithFormat:@"South_line %d", i];
        NSArray* wayPoints = [self createWayPoints:0 yoffset:-0.5 * i];
        [self.meMapViewController addDynamicLineToVectorMap:self.name
                                                     lineId:lineID
                                                     points:wayPoints
                                                      style:self.vectorLineStyle];
    }
    
    
}

//Converts NSValue from way point array to CLLocationCoordinate2D
-(CLLocationCoordinate2D) wayPointLocation:(int) index{
    if(self.wayPoints==nil){
        return CLLocationCoordinate2DMake(0, 0);
    }
    if(self.wayPoints.count < index+1){
        return CLLocationCoordinate2DMake(0, 0);
    }
    NSValue* value = [self.wayPoints objectAtIndex:index];
    CGPoint point = [value CGPointValue];
    return CLLocationCoordinate2DMake(point.y, point.x);
}

//Fit the route into view
- (void) lookAtRoute{
	if(self.wayPoints==nil)
		return;
	if(self.wayPoints.count<2)
		return;
	NSValue* startValue = [self.wayPoints objectAtIndex:0];
	NSValue* endValue = [self.wayPoints lastObject];
	CGPoint start = [startValue CGPointValue];
	CGPoint end = [endValue CGPointValue];
	
	[self.meMapViewController.meMapView lookAtCoordinate:CLLocationCoordinate2DMake(start.y, start.x)
                                           andCoordinate:CLLocationCoordinate2DMake(end.y, end.x)
                                    withHorizontalBuffer:10
                                      withVerticalBuffer:10
									   animationDuration:0.5];
}

//Adds a new dynamic marker to the dynamic marker map
- (void) addDynamicMarker:(NSString*) label location:(CLLocationCoordinate2D) location{
    MEMarker* marker = [[MEMarker alloc]init];
    marker.uniqueName = label; //Dynamic markers must have unique names
    marker.location = location;
    CGPoint anchor;
    marker.uiImage = [WayPointMarkerImage createCustomMarkerImage:label
                                                      anchorPoint:&anchor];
    marker.anchorPoint = anchor;
    [self.meMapViewController addDynamicMarkerToMap:self.markerMapName
                                      dynamicMarker:marker];
}

//Add a dynamic marker map (you can also add an in-memory clustered marker route
//if you have a lot of markers along a route that may touch
- (void) addMarkerMap{
    
    //Add dynamic marker map
    MEDynamicMarkerMapInfo* mapInfo = [[MEDynamicMarkerMapInfo alloc]init];
    mapInfo.zOrder = 101;
    mapInfo.name = self.markerMapName;
    mapInfo.meDynamicMarkerMapDelegate = self;
    [self.meMapViewController addMapUsingMapInfo:mapInfo];
    
    //Add markers
    [self addDynamicMarker:@"Start" location:[self wayPointLocation:0]];
    [self addDynamicMarker:@"End" location:[self wayPointLocation:self.wayPoints.count-1]];
}

//Removes marker map
- (void) removeMarkerMap{
    [self.meMapViewController removeMap:self.markerMapName
                             clearCache:YES];
}

//Add all maps
- (void) addMaps{
	[self addVectorMap];
    [self addMarkerMap];
}

//Remove all maps
- (void) removeMaps{
    [self.meMapViewController removeMap:self.name
                             clearCache:YES];
    [self removeMarkerMap];
}


- (void) beginTest{
	[self addMaps];
    //Look at the route
	[self lookAtRoute];
}

- (void) endTest{
	[self removeMaps];
}

- (void) start{
	if(self.isRunning){
		return;
	}
	[self beginTest];
    self.isRunning = YES;
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
	[self removeMaps];
	self.isRunning = NO;
    [self endTest];
}

@end
