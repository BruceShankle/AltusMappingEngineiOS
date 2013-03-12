//
//  MEInMemoryVectorTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/16/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MEInMemoryVectorPolygonsTest.h"

@implementation MEInMemoryVectorPolygonsTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"In-Memory Polys";
    }
    return self;
}

- (void) addMap
{
	MEVectorMapInfo* vectorMapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
	vectorMapInfo.name = self.name;
	vectorMapInfo.zOrder = 100;
	[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
	//    [self.meMapViewController setTesselationThresholdForMap:vectorMapInfo.name withThreshold:90];
	
	//Point camera at US
	//[self lookAtUnitedStates];
    
    //Create a new polygon style
    MEPolygonStyle* polygonStyle=[[[MEPolygonStyle alloc]init]autorelease];
    polygonStyle.strokeColor = [UIColor redColor];
    polygonStyle.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
    polygonStyle.strokeWidth = 8;
    
    //Create an array of points for a polygon
    NSMutableArray* polygonPoints=[[[NSMutableArray alloc]init]autorelease];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-78.9698, 42.6945)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-74.8382, 42.4147)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-74.6824, 40.2845)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-77.02, 40.23)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-78.3941, 40.3192)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-79.4015, 40.5728)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-82.8436, 40.6145)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-83.7102, 41.5953)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-82.72, 42.5952)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-78.9698 , 42.6945)]];
    
    //Add the polygon to the map
    [self.meMapViewController addPolygonToVectorMap:self.name points:polygonPoints style:polygonStyle];
	
    [polygonPoints removeAllObjects];
    
    
    //Add more shapes
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-123.7035, 41.8865)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-123.8793, 39.5185)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.2309, 38.0783)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-121.5498, 37.1585)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-120.2035, 34.8649)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-117.8686, 34.1212)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-116.9497, 33.0147)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-116.6738, 32.3087)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-120.2194, 30.1591)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-127.026 , 39.7457)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-127.1016, 41.5251)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-123.7035, 41.8865)]];
    polygonStyle.strokeColor = [UIColor greenColor];
    polygonStyle.fillColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
    polygonStyle.strokeWidth = 2;
    [self.meMapViewController addPolygonToVectorMap:self.name points:polygonPoints style:polygonStyle];
    [polygonPoints removeAllObjects];
    
    
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-123.7035, 51.8865)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-123.8793, 49.5185)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.2309, 48.0783)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-121.5498, 47.1585)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-120.2035, 44.8649)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-117.8686, 44.1212)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-116.9497, 43.0147)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-116.6738, 42.3087)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-120.2194, 40.1591)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-127.026 , 49.7457)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-127.1016, 51.5251)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-123.7035, 51.8865)]];
    polygonStyle.strokeColor = [UIColor blueColor];
    polygonStyle.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5];
    polygonStyle.strokeWidth = 4;
    [self.meMapViewController addPolygonToVectorMap:self.name points:polygonPoints style:polygonStyle];
    [polygonPoints removeAllObjects];
    
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-123.7035, 51.8865)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-123.8793, 49.5185)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.2309, 48.0783)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-121.5498, 47.1585)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-120.2035, 44.8649)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-117.8686, 44.1212)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-116.9497, 43.0147)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-116.6738, 42.3087)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-120.2194, 40.1591)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-127.026 , 49.7457)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-127.1016, 51.5251)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-123.7035, 51.8865)]];
    polygonStyle.strokeColor = [UIColor blueColor];
    polygonStyle.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5];
    polygonStyle.strokeWidth = 4;
    [self.meMapViewController addPolygonToVectorMap:self.name points:polygonPoints style:polygonStyle];
    [polygonPoints removeAllObjects];
}

- (void) removeMap
{
	[self.meMapViewController removeMap:self.name clearCache:YES];
}


- (void) start
{
    self.isRunning = YES;
    
    //Add an in-memory vector map
	[self addMap];
	
}

- (void) stop
{
    self.isRunning = NO;
	[self removeMap];
}

@end

////////////////////////////////////////////////////////////////
@implementation MEInMemoryVectorPolygonsStressTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"In-Memory Polys Stress";
		self.interval = 0.2;
    }
    return self;
}

- (void) start
{
	if(self.isRunning)
		return;
	
	self.oldDelegate = self.meMapViewController.meMapView.meMapViewDelegate;
	self.meMapViewController.meMapView.meMapViewDelegate = self;
	self.isRunning = YES;
	[self cycleMap];
}

- (void) cycleMap
{
	[self stopTimer];
	if([self.meMapViewController containsMap:self.name])
		[self removeMap];
	[self addMap];
}

- (void) timerTick
{
	[self cycleMap];
}

- (void) stop
{
	if(!self.isRunning)
		return;
	self.meMapViewController.meMapView.meMapViewDelegate = self.oldDelegate;
	self.oldDelegate = nil;
	[self stopTimer];
	[self removeMap];
	self.isRunning = NO;
}


- (void) mapView:(MEMapView *)mapView didFinishLoadingMap:(NSString *)mapName
{
	[self startTimer];
}

@end

////////////////////////////////////////////////////////////////
@implementation MEInMemoryVectorPolygonEdgeCases

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Polygon Edge Cases";
    }
    return self;
}


- (void) start
{
    self.isRunning = YES;
    
    //Add an in-memory vector map
	MEVectorMapInfo* vectorMapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
	vectorMapInfo.name = self.name;
	vectorMapInfo.zOrder = 100;
	[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
	//    [self.meMapViewController setTesselationThresholdForMap:vectorMapInfo.name withThreshold:90];
	
	//Point camera at US
	[self lookAtUnitedStates];
    
    //Create a new polygon style
    MEPolygonStyle* polygonStyle=[[[MEPolygonStyle alloc]init]autorelease];
    polygonStyle.strokeColor = [UIColor redColor];
    polygonStyle.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
    polygonStyle.strokeWidth = 8;
    
    //Create an array of points for a polygon
    NSMutableArray* polygonPoints=[[[NSMutableArray alloc]init]autorelease];
    
	//Test a polygon without enough points.
	//[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-110, 46.8865)]];
	//[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-123.8793, 44.5185)]];
	//[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-127.1016, 46.5251)]];
	//[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-123.7035, 46.8865)]];
	polygonStyle.strokeColor = [UIColor orangeColor];
	polygonStyle.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:0.75];
	polygonStyle.strokeWidth = 1.0;
	[self.meMapViewController addPolygonToVectorMap:self.name points:polygonPoints style:polygonStyle];
	[polygonPoints removeAllObjects];
	
	//Test polygon that is not closed, the mapping engine show issue a warning, but not actually
	//add the polygon.
//    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-110, 46.8865)]];
//    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-123.8793, 44.5185)]];
//    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-127.1016, 46.5251)]];
//    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(-123.7035, 46.8865)]];
//    polygonStyle.strokeColor = [UIColor orangeColor];
//    polygonStyle.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:0.75];
//    polygonStyle.strokeWidth = 1.0;
//    [self.meMapViewController addPolygonToVectorMap:self.name points:polygonPoints style:polygonStyle];
//    [polygonPoints removeAllObjects];
	
	//Testing potential crash with polygon supplied by a customer.
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(145.131111,13.640000)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(144.746986,13.476885)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(144.724798,13.526307)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(144.716441,13.579617)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(144.722490,13.633222)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(144.742544,13.683503)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(144.775259,13.727068)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(144.818430,13.760971)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(144.869144,13.782922)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(144.923973,13.791437)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(144.979210,13.785939)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(145.031119,13.766801)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(145.076191,13.735317)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(145.111384,13.693614)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(145.134325,13.644511)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(145.134373,13.644861)]];
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(145.131111,13.640000)]];
	polygonStyle.strokeColor = [UIColor orangeColor];
    polygonStyle.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:0.75];
    polygonStyle.strokeWidth = 1.0;
    [self.meMapViewController addPolygonToVectorMap:self.name points:polygonPoints style:polygonStyle];
    [polygonPoints removeAllObjects];
	
	[self lookAtGuam];
}

- (void) stop
{
    [self.meMapViewController removeMap:self.name clearCache:NO];
    self.isRunning = NO;
}


@end


////////////////////////////////////////////////////////////////
@implementation MEInMemoryVectorPolygonsAlphaTest
@synthesize currentAlpha;

- (id) init
{
    if(self = [super init])
    {
        self.name=@"In-Memory Polys w/Alpha";
        self.currentAlpha = 1.0;
    }
    return self;
}

- (NSString*) label
{
    if(self.currentAlpha>0)
        return [NSString stringWithFormat:@"%f", self.currentAlpha];
    else
        return @"Remove";
}


- (void) start
{
    if(self.isRunning)
        return;
    [super start];
    [self.meMapViewController setMapAlpha:self.name alpha:self.currentAlpha];
    self.isRunning = YES;
    [self nextTestCase];
}

- (void) nextTestCase
{
    float testCases[] = {1.0,0.5,0.25,0.12,0.06,0.03,0.0,-1.0};
    int testCount = sizeof testCases / sizeof(float);
    
    //Get next size.
    float nextAlpha = testCases[0];
    for(int i=0; i<testCount; i++)
    {
        if(testCases[i]<self.currentAlpha)
        {
            nextAlpha=testCases[i];
            break;
        }
    }

    self.currentAlpha = nextAlpha;
    
}

- (void) userTapped
{
    if(!self.isRunning)
    {
        [self start];
        return;
    }
    
    [self nextTestCase];
    
    if(self.currentAlpha>=0)
        [self.meMapViewController setMapAlpha:self.name alpha:self.currentAlpha];
    else
    {
        self.currentAlpha = 1.0;
        [super stop];
    }
        
    
}


@end

