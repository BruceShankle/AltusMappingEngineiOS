//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "TerrainProfileTests.h"
#import "../METestManager.h"
#import "../METestConsts.h"
#import "TerrainMapFinder.h"

@implementation TerrainProfileHelper

+(void) showTowers:(METestManager *)testManager{
	METest* towers = [testManager testInCategory:@"Markers"
										  withName:@"Towers"];
	if(towers){
		[towers start];
	}
}

+(void) hideTowers:(METestManager *)testManager{
    METest* towers = [testManager testInCategory:@"Markers"
                                        withName:@"Towers"];
	if(towers){
		[towers stop];
	}
	
}

@end

@implementation TerrainProfileBasicTest

- (id) init{
	if(self==[super init]){
		self.name = @"SFO to RDU";
		self.routeViewHorizontalBuffer = 20;
		self.routeViewVerticalBuffer = 20;
		self.lookAtRouteAnimationDuration = 1.0;
        self.obstacleDatabasePath = [[NSBundle mainBundle] pathForResource:@"Towers"
                                        ofType:@"sqlite"];
		self.bufferRadius = 2.5;
		self.drawTerrainProfile = YES;
		self.terrainProfileViewHeight = 150;
		self.maxHeightInFeet = 15000;
		self.boundingGraphicsMapName = @"boundingGraphics";
	}
	return self;
}

- (void) dealloc{
	self.vectorLineStyle = nil;
	self.terrainProfileView = nil;
	self.wayPoints = nil;
	self.obstacleDatabasePath = nil;
}

- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(SFO_COORD.longitude, SFO_COORD.latitude)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(RDU_COORD.longitude, RDU_COORD.latitude)]];
	
}

- (void) start{
	if(self.isRunning){
		return;
	}
	
	[TerrainProfileHelper showTowers:self.meTestManager];
	
	//Stop other tests in this category
	[self.meTestManager stopCategory:self.meTestCategory.name];
	
	//Cache a marker image to represent obstacles
	[self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"pinRed"]
										  withName:@"pinRed"
								   compressTexture:NO
					nearestNeighborTextureSampling:NO];
	
	//Find all terrain maps on the device
	self.terrainMaps = [TerrainMapFinder getTerrainMaps];
	
	//Set wayopints for terrain profile
	[self createWayPoints];
	
	//Create vector line style
	self.vectorLineStyle = [[MELineStyle alloc]init];
	self.vectorLineStyle.strokeColor = [UIColor blueColor];
	self.vectorLineStyle.outlineColor = [UIColor blackColor];
	self.vectorLineStyle.strokeWidth = 4;
	self.vectorLineStyle.outlineWidth = 1;
	
	//Add terrain profile view
	[self addTerrainProfileView];
	
	//Add vector map to show a route
	[self addVectorMap];
	
	//Refresh the terrain profile.
	[self updateTerrainProfile];
	
	//Look at the route
	[self lookAtRoute];
	
	//[self addBoundingGraphics];
	
	self.isRunning = YES;
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
	[TerrainProfileHelper hideTowers:self.meTestManager];
	[self removeTerrainProfileView];
	[self removeVectorMap];
	[self.meMapViewController removeMap:@"obstacles" clearCache:YES];
	[self.meMapViewController removeMap:self.boundingGraphicsMapName clearCache:YES];
	
	self.isRunning = NO;
}

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
                                    withHorizontalBuffer:self.routeViewHorizontalBuffer
                                      withVerticalBuffer:self.routeViewVerticalBuffer
									   animationDuration:self.lookAtRouteAnimationDuration];
}

- (void) addTerrainProfileView{
	CGFloat maxWidth = self.meMapViewController.meMapView.bounds.size.width;
	CGFloat left = maxWidth * (1.0 / 6.0);
	CGFloat windowWidth = maxWidth * (2.0 / 3.0);
	CGRect frame = CGRectMake(left,20,
							  windowWidth,
							  self.terrainProfileViewHeight);
	self.terrainProfileView = [[TerrainProfileView alloc]initWithFrame:frame];
	[self.meMapViewController.meMapView addSubview:self.terrainProfileView];
	self.terrainProfileView.alpha = 0.75;
	self.terrainProfileView.drawTerrainProfile = self.drawTerrainProfile;
	[self.terrainProfileView setMaxHeightInFeet:self.maxHeightInFeet];
}

- (void) removeTerrainProfileView{
	[self.terrainProfileView removeFromSuperview];
	self.terrainProfileView = nil;
}

- (void) updateVectorMap{
	//Add a line across the United states.
	[self.meMapViewController clearDynamicGeometryFromMap:self.name];
    [self.meMapViewController addDynamicLineToVectorMap:self.name
												 lineId:@"route"
												 points:self.wayPoints
												  style:self.vectorLineStyle];
}

- (void) addVectorMap{
	
	//Add a vector map
	MEVectorMapInfo* vectorMapInfo = [[MEVectorMapInfo alloc]init];
	vectorMapInfo.name = self.name;
	vectorMapInfo.zOrder = 100;
	[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
    [self.meMapViewController setTesselationThresholdForMap:vectorMapInfo.name withThreshold:40];
	[self updateVectorMap];
	
}

- (void) removeVectorMap{
	[self.meMapViewController removeMap:self.name clearCache:YES];
}

- (void) terrainProfileUpdated{
}

- (void) showMarkersAlongRoute{
	if(!self.isRunning){
		return;
	}
	
	[self.meMapViewController removeMap:@"obstacles" clearCache:YES];
	
	//Early exit
	if(self.markersAlongRoute==nil || self.markersAlongRoute.count==0){
		return;
	}
	
	//Add dynamic marker map
	MEDynamicMarkerMapInfo* mapInfo = [[MEDynamicMarkerMapInfo alloc]init];
	mapInfo.hitTestingEnabled = NO;
	mapInfo.name = @"obstacles";
	mapInfo.zOrder = 100;
	mapInfo.meDynamicMarkerMapDelegate = self;
	mapInfo.meMapViewController = self.meMapViewController;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	//Add dynamic markers to the dynamic marker map
	for(MEMarker* marker in self.markersAlongRoute){
		MEDynamicMarker* dynamicMarker = [[MEDynamicMarker alloc]init];
		dynamicMarker.name=[NSString stringWithFormat:@"%d", marker.uid];
		dynamicMarker.location = marker.location;
		dynamicMarker.cachedImageName = @"pinRed";
		dynamicMarker.anchorPoint = CGPointMake(7,35);
		[self.meMapViewController addDynamicMarkerToMap:@"obstacles"
										  dynamicMarker:dynamicMarker];
	}
	
}

- (void) updateTerrainProfile{
	
	//Get 1 terrrain sample per pixel
	uint sampleCount = self.terrainProfileView.frame.size.width;
	
	//Ask mapping engine for terrain height and marker weights on another thread.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		//Update terrain height samples along route
		self.terrainProfileView.heightSamples =
		[METerrainProfiler getTerrainProfile:self.terrainMaps
										  wayPoints:self.wayPoints
								   samplePointCount:sampleCount
									  bufferRadius:self.bufferRadius];
		
		//Update marker weight samples along route
		self.terrainProfileView.weightSamples =
		[MEMarkerQuery getMaxMarkerWeightsAlongRoute:self.obstacleDatabasePath
												tableNamePrefix:@""
													  wayPoints:self.wayPoints
											   samplePointCount:sampleCount
												  bufferRadius:self.bufferRadius];
		
		//Get markers that lie along the route
		self.markersAlongRoute =
		[MEMarkerQuery getMarkersAlongRoute:self.obstacleDatabasePath
									   tableNamePrefix:@""
											 wayPoints:self.wayPoints
										 bufferRadius:self.bufferRadius];
		
		//Update view on main thread.
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.terrainProfileView setNeedsDisplay];
			[self terrainProfileUpdated];
			[self showMarkersAlongRoute];
			[self updateVectorMap];
		});
		
	});
}


- (double) lineSegmentHitTestPixelBufferDistance{
	return 10;
}

- (double) vertexHitTestPixelBufferDistance{
	return 10;
}

- (void) addBoundingGraphics{
	
	//Create polygon style
	self.polygonStyle = [[MEPolygonStyle alloc]initWithStrokeColor:[UIColor whiteColor]
														strokeWidth:2.0
														  fillColor:[UIColor blueColor]];
	
	[self updateBoundingGraphics];
}

- (void) updateBoundingGraphics{
	return;
	if([self.meMapViewController containsMap:self.boundingGraphicsMapName]){
		[self.meMapViewController removeMap:self.boundingGraphicsMapName clearCache:YES];
	}
	
	//Add a vector map
	MEVectorMapInfo* mapInfo = [[MEVectorMapInfo alloc]init];
	mapInfo.name = self.boundingGraphicsMapName;
	mapInfo.zOrder = 10;
	mapInfo.meVectorMapDelegate = self;
	mapInfo.alpha = 0.25;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	for(int i=0; i<self.wayPoints.count-1; i+=2){
		NSValue* v1 = [self.wayPoints objectAtIndex:i];
		NSValue* v2 = [self.wayPoints objectAtIndex:i+1];
		CGPoint p1 = [v1 CGPointValue];
		CGPoint p2 = [v2 CGPointValue];
		[self addPolyAroundPoints:p1 p2:p2];
	}
}

- (void) addPolyAroundPoints:(CGPoint) p1 p2:(CGPoint) p2{
	
	CGPoint startPoint = p1;
	CGPoint endPoint = p2;
	
	double heading = [MEMath courseFromPoint:startPoint toPoint:endPoint];
	double distance = [MEMath nauticalMilesBetween:startPoint point2:endPoint];
	
	NSMutableArray* points = [[NSMutableArray alloc]init];
	CGPoint bufferPoint = [MEMath pointOnRadial:startPoint radial:heading-180 distance:self.bufferRadius];
	
	//Compute points that represent the corridor around the radial
	CGPoint polypt1 = [MEMath pointOnRadial:bufferPoint radial:heading-90 distance:self.bufferRadius];
	CGPoint polypt2 = [MEMath pointOnRadial:polypt1 radial:heading distance:distance + self.bufferRadius*2];
	CGPoint polypt3 = [MEMath pointOnRadial:polypt2 radial:heading+90 distance:self.bufferRadius*2];
	CGPoint polypt4 = [MEMath pointOnRadial:polypt3 radial:heading+180 distance:distance+self.bufferRadius*2];
	
	//Add points of bounding box (being sure to close it)
	[points addObject:[NSValue valueWithCGPoint:polypt1]];
	[points addObject:[NSValue valueWithCGPoint:polypt2]];
	[points addObject:[NSValue valueWithCGPoint:polypt3]];
	[points addObject:[NSValue valueWithCGPoint:polypt4]];
	[points addObject:[NSValue valueWithCGPoint:polypt1]];
	
	[self.meMapViewController addPolygonToVectorMap:self.boundingGraphicsMapName
											 points:points
											  style:self.polygonStyle];
	
}

@end

///////////////////////////////////////////////////////////////////
//FF Case 254205 - BEGIN
static inline CLLocationCoordinate2D SurfaceLocationUsingDistance(CLLocationCoordinate2D sourceLocation, double distanceInNauticalMiles, double bearingTrue) {
    
    double lat1 = sourceLocation.latitude * M_PI / 180.0;
    double lon1 = sourceLocation.longitude * M_PI / 180.0;
    double distanceInKm = distanceInNauticalMiles / 0.539957;
    
    double dOverRadius = distanceInKm / 6371.0; // 6,371 km earth radius
    
    bearingTrue = bearingTrue * M_PI / 180.0;
    
    double lat2 = asin( sin(lat1)*cos(dOverRadius) +
                       cos(lat1)*sin(dOverRadius)*cos(bearingTrue) );
    double lon2 = lon1 + atan2(sin(bearingTrue)*sin(dOverRadius)*cos(lat1),
                               cos(dOverRadius)-sin(lat1)*sin(lat2));
    
    lat2 = lat2 * 180.0 / M_PI;
    lon2 = lon2 * 180.0 / M_PI;
    
    return CLLocationCoordinate2DMake(lat2, lon2);
}

@implementation FF254205

- (id) init{
	if(self==[super init]){
		self.name = @"FF254205";
		self.maxHeightInFeet = 8000;
	}
	return self;
}

- (void) updateTerrainProfile{
    
    uint sampleCount = 1024;
    self.bufferRadius = 1.0;
    
    //Ask mapping engine for terrain height and marker weights on another thread.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //Update terrain height samples along route
        NSDate *startTime = [NSDate date];
        
        NSMutableArray *testWaypoints2 = [NSMutableArray array];
        [testWaypoints2 addObject:[self.wayPoints lastObject]];
        CGPoint lastPoint3 = [[self.wayPoints lastObject] CGPointValue];
        CLLocationCoordinate2D lastCoord3 = CLLocationCoordinate2DMake(lastPoint3.y, lastPoint3.x);
        CLLocationCoordinate2D smallDistance2 = SurfaceLocationUsingDistance(lastCoord3, 1.2, 45); // 50'
        [testWaypoints2 addObject:[NSValue valueWithCGPoint:CGPointMake(smallDistance2.longitude, smallDistance2.latitude)]];
        
        self.terrainProfileView.heightSamples =
        [METerrainProfiler getTerrainProfile:self.terrainMaps
                                   wayPoints:testWaypoints2 //  self.wayPoints
                            samplePointCount:sampleCount
                                bufferRadius:self.bufferRadius];
        
        NSDate *endTime = [NSDate date];
        NSLog(@"Query Time (profile: %f): %f seconds", self.bufferRadius, [endTime timeIntervalSinceDate:startTime]);
        
        //Update view on main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.terrainProfileView setNeedsDisplay];
            [self terrainProfileUpdated];
            [self updateVectorMap];
        });
        
    });
}

@end
//FF Case 254205 - END
///////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////
@implementation TerrainProfileDeathValley
- (id) init{
	if(self==[super init]){
		self.name = @"Death Valley";
		self.maxHeightInFeet = 8000;
	}
	return self;
}
- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-117.041854, 36.375919)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-116.739261,  36.375919)]];
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileHighToLow
- (id) init{
	if(self==[super init]){
		self.name = @"High-to-Low";
		self.maxHeightInFeet = 18000;
	}
	return self;
}
- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-106.060844, 39.747982)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-104.960838, 39.748114)]];
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileVeryClose
- (id) init{
	if(self==[super init]){
		self.name = @"Very Close";
		self.maxHeightInFeet = 8000;
	}
	return self;
}

- (void) createWayPoints{
    CLLocationCoordinate2D ITEM1_COORD = {50.835556, -0.297222};
    CLLocationCoordinate2D ITEM2_COORD = {50.836100, -0.293483};
    self.wayPoints = [[NSMutableArray alloc]init];
    
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
                               CGPointMake(ITEM1_COORD.longitude, ITEM1_COORD.latitude)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
                               CGPointMake(ITEM2_COORD.longitude, ITEM2_COORD.latitude)]];
}


@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileLowToHigh
- (id) init{
	if(self==[super init]){
		self.name = @"Low-to-High";
		self.maxHeightInFeet = 18000;
	}
	return self;
}
- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-104.960838, 39.748114)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-106.060844, 39.747982)]];
    
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileAntiMeridian
- (id) init{
	if(self==[super init]){
		self.name = @"Antimeridian";
		self.maxHeightInFeet = 8000;
	}
	return self;
}
- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(179, 66)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-177.5,  66)]];
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileMtRanier
- (id) init{
	if(self==[super init]){
		self.name = @"Mt. Ranier";
		self.maxHeightInFeet = 18000;
	}
	return self;
}
- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.926567, 46.847675)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.757665, 46.854913)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.546668, 46.862655)]];
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileMtRanierAcuteA
- (id) init{
	if(self==[super init]){
		self.name = @"Mt. Ranier AcuteA";
	}
	return self;
}
- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.926567, 46.847675)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.757665, 46.854913)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.546668, 46.5)]];
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileMtRanierAcuteB
- (id) init{
	if(self==[super init]){
		self.name = @"Mt. Ranier AcuteB";
	}
	return self;
}
- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.926567, 46.847675)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.757665, 46.854913)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.546668, 47.1)]];
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileMtRanierObtuseA
- (id) init{
	if(self==[super init]){
		self.name = @"Mt. Ranier ObtuseA";
	}
	return self;
}
- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.926567, 46.847675)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.757665, 46.854913)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.926668, 46.5)]];
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileMtRanierObtuseB
- (id) init{
	if(self==[super init]){
		self.name = @"Mt. Ranier ObtuseB";
	}
	return self;
}
- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.926567, 46.847675)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.757665, 46.854913)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.926668, 47.1)]];
}
@end


///////////////////////////////////////////////////////////////////
@implementation TerrainProfileMtRanierSpiral

- (id) init{
	if(self==[super init]){
		self.name = @"Mt. Ranier Spiral";
		self.maxHeightInFeet = 18000;
	}
	return self;
}

- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.8441124224066,46.91694527653809)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.8394270467538,46.9170867249385)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.6704792731955,46.91375299169223)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.6682766931006,46.81269054057348)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.8404216181192,46.8152714863996)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.8412013647367,46.8703509470418)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-121.6921944109686,46.85820909733645)]];
	
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileMtRanierZigZag

- (id) init{
	if(self==[super init]){
		self.name = @"Mt. Ranier ZigZag";
		self.maxHeightInFeet = 18000;
	}
	return self;
}

- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
	
	double left = -121.926321;
	double bottom = 46.75821;
	double top = 46.915331;
	double right = -121.647174;
	double y = bottom;
	double xincr = (right-left)/10;
	for(double x = left; x < right; x+=xincr){
		[self.wayPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x,y)]];
		if(y==bottom){
			y=top;
		}
		else{
			y=bottom;
		}
	}
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileArctic
- (id) init{
	if(self==[super init]){
		self.name = @"Arctic";
		self.maxHeightInFeet = 5000;
	}
	return self;
}
- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-98.492675, 70.453721)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-102.552743, 78.653471)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-115.531997, 84.193925)]];
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileGrandCanyon
- (id) init{
	if(self==[super init]){
		self.name = @"Grand Canyon";
		self.maxHeightInFeet = 10000;
	}
	return self;
}
- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-112.167794, 36.037388)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-112.149790, 36.103913)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-112.119263, 36.222129)]];
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileGrandCanyonVeryShort
- (id) init{
	if(self==[super init]){
		self.name = @"Grand Canyon - Ultra short";
		self.maxHeightInFeet = 10000;
	}
	return self;
}
- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-112.167794, 36.037388)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-112.167794, 36.036388)]];
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileAtlanticOcean
- (id) init{
	if(self==[super init]){
		self.name = @"Atlantic Ocean";
		self.maxHeightInFeet = 5000;
	}
	return self;
}
- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-76.386507, 33.366498)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-18.451301, 19.526252)]];
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileEastBoundFlight
- (id) init{
	if(self==[super init]){
		self.name = @"Eastbound Flight";
		self.routeViewVerticalBuffer = 100;
		self.routeViewHorizontalBuffer = 150;
		self.lookAtRouteAnimationDuration = 0.75;
		self.interval = 0.01;
		self.maxHeightInFeet = 15000;
	}
	return self;
}

- (void) start{
	if(self.isRunning){
		return;
	}
	[TerrainProfileHelper showTowers:self.meTestManager];
	self.currLongitude = SFO_COORD.longitude;
	[super start];
	self.isRunning = YES;
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
	[TerrainProfileHelper hideTowers:self.meTestManager];
	[self stopTimer];
	[super stop];
	self.isRunning = NO;
}

- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(self.currLongitude, SFO_COORD.latitude)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(self.currLongitude+0.50, SFO_COORD.latitude)]];
}

- (void) timerTick {
	[self stopTimer];
	self.currLongitude+=0.05;
	[self createWayPoints];
	[self updateTerrainProfile];
	[self updateBoundingGraphics];
	[self lookAtRoute];
}

- (void) terrainProfileUpdated{
	if(!self.isRunning){
		return;
	}
	[self startTimer];
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileMtRanierScan
- (id) init{
	if(self==[super init]){
		self.name = @"Mt. Ranier Scan";
		self.maxHeightInFeet = 18000;
		self.routeViewVerticalBuffer = 100;
		self.routeViewHorizontalBuffer = 150;
		self.lookAtRouteAnimationDuration = 2.0;
		self.interval = 0.1;
		self.wLongitude = -121.879220;
		self.eLongitude = -121.631413;
		self.currLatitude = 46.939506;
	}
	return self;
}

- (void) start{
	if(self.isRunning){
		return;
	}
	[super start];
	self.isRunning = YES;
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
	[self stopTimer];
	if([self.meMapViewController containsMap:self.name]){
		[self.meMapViewController removeMap:self.name clearCache:YES];
	}
	[super stop];
	self.isRunning = NO;
}

- (void) createWayPoints{
	self.wayPoints = [[NSMutableArray alloc]init];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(self.wLongitude, self.currLatitude)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(self.eLongitude, self.currLatitude)]];
}

- (void) timerTick {
	[self stopTimer];
	self.currLatitude-=0.005;
	[self createWayPoints];
	[self updateTerrainProfile];
	[self updateBoundingGraphics];
	[self lookAtRoute];
}

- (void) terrainProfileUpdated{
	if(!self.isRunning){
		return;
	}
	[self startTimer];
}

@end

///////////////////////////////////////////////////////////////////
@implementation TerrainProfileSeattleScan
- (id) init{
	if(self==[super init]){
		self.name = @"Seattle Scan";
		self.routeViewVerticalBuffer = 100;
		self.routeViewHorizontalBuffer = 150;
		self.lookAtRouteAnimationDuration = 2.0;
		self.interval = 0.1;
		self.wLongitude = -122.406908;
		self.eLongitude = -122.267153;
		self.currLatitude = 47.621822;
		self.bufferRadius = 0.5;
		self.maxHeightInFeet = 2000;
	}
	return self;
}
- (void) timerTick {
	[self stopTimer];
	self.currLatitude-=0.0005;
	[self createWayPoints];
	[self updateTerrainProfile];
	[self updateBoundingGraphics];
}


@end

///////////////////////////////////////////////////////////////////
@implementation ShowObstacles
- (id) init{
	if(self==[super init]){
		self.name = @"Towers 10nm Radius of SFO Eastbound";
		self.currentLocation = SFO_COORD;
		self.radius = 10;
		self.distancePerCycle = self.radius / 2;
		self.heading = 90;
		self.bestFontSize = 14.0f;
		self.boundingGraphicsMapName = @"boundingGraphics";
	}
	return self;
}

- (void) start{
	if(self.isRunning){
		return;
	}
	//Stop other tests
	[self.meTestCategory stopAllTests];
	
	[TerrainProfileHelper showTowers:self.meTestManager];
	
	//Cache marker images
	[self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"pinRed"]
										  withName:@"pinRed"
								   compressTexture:NO
					nearestNeighborTextureSampling:NO];
	
	[self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"pinPurple"]
										  withName:@"pinPurple"
								   compressTexture:NO
					nearestNeighborTextureSampling:NO];
	
	//Add dynamic marker map for pins
	MEDynamicMarkerMapInfo* mapInfo = [[MEDynamicMarkerMapInfo alloc]init];
	mapInfo.hitTestingEnabled = NO;
	mapInfo.name = self.name;
	mapInfo.zOrder = 100;
	mapInfo.meDynamicMarkerMapDelegate = self;
	mapInfo.meMapViewController = self.meMapViewController;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	
	[self addBoundingGraphics];
	
	//Center camera
	[self.meMapViewController.meMapView setCenterCoordinate:self.currentLocation];
	
	
	self.interval = 1;
	[self startTimer];
	self.isRunning = YES;
}

- (void) addBoundingGraphics{
	//Add a vector circle to highlight where we're querying for markers
	MEAnimatedVectorCircle* vectorCircle = [[MEAnimatedVectorCircle alloc]init];
	vectorCircle.name = self.boundingGraphicsMapName;
	vectorCircle.location = self.currentLocation;
	vectorCircle.minRadius = self.radius;
	vectorCircle.maxRadius = self.radius;
	vectorCircle.useWorldSpace = YES;
	vectorCircle.zOrder = 10;
	[self.meMapViewController addAnimatedVectorCircle:vectorCircle];
}

- (void) updateBoundingGraphics{
	[self.meMapViewController updateAnimatedVectorCircleLocation:self.boundingGraphicsMapName
													 newLocation:self.currentLocation
											   animationDuration:self.interval/5];
}
- (void) removeBoundingGraphics{
	[self.meMapViewController removeMap:self.boundingGraphicsMapName clearCache:NO];
}

-(void) updateLocation{
	
	//Move the current location along the heading.
	CGPoint currentLocation = CGPointMake(self.currentLocation.longitude, self.currentLocation.latitude);
	CGPoint nextLocation = [MEMath pointOnRadial:currentLocation radial:self.heading distance:self.distancePerCycle];
	
	//Determine if we are crossing the pole for Due North and Due South headings
	BOOL crossingPole = NO;
	if(self.heading == 0){
		double distanceToNorthPole = [MEMath nauticalMilesBetween:currentLocation point2:CGPointMake(0,90)];
		if(distanceToNorthPole<self.distancePerCycle){
			crossingPole = YES;
		}
	}
	if(self.heading == 180){
		double distanceToSouthPole = [MEMath nauticalMilesBetween:currentLocation point2:CGPointMake(0,-90)];
		if(distanceToSouthPole<self.distancePerCycle){
			crossingPole = YES;
		}
	}
	
	//Flip headig if crossing the pole
	if(crossingPole){
		self.heading += 180;
		while(self.heading>=360){
			self.heading-=360;
		}
	}
	
	self.currentLocation = CLLocationCoordinate2DMake(nextLocation.y, nextLocation.x);
}

-(void) updateCamera{
	[self.meMapViewController.meMapView setCenterCoordinate:self.currentLocation animationDuration:self.interval];
}

- (void) timerTick{
	[self stopTimer];
	[self updateLocation];
	[self updateBoundingGraphics];
	[self updateCamera];
	[self showMarkers: self.currentLocation];
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
	[TerrainProfileHelper hideTowers:self.meTestManager];
	[self stopTimer];
	[self.meMapViewController removeMap:self.name clearCache:YES];
	[self removeBoundingGraphics];
	self.isRunning = NO;
}

- (BOOL) markerIsInSet:(MEMarker*) marker markerSet:(NSArray*) someMarkerSet{
	if(marker==nil){
		return NO;
	}
	if(someMarkerSet==nil){
		return NO;
	}
	for(MEMarker* otherMarker in someMarkerSet){
		if(otherMarker!=nil){
			if(otherMarker.uid == marker.uid){
				return YES;
			}
		}
	}
	return NO;
}

- (NSArray*) getMarkers:(CLLocationCoordinate2D) location{
	
	//Test getting highest marker
    NSString* towerDatabase = [[NSBundle mainBundle] pathForResource:@"Towers"
                                    ofType:@"sqlite"];
    
	self.highestMarker = [MEMarkerQuery getHighestMarkerAroundLocation:towerDatabase
																  tableNamePrefix:@""
																		 location:location
																		   radius:self.radius];
	
	//Return all markers
	return [MEMarkerQuery getMarkersAroundLocation:towerDatabase
									   tableNamePrefix:@""
											  location:location
												radius:self.radius];
	
	
}

- (void) showMarkers:(CLLocationCoordinate2D) location{
	
	__block NSArray* newMarkerSet;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		//Query for markers on background thread
		newMarkerSet = [self getMarkers:location];
		
		//Add dynamic marker map on main thread
		dispatch_async(dispatch_get_main_queue(), ^{
			
			//Add any new markers that have appeared.
			for(MEMarker* marker in newMarkerSet){
				if(![self markerIsInSet:marker markerSet:self.lastMarkerSet]){
					MEDynamicMarker* dynamicMarker = [[MEDynamicMarker alloc]init];
					dynamicMarker.name=[NSString stringWithFormat:@"%d", marker.uid];
					dynamicMarker.location = marker.location;
					dynamicMarker.cachedImageName = @"pinRed";
					dynamicMarker.anchorPoint = CGPointMake(7,35);
					[self.meMapViewController addDynamicMarkerToMap:self.name
													  dynamicMarker:dynamicMarker];
					
				}
			}
			
		
			//Remove markers that drop out, or change them back to red
			for(MEMarker* marker in self.lastMarkerSet){
				if(![self markerIsInSet:marker markerSet:newMarkerSet]){
					[self.meMapViewController removeDynamicMarkerFromMap:self.name
															  markerName:[NSString stringWithFormat:@"%d", marker.uid]];
				}
				else{
					[self.meMapViewController updateDynamicMarkerImage:self.name
															markerName:[NSString stringWithFormat:@"%d",
																		marker.uid]
													   cachedImageName:@"pinRed"
														   anchorPoint:CGPointMake(7,35)
																offset:CGPointMake(0,0)];
					//Unrotate
					[self.meMapViewController updateDynamicMarkerRotation:self.name
															   markerName:[NSString stringWithFormat:@"%d",
																		   marker.uid]
																 rotation:0
														animationDuration:self.interval/2];
				}
			}
			
			//Show the highest marker as purple pin instead of red pin
			if(self.highestMarker!=nil){
				[self.meMapViewController updateDynamicMarkerImage:self.name
														markerName:[NSString stringWithFormat:@"%d",
																	self.highestMarker.uid]
												   cachedImageName:@"pinPurple"
													   anchorPoint:CGPointMake(7,35)
															offset:CGPointMake(0,0)];
				
				//Rotate the highest marker to make it stand out
				[self.meMapViewController updateDynamicMarkerRotation:self.name
														   markerName:[NSString stringWithFormat:@"%d",
																	   self.highestMarker.uid]
															 rotation:180.0
													animationDuration:self.interval/2];
			}
			
			//Save the set of markers from the last run
			self.lastMarkerSet = newMarkerSet;
			
			//Restart timer
			[self startTimer];
		});
		
	});
}

@end


///////////////////////////////////////////////////////////////////
@implementation ShowObstacles2
- (id) init{
	if(self==[super init]){
		self.name = @"Towers 15nm Radius of HOU Northbound";
		self.currentLocation = HOU_COORD;
		self.radius = 15;
		self.distancePerCycle = self.radius;
		self.heading = 0;
	}
	return self;
}
@end

///////////////////////////////////////////////////////////////////
@implementation ShowObstacles3
- (id) init{
	if(self==[super init]){
		self.name = @"Towers 50nm Radius Pole-to-Pole";
		self.currentLocation = CLLocationCoordinate2DMake(-90,0);
		self.radius = 50;
		self.distancePerCycle = 500;
		self.heading = 0;
	}
	return self;
}
@end

///////////////////////////////////////////////////////////////////
@implementation ShowObstacles4
- (id) init{
	if(self==[super init]){
		self.name = @"Towers 10nm Box SFO Eastbound";
		self.currentLocation = SFO_COORD;
		self.radius = 5;
		self.distancePerCycle = self.radius;
		[self updateLocation];
	}
	return self;
}

-(void) updateLocation{
	
	//Move center
	[super updateLocation];
	
	//Compute coordinates of a bounding box centered around location
	//that has a diagonal dimension that is self.radius * 2 NM across
	double halfDiagonal = self.radius * M_SQRT2;
	CGPoint center = CGPointMake(self.currentLocation.longitude, self.currentLocation.latitude);
	CGPoint bottomLeft = [MEMath pointOnRadial:center radial:225 distance:halfDiagonal];
	CGPoint topRight = [MEMath pointOnRadial:center radial:45 distance:halfDiagonal];
	self.swCorner = CLLocationCoordinate2DMake(bottomLeft.y, bottomLeft.x);
	self.neCorner = CLLocationCoordinate2DMake(topRight.y, topRight.x);
}

- (NSArray*) getMarkers:(CLLocationCoordinate2D) location{
	
    NSString* towerDatabase = [[NSBundle mainBundle] pathForResource:@"Towers"
                                                              ofType:@"sqlite"];
    
	//Get highest marker
	self.highestMarker = [MEMarkerQuery getHighestMarkerInBoundingBox:towerDatabase
																 tableNamePrefix:@""
															   southWestLocation:self.swCorner
															   northEastLocation:self.neCorner];

	//Return the rest
	return [MEMarkerQuery getMarkersInBoundingBox:towerDatabase
											 tableNamePrefix:@""
										   southWestLocation:self.swCorner
										   northEastLocation:self.neCorner];
}

- (double) lineSegmentHitTestPixelBufferDistance{return 10;}
- (double) vertexHitTestPixelBufferDistance{return 10;}

- (void) addBoundingGraphics{
	
	//Create polygon style
	self.polygonStyle = [[MEPolygonStyle alloc]initWithStrokeColor:[UIColor whiteColor]
														strokeWidth:2.0
														  fillColor:[UIColor blueColor]];
	
	[self updateBoundingGraphics];
}

- (void) updateBoundingGraphics{
	
	if([self.meMapViewController containsMap:self.boundingGraphicsMapName]){
		[self.meMapViewController removeMap:self.boundingGraphicsMapName clearCache:YES];
	}
	
	//Add a vector map
	MEVectorMapInfo* mapInfo = [[MEVectorMapInfo alloc]init];
	mapInfo.name = self.boundingGraphicsMapName;
	mapInfo.zOrder = 10;
	mapInfo.meVectorMapDelegate = self;
	mapInfo.alpha = 0.25;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	
	NSMutableArray* points = [[NSMutableArray alloc]init];
	
	//Add points of bounding box
	[points addObject:[NSValue valueWithCGPoint:CGPointMake(self.swCorner.longitude,
															self.swCorner.latitude)]];
	
	[points addObject:[NSValue valueWithCGPoint:CGPointMake(self.swCorner.longitude,
															self.neCorner.latitude)]];
	
	[points addObject:[NSValue valueWithCGPoint:CGPointMake(self.neCorner.longitude,
															self.neCorner.latitude)]];
	
	[points addObject:[NSValue valueWithCGPoint:CGPointMake(self.neCorner.longitude,
															self.swCorner.latitude)]];
	
	[points addObject:[NSValue valueWithCGPoint:CGPointMake(self.swCorner.longitude,
															self.swCorner.latitude)]];
	
	[self.meMapViewController addPolygonToVectorMap:self.boundingGraphicsMapName
											 points:points
											  style:self.polygonStyle];
	
	
}

@end

///////////////////////////////////////////////////////////////////
@implementation ShowObstacles5
- (id) init{
	if(self==[super init]){
		self.name = @"Obstacles 50nm Box RDU Northbound";
		self.currentLocation = RDU_COORD;
		self.radius = 25;
		self.distancePerCycle = self.radius;
		self.heading = 0;
		[self updateLocation];
	}
	return self;
}
@end

///////////////////////////////////////////////////////////////////
@implementation ShowObstacles6
- (id) init{
	if(self==[super init]){
		self.name = @"Obstacles on Radial";
		self.currentLocation = SFO_COORD;
		self.radius = 25;
		self.distancePerCycle = self.radius;
		self.heading = 0;
		[self updateLocation];
		self.lineStyle = [[MELineStyle alloc]init];
		self.lineStyle.strokeColor = [UIColor blueColor];
		self.lineStyle.strokeWidth = 3;
		self.lineStyle.outlineColor = [UIColor whiteColor];
		self.lineStyle.outlineWidth = 2;
		self.interval = 0.1;
		self.bufferRadius = 1.0;
	}
	return self;
}

- (void) start{
	self.heading = 0;
	[super start];
	[super updateCamera];
}

- (void) updateCamera{
	return;
}

- (NSArray*) getMarkers:(CLLocationCoordinate2D) location{
	
	//Get highest marker
	/*
	self.highestMarker = [MEMarkerQuery getHighestMarkerInBoundingBox:[MarkerTestData towerMarkerBundlePath]
																 tableNamePrefix:@""
															   southWestLocation:self.swCorner
															   northEastLocation:self.neCorner];*/
	
	//Return the rest
    NSString* towerDatabase = [[NSBundle mainBundle] pathForResource:@"Towers"
                                                              ofType:@"sqlite"];
	return [MEMarkerQuery getMarkersOnRadial:towerDatabase
										tableNamePrefix:@""
											   location:self.currentLocation
												 radial:self.heading
											   distance:self.distancePerCycle
										  bufferRadius:self.bufferRadius];
	
}

- (void) updateBoundingGraphics{
	
	if([self.meMapViewController containsMap:self.boundingGraphicsMapName]){
		[self.meMapViewController removeMap:self.boundingGraphicsMapName clearCache:YES];
	}
	
	//Add a vector map
	MEVectorMapInfo* mapInfo = [[MEVectorMapInfo alloc]init];
	mapInfo.name = self.boundingGraphicsMapName;
	mapInfo.zOrder = 10;
	mapInfo.meVectorMapDelegate = self;
	mapInfo.alpha = 0.25;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	
	
	CGPoint startPoint = CGPointMake(self.currentLocation.longitude,
									  self.currentLocation.latitude);
	CGPoint endPoint = [MEMath pointOnRadial:startPoint
									  radial:self.heading
									distance:self.distancePerCycle];
	
	NSMutableArray* points = [[NSMutableArray alloc]init];
	CGPoint bufferPoint = [MEMath pointOnRadial:startPoint radial:self.heading-180 distance:self.bufferRadius];
	
	//Compute points that represent the corridor around the radial
	CGPoint p1 = [MEMath pointOnRadial:bufferPoint radial:self.heading-90 distance:self.bufferRadius];
	CGPoint p2 = [MEMath pointOnRadial:p1 radial:self.heading distance:self.distancePerCycle + self.bufferRadius*2];
	CGPoint p3 = [MEMath pointOnRadial:p2 radial:self.heading+90 distance:self.bufferRadius*2];
	CGPoint p4 = [MEMath pointOnRadial:p3 radial:self.heading+180 distance:self.distancePerCycle+self.bufferRadius*2];
	
	//Add points of bounding box (being sure to close it)
	[points addObject:[NSValue valueWithCGPoint:p1]];
	[points addObject:[NSValue valueWithCGPoint:p2]];
	[points addObject:[NSValue valueWithCGPoint:p3]];
	[points addObject:[NSValue valueWithCGPoint:p4]];
	[points addObject:[NSValue valueWithCGPoint:p1]];
	
	[self.meMapViewController addPolygonToVectorMap:self.boundingGraphicsMapName
											 points:points
											  style:self.polygonStyle];
	
	
	
	//Add a line
	[self.meMapViewController setTesselationThresholdForMap:self.boundingGraphicsMapName
											  withThreshold:5];
	NSMutableArray* linePoints=[[NSMutableArray alloc]init];
	[linePoints addObject:[NSValue valueWithCGPoint:startPoint]];
	[linePoints addObject:[NSValue valueWithCGPoint:endPoint]];
	[self.meMapViewController addDynamicLineToVectorMap:self.boundingGraphicsMapName lineId:@"" points:linePoints style:self.lineStyle];
	
}

- (void) updateLocation{
	self.heading+=1;
	if(self.heading==360){
		self.heading = 0;
	}
}

@end

/////////////////////////////////////////////////////////////
@implementation  TerrainMinMaxInBounds

- (id) init{
	if(self==[super init]){
		self.name = @"Min/Max - Boxes";
		self.terrainProfileViewHeight=150;
	}
	return self;
}

- (void) start{
	if(self.isRunning){
		return;
	}
	
	//Stop other tests in this category
	[self.meTestManager stopCategory:self.meTestCategory.name];
	
	
	self.terrainMaps = [TerrainMapFinder getTerrainMaps];

	[TerrainProfileHelper showTowers:self.meTestManager];
	
	//Cache purple pin
	[self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"pinPurple"] withName:@"pinPurple" compressTexture:NO nearestNeighborTextureSampling:YES];
	
	[self addMarkers];
	[self updateCamera];
	self.isRunning = YES;
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
	[TerrainProfileHelper hideTowers:self.meTestManager];
	
	[self.meMapViewController removeMap:self.name clearCache:NO];
	[self.meMapViewController removeMap:@"highestTowers" clearCache:NO];
	
	self.isRunning = NO;
}

-(void) updateCamera{
	[self lookAtUnitedStates];
}

-(void) addMarkers{
	
	//Create a marker for every 1/2 degree in the US
	NSMutableArray* markers = [[NSMutableArray alloc]init];
	
	//Add lat lon labels for world
	for(double lon=-180; lon<180; lon+=1){
		for(double lat=-90; lat<90; lat+=1){
			//Add marker to label lat lon
			MEMarkerAnnotation* marker = [[MEMarkerAnnotation alloc] init];
			marker.coordinate = CLLocationCoordinate2DMake(lat, lon);
			marker.metaData = @"";
			[markers addObject:marker];
		}
	}

	//Add 1/4 arc-hour markers in Continental US
	double startLon = -128;
	double endLon = -66;
	double startLat = 24;
	double endLat = 50;
	for(double lon=startLon; lon<endLon; lon+=1){
		for(double lat=startLat; lat<endLat; lat+=1){
						
			//Add terrain sample markers
			//Add marker to label lat lon
			MEMarkerAnnotation* marker = [[MEMarkerAnnotation alloc] init];
			marker.coordinate = CLLocationCoordinate2DMake(lat + 0.25, lon + 0.25);
			marker.metaData = @"T";
			[markers addObject:marker];
			
			marker = [[MEMarkerAnnotation alloc] init];
			marker.coordinate = CLLocationCoordinate2DMake(lat + 0.25, lon + 0.75);
			marker.metaData = @"T";
			[markers addObject:marker];
			
			marker = [[MEMarkerAnnotation alloc] init];
			marker.coordinate = CLLocationCoordinate2DMake(lat + 0.75, lon + 0.25);
			marker.metaData = @"T";
			[markers addObject:marker];
			
			marker = [[MEMarkerAnnotation alloc] init];
			marker.coordinate = CLLocationCoordinate2DMake(lat + 0.75, lon + 0.75);
			marker.metaData = @"T";
			[markers addObject:marker];
		}
	}
	
	MEMarkerMapInfo* mapInfo = [[MEMarkerMapInfo alloc]init];
	mapInfo.hitTestingEnabled = YES;
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeMemoryMarker;
	mapInfo.zOrder = 20;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.markers = markers;
	mapInfo.clusterDistance = 50;
	mapInfo.maxLevel = 10;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	//Add a dynamic marker map to show highest marker
	//Add dynamic marker map for pins
	MEDynamicMarkerMapInfo* dynMarkerMapInfo = [[MEDynamicMarkerMapInfo alloc]init];
	dynMarkerMapInfo.hitTestingEnabled = NO;
	dynMarkerMapInfo.name = @"highestTowers";
	dynMarkerMapInfo.zOrder = 19;
	dynMarkerMapInfo.meDynamicMarkerMapDelegate = self;
	dynMarkerMapInfo.meMapViewController = self.meMapViewController;
	[self.meMapViewController addMapUsingMapInfo:dynMarkerMapInfo];
	
}

- (CGFloat) metersToFeet:(CGFloat) meters{
	return meters * 3.28084;
}


-(void) addMarker:(MEMarker*) marker{
	//Add higest marker to dynamic marker map
	MEDynamicMarker* dynamicMarker = [[MEDynamicMarker alloc]init];
	dynamicMarker.name=[NSString stringWithFormat:@"%d", marker.uid];
	dynamicMarker.location = marker.location;
	dynamicMarker.cachedImageName = @"pinPurple";
	dynamicMarker.anchorPoint = CGPointMake(7,35);
	[self.meMapViewController addDynamicMarkerToMap:@"highestTowers"
									  dynamicMarker:dynamicMarker];
}

-(double) convertToMSA:(double) height{
	int msa = height / 100;
	msa=msa*100;
	msa=msa+200;
	msa=msa/100;
	return msa;
}

-(double) getMaxTerrainHeight:(CLLocationCoordinate2D) location{
	
	CLLocationCoordinate2D swCorner = CLLocationCoordinate2DMake(location.latitude-0.25,
																 location.longitude-0.25);
	CLLocationCoordinate2D neCorner = CLLocationCoordinate2DMake(location.latitude+0.25,
																 location.longitude+0.25);
	
	CGPoint minMax  = [METerrainProfiler getMinMaxTerrainHeightsInBoundingBox:self.terrainMaps
															  southWestLocation:swCorner
															  northEastLocation:neCorner];
	return [self metersToFeet:minMax.y];
}

//Gets the higest marker in a 1/2 degree x 1/2 degree box
//as seen on a sectional
-(double) getMaxMarkerHeight:(CLLocationCoordinate2D) location{
	
	CLLocationCoordinate2D swCorner = CLLocationCoordinate2DMake(location.latitude-0.25,
																  location.longitude-0.25);
	CLLocationCoordinate2D neCorner = CLLocationCoordinate2DMake(location.latitude+0.25,
																 location.longitude+0.25);
	//Get highest marker
    NSString* towerDatabase = [[NSBundle mainBundle] pathForResource:@"Towers"
                                                              ofType:@"sqlite"];
	MEMarker* highestMarker = [MEMarkerQuery getHighestMarkerInBoundingBox:towerDatabase
																 tableNamePrefix:@""
															   southWestLocation:swCorner
															   northEastLocation:neCorner];
	
	if(highestMarker==nil){
		return 0;
	}
	
	//Add marker to map
	//[self addMarker:highestMarker];
	
	return [self metersToFeet:highestMarker.weight];
}

// Implement MEMarkerMapDelegate methods
- (void) mapView:(MEMapView *)mapView
updateMarkerInfo:(MEMarkerInfo *)markerInfo
		 mapName:(NSString *)mapName
{
    float fontSize = 12.5f;
    UIColor* fillColor = [UIColor whiteColor];
    UIColor* strokeColor = [UIColor blackColor];
	NSString* label;
	if([markerInfo.metaData isEqualToString:@"T"]){
		strokeColor = [UIColor grayColor];
		fontSize = 28.0f;
		fillColor = [UIColor blueColor];
		double maxHeight = [self getMaxMarkerHeight:markerInfo.location];
		if(maxHeight==0){
			maxHeight = [self getMaxTerrainHeight:markerInfo.location];
			fillColor = [UIColor greenColor];
			label=[NSString stringWithFormat:@"%02.0f",maxHeight];
		}
		else{
			label=[NSString stringWithFormat:@"%02.0f",
				   [self convertToMSA:maxHeight]];
		}
	}
	else{
	label=[NSString stringWithFormat:@"%0.1f° %0.1f°",
					 markerInfo.location.latitude,
					 markerInfo.location.longitude];
	}
	
    UIImage* textImage=[MEFontUtil newImageWithFontOutlined:@"Helvetica"
												   fontSize:fontSize
												  fillColor:fillColor
												strokeColor:strokeColor
												strokeWidth:0
													   text:label];
    
    //Craete an anhor point based on the image size
    CGPoint anchorPoint = CGPointMake(textImage.size.width / 2.0,
                                      textImage.size.height / 2.0);
    //Update the marker info
	markerInfo.uiImage = textImage;
	markerInfo.anchorPoint = anchorPoint;
}


- (void) addTerrainProfileView{
	CGFloat maxWidth = self.meMapViewController.meMapView.bounds.size.width;
	CGFloat left = maxWidth * (1.0 / 6.0);
	CGFloat windowWidth = maxWidth * (2.0 / 3.0);
	CGRect frame = CGRectMake(left,20,
							  windowWidth,
							  self.terrainProfileViewHeight);
	self.terrainProfileView = [[TerrainProfileView alloc]initWithFrame:frame];
	[self.meMapViewController.meMapView addSubview:self.terrainProfileView];
	self.terrainProfileView.alpha = 0.75;
	self.terrainProfileView.drawTerrainProfile = YES;
	[self.terrainProfileView setMaxHeightInFeet:10000];
}

- (void) removeTerrainProfileView{
	[self.terrainProfileView removeFromSuperview];
	self.terrainProfileView = nil;
}

@end

/////////////////////////////////////////////////////////////
@implementation TerrainMinMaxAroundLocation

- (id) init{
	if(self==[super init]){
		self.name = @"Min/Max - Circles";
	}
	return self;
}

-(double) getMaxTerrainHeight:(CLLocationCoordinate2D) location{
	
	CGPoint minMax  = [METerrainProfiler getMinMaxTerrainHeightsAroundLocation:self.terrainMaps
																			 location:location
																			   radius:5];
	return [self metersToFeet:minMax.y];
}

@end


/////////////////////////////////////////////////////////////
@implementation TerrainMinMaxInBounds2

- (id) init{
	if(self==[super init]){
		self.name = @"Min/Max Bounds - Mt. Ranier";
		self.boundingGraphicsMapName = @"boundingGraphics";
		self.neCorner = CLLocationCoordinate2DMake(46.858643, -121.748950);
		self.swCorner = CLLocationCoordinate2DMake(46.446286, -122.395238);
		self.expectedHeights = @"14,411 ft (4,392 m)";
		self.terrainMaps = [TerrainMapFinder getTerrainMaps];
	}
	return self;
}

-(double) getMaxHeight:(CLLocationCoordinate2D) location radius:(double)radius {
    CGPoint minMax = [METerrainProfiler getMinMaxTerrainHeightsAroundLocation:self.terrainMaps location:location radius:radius];
    return [self metersToFeet:minMax.y];
}

- (NSString *)applicationDocumentsDirectory:(NSString*)file {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
    
    NSString *path = [url.path stringByAppendingPathComponent:file];
    return path;
}


- (void) start {
	if(self.isRunning){
		return;
	}
	[self.meTestManager stopCategory:self.meTestCategory.name];
	[self addBoundingGraphics];
	[self lookAt];
	[self addMarkerMap];
	[self getTerrainMinMax];
    
//    const int SIZE = 1201;
//    NSFileHandle* file = [NSFileHandle fileHandleForReadingAtPath:[self applicationDocumentsDirectory:@"N44W072.hgt"]];
//    self.srtmData = [file readDataOfLength:SIZE*SIZE*2];
    
//    [self runTest:44.266452 lon:-71.676197 SRTM:2362 OSM:2358.923960 ME:2129.265137];
//    [self runTest:44.378393 lon:-71.708976 SRTM:1807 OSM:1827.427880 ME:1712.598511];
//    [self runTest:44.439226 lon:-71.270355 SRTM:3254 OSM:3254.593280 ME:3175.853027];
//    [self runTest:44.407838 lon:-71.537583 SRTM:1620 OSM:1601.049920 ME:1482.939697];
//    [self runTest:44.506065 lon:-71.414542 SRTM:4146 OSM:4127.296720 ME:3966.535645];
//    [self runTest:44.506168 lon:-71.182299 SRTM:2043 OSM:2063.648360 ME:1935.695557];
//    [self runTest:44.318952 lon:-71.396745 SRTM:2729 OSM:2749.343920 ME:2660.761230];
//    [self runTest:44.346727 lon:-71.780645 SRTM:1948 OSM:1958.661480 ME:1699.475098];
//    [self runTest:44.344505 lon:-71.627029 SRTM:1719 OSM:715.879320  ME:1564.960693];
//    [self runTest:44.330895 lon:-71.499247 SRTM:3523 OSM:3556.430560 ME:3402.231201];
//    [self runTest:44.251731 lon:-71.517580 SRTM:2490 OSM:2503.280920 ME:2273.622070];
//    [self runTest:44.316174 lon:-71.379244 SRTM:3041 OSM:3047.900360 ME:2883.858398];
//    [self runTest:44.454225 lon:-71.615363 SRTM:1817 OSM:1837.270400 ME:1302.493530];
//    [self runTest:44.454781 lon:-71.587585 SRTM:1830 OSM:1840.551240 ME:1505.905518];
//    [self runTest:44.517834 lon:-71.400914 SRTM:3805 OSM:3832.021120 ME:3408.792725];
//    [self runTest:44.394504 lon:-71.691754 SRTM:1886 OSM:1893.044680 ME:1811.023682];
//    [self runTest:44.112845 lon:-71.418132 SRTM:3625 OSM:3667.979120 ME:3467.847900];
//    [self runTest:44.030347 lon:-71.302017 SRTM:3179 OSM:3202.099840 ME:3097.113037];
//    [self runTest:44.074510 lon:-71.923698 SRTM:2729 OSM:2782.152320 ME:2316.272949];
//    [self runTest:44.030900 lon:-71.820362 SRTM:4491 OSM:4527.559200 ME:4478.346680];
//    [self runTest:44.152918 lon:-71.531214 SRTM:4635 OSM:4698.162880 ME:4635.827148];
//    [self runTest:44.332007 lon:-71.343688 SRTM:3418 OSM:3369.422680 ME:3175.853027];
//    [self runTest:44.093401 lon:-71.447576 SRTM:4632 OSM:4665.354480 ME:4445.538086];
//    [self runTest:44.267288 lon:-71.178962 SRTM:4803 OSM:4826.115640 ME:4616.142090];
//    [self runTest:44.029233 lon:-71.872029 SRTM:3523 OSM:3553.149720 ME:3408.792725];
//    [self runTest:44.166453 lon:-71.814531 SRTM:2549 OSM:2631.233680 ME:2480.314941];
//    [self runTest:44.202842 lon:-71.605638 SRTM:3205 OSM:3238.189080 ME:2952.756104];
//    [self runTest:44.471169 lon:-71.200910 SRTM:2011 OSM:2030.839960 ME:1722.441040];
//    [self runTest:44.249510 lon:-71.330631 SRTM:4947 OSM:4973.753440 ME:4921.259766];
//    [self runTest:44.187221 lon:-71.610724 SRTM:4337 OSM:4412.729800 ME:4091.207520];
//    [self runTest:44.228674 lon:-71.794810 SRTM:1896 OSM:1916.010560 ME:1870.078857];
//    [self runTest:44.002290 lon:-71.710359 SRTM:1988 OSM:2007.874080 ME:1847.112915];
//    [self runTest:44.221731 lon:-71.512024 SRTM:4032 OSM:4048.556560 ME:3999.343994];
//    
//    
//    [self runTest:44.417282 lon:-71.392302 SRTM:3572.834651 OSM:3566.272971 ME:3986.220703];
//    [self runTest:44.418671 lon:-71.354801 SRTM:2795.275595 OSM:2801.837275 ME:3280.840088];
//    [self runTest:44.312838 lon:-71.962870 SRTM:1719.160108 OSM:1732.283467 ME:2063.648438];
//    [self runTest:44.477558 lon:-71.394247 SRTM:3543.307092 OSM:3549.868772 ME:4146.981934];
//    [self runTest:44.330062 lon:-71.480636 SRTM:2969.160110 OSM:2975.721789 ME:3402.231201];
//    [self runTest:44.340616 lon:-71.801201 SRTM:1564.960632 OSM:1558.398953 ME:1683.070923];
//    [self runTest:44.324508 lon:-71.288131 SRTM:5344.488197 OSM:5357.611557 ME:5728.346680];
//    [self runTest:44.321730 lon:-71.300354 SRTM:5521.653552 OSM:5518.372712 ME:5728.346680];
//    [self runTest:44.283398 lon:-71.251185 SRTM:2821.522314 OSM:2795.275595 ME:3244.750732];
//    [self runTest:44.074791 lon:-71.318129 SRTM:1200.787403 OSM:1135.170605 ME:2152.230957];
//    [self runTest:44.240619 lon:-71.649806 SRTM:1706.036748 OSM:1722.440947 ME:1965.223145];
//    [self runTest:44.325341 lon:-71.300631 SRTM:5305.118118 OSM:5334.645677 ME:5728.346680];
//    [self runTest:44.315897 lon:-71.306465 SRTM:5200.131242 OSM:5216.535441 ME:5728.346680];
//    [self runTest:44.390339 lon:-71.064519 SRTM:1223.753283 OSM:1250.000002 ME:1729.002686];
//    [self runTest:44.206454 lon:-71.428133 SRTM:3392.388457 OSM:3398.950136 ME:3753.281006];
//    [self runTest:44.191452 lon:-71.935090 SRTM:1056.430448 OSM:1085.958007 ME:1292.651001];
//    [self runTest:44.437004 lon:-71.097854 SRTM:2782.152235 OSM:2785.433075 ME:3070.866211];
//    [self runTest:44.182842 lon:-71.703418 SRTM:2227.690292 OSM:2237.532812 ME:2375.328125];
//    [self runTest:44.101180 lon:-71.113405 SRTM:2539.370083 OSM:2578.740161 ME:2621.391113];
//    [self runTest:44.043403 lon:-71.314796 SRTM:1791.338585 OSM:1768.372706 ME:2893.700928];
//    [self runTest:44.019791 lon:-71.365074 SRTM:1866.797903 OSM:1886.482943 ME:2188.320312];
//    [self runTest:44.033403 lon:-71.146182 SRTM:757.874017  OSM:757.874017  ME:984.252014 ];
//    [self runTest:44.252654 lon:-71.294072 SRTM:5459.317594 OSM:5459.317594 ME:6253.281250];
//    [self runTest:44.458670 lon:-71.166743 SRTM:1715.879268 OSM:1709.317588 ME:2007.874023];
//    [self runTest:44.093124 lon:-71.289518 SRTM:1400.918637 OSM:1414.041997 ME:2139.107666];
//    [self runTest:44.202845 lon:-71.105906 SRTM:3307.086619 OSM:3280.839900 ME:3480.971191];
//    [self runTest:44.419783 lon:-71.074798 SRTM:1358.267719 OSM:1394.356958 ME:2526.246826];
//    [self runTest:44.057569 lon:-71.092848 SRTM:1653.543310 OSM:1673.228349 ME:1735.564331];
//    [self runTest:44.136457 lon:-71.332575 SRTM:3024.934388 OSM:3077.427826 ME:3129.921387];
//    [self runTest:44.407283 lon:-71.032297 SRTM:1272.965881 OSM:1282.808401 ME:1801.181152];
//    [self runTest:44.204233 lon:-71.310630 SRTM:3805.774284 OSM:3809.055124 ME:3969.816406];
//    [self runTest:44.107012 lon:-71.395353 SRTM:3300.524939 OSM:3313.648299 ME:3871.391113];
//    [self runTest:44.161457 lon:-71.195906 SRTM:1558.398953 OSM:1587.926512 ME:2171.916016];
//    [self runTest:44.215622 lon:-71.062017 SRTM:2864.173233 OSM:2929.790031 ME:3520.341309];
//    [self runTest:44.240343 lon:-71.350354 SRTM:4688.320217 OSM:4753.937015 ME:4921.259766];
//    [self runTest:44.201456 lon:-71.280630 SRTM:3110.236225 OSM:3090.551186 ME:3969.816406];

	self.isRunning = YES;
}

- (void) stop {
	if(!self.isRunning){
		return;
	}
	[self removeBoundingGraphics];
	[self removeMarkerMap];
	self.isRunning = NO;
}

- (double) lineSegmentHitTestPixelBufferDistance{return 10;}
- (double) vertexHitTestPixelBufferDistance{return 10;}

- (void) removeBoundingGraphics{
	[self.meMapViewController removeMap:self.boundingGraphicsMapName clearCache:YES];
}

- (void) addBoundingGraphics{
	
	//Create polygon style
	self.polygonStyle = [[MEPolygonStyle alloc]initWithStrokeColor:[UIColor whiteColor]
														strokeWidth:2.0
														  fillColor:[UIColor redColor]];
		
	//Add a vector map
	MEVectorMapInfo* mapInfo = [[MEVectorMapInfo alloc]init];
	mapInfo.name = self.boundingGraphicsMapName;
	mapInfo.zOrder = 10;
	mapInfo.meVectorMapDelegate = self;
	mapInfo.alpha = 0.25;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	
	NSMutableArray* points = [[NSMutableArray alloc]init];
	
	//Add points of bounding box
	[points addObject:[NSValue valueWithCGPoint:CGPointMake(self.swCorner.longitude,
															self.swCorner.latitude)]];
	
	[points addObject:[NSValue valueWithCGPoint:CGPointMake(self.swCorner.longitude,
															self.neCorner.latitude)]];
	
	[points addObject:[NSValue valueWithCGPoint:CGPointMake(self.neCorner.longitude,
															self.neCorner.latitude)]];
	
	[points addObject:[NSValue valueWithCGPoint:CGPointMake(self.neCorner.longitude,
															self.swCorner.latitude)]];
	
	[points addObject:[NSValue valueWithCGPoint:CGPointMake(self.swCorner.longitude,
															self.swCorner.latitude)]];
	
	[self.meMapViewController addPolygonToVectorMap:self.boundingGraphicsMapName
											 points:points
											  style:self.polygonStyle];
	
	
}

- (void) lookAt{
	[self.meMapViewController.meMapView lookAtCoordinate:self.swCorner
                                           andCoordinate:self.neCorner
                                    withHorizontalBuffer:100
                                      withVerticalBuffer:100
									   animationDuration:0.5];
}

- (void) addMarkerMap{
	MEDynamicMarkerMapInfo* mapInfo = [[MEDynamicMarkerMapInfo alloc]init];
	mapInfo.hitTestingEnabled = NO;
	mapInfo.name = @"markers";
	mapInfo.zOrder = 100;
	mapInfo.meDynamicMarkerMapDelegate = self;
	mapInfo.meMapViewController = self.meMapViewController;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];

}

- (void) removeMarkerMap{
	[self.meMapViewController removeMap:@"markers" clearCache:YES];
}

- (CGFloat) metersToFeet:(CGFloat) meters{
	return meters * 3.28084;
}

- (void) addMarker:(CGPoint) minMax{
	
	double minFeet = [self metersToFeet:minMax.x];
	double maxFeet = [self metersToFeet:minMax.y];
	
	
	NSString* label=[NSString stringWithFormat:@"Min: %0.0f ft (%0.0f m) Max: %0.0f ft (%0.0f m) Expected:%@",
					 minFeet,
					 minMax.x,
					 maxFeet,
					 minMax.y,
					 self.expectedHeights];
	
	UIImage* textImage=[MEFontUtil newImageWithFontOutlined:@"Helvetica"
												   fontSize:15
												  fillColor:[UIColor whiteColor]
												strokeColor:[UIColor blackColor]
												strokeWidth:0
													   text:label];
    
    //Craete an anhor point based on the image size
    CGPoint anchorPoint = CGPointMake(textImage.size.width / 2.0,
                                      textImage.size.height / 2.0);
	
	double lon = self.swCorner.longitude + (self.neCorner.longitude - self.swCorner.longitude)/2;
	double lat = self.swCorner.latitude + (self.neCorner.latitude - self.swCorner.latitude)/2;
	
	MEDynamicMarker* marker = [[MEDynamicMarker alloc]init];
	marker.uiImage = textImage;
	marker.anchorPoint = anchorPoint;
	marker.location = CLLocationCoordinate2DMake(lat,lon);
	[self.meMapViewController addDynamicMarkerToMap:@"markers" dynamicMarker:marker];
}

- (void) getTerrainMinMax{
	
	__block CGPoint minMax;
	
	//Ask mapping engine for terrain height and marker weights on another thread.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		minMax = [METerrainProfiler getMinMaxTerrainHeightsInBoundingBox:self.terrainMaps
																	  southWestLocation:self.swCorner
																	  northEastLocation:self.neCorner];
		
		//Update view on main thread.
		dispatch_async(dispatch_get_main_queue(), ^{
			[self addMarker: minMax];
		});
		
	});
	
}

@end

/////////////////////////////////////////////////////////////
@implementation TerrainMinMaxInBounds3

- (id) init{
	if(self==[super init]){
		self.name = @"Min/Max Bounds - Mt. Adams";
		self.boundingGraphicsMapName = @"boundingGraphics";
		self.neCorner = CLLocationCoordinate2DMake( 46.227789, -121.049032);
		self.swCorner = CLLocationCoordinate2DMake(45.990993, -121.578231);
		self.expectedHeights = @"12,281 ft (3,743 m)";
		self.terrainMaps = [TerrainMapFinder getTerrainMaps];
	}
	return self;
}
@end


/////////////////////////////////////////////////////////////
@implementation TerrainMinMaxInBoundsA

- (id) init{
	if(self==[super init]){
		self.name = @"Min/Max Bounds - Mt. Ranier 0.5 arc hour";
		self.boundingGraphicsMapName = @"boundingGraphics";
        
        //46°51′10″N 121°45′37″WCoordinates: 46°51′10″N 121°45′37″W[5]
		self.neCorner = CLLocationCoordinate2DMake(46.5, -122);
		self.swCorner = CLLocationCoordinate2DMake(47, -121.5);
		self.expectedHeights = @"14,441 ft";
		self.terrainMaps = [TerrainMapFinder getTerrainMaps];
	}
	return self;
}
@end

/////////////////////////////////////////////////////////////
@implementation TerrainMinMaxInBoundsB

- (id) init{
	if(self==[super init]){
		self.name = @"Min/Max Bounds - Mt. Ranier 1 arc hour";
		self.boundingGraphicsMapName = @"boundingGraphics";
        
        //46°51′10″N 121°45′37″WCoordinates: 46°51′10″N 121°45′37″W[5]
		self.neCorner = CLLocationCoordinate2DMake(46, -122);
		self.swCorner = CLLocationCoordinate2DMake(47, -121);
		self.expectedHeights = @"14,441 ft";
		self.terrainMaps = [TerrainMapFinder getTerrainMaps];
	}
	return self;
}
@end

/////////////////////////////////////////////////////////////
@implementation TerrainMinMaxInBoundsC

- (id) init{
	if(self==[super init]){
		self.name = @"Min/Max Bounds - Mt. Ranier 10 arc hours";
		self.boundingGraphicsMapName = @"boundingGraphics";
        // 45, -125
		self.neCorner = CLLocationCoordinate2DMake(40, -130);
		self.swCorner = CLLocationCoordinate2DMake(50, -120);
		self.expectedHeights = @"14,441 ft";
		self.terrainMaps = [TerrainMapFinder getTerrainMaps];
	}
	return self;
}
@end
