//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "TerrainProfileTests.h"
#import "../METestManager.h"
#import "../METestConsts.h"
#import "../../MapManager/MEMap.h"
#import "../../MapManager/MEMapCategory.h"
#import "../../MapManager/MapManager.h"
#import "../MarkerTests/MarkerTestData.h"
#import "../METestConsts.h"
#import "TerrainMapFinder.h"

@implementation TerrainProfileHelper

+(void) showTowers:(METestManager *)testManager{
	METest* towers = [testManager testFromCategoryName:@"Markers"
										  withTestName:@"Aviation Towers: From Bundle"];
	if(towers){
		[towers start];
	}
}

+(void) hideTowers:(METestManager *)testManager{
	METest* towers = [testManager testFromCategoryName:@"Markers"
										  withTestName:@"Aviation Towers: From Bundle"];
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
		self.obstacleDatabasePath = [MarkerTestData towerMarkerBundlePath];
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
	[super dealloc];
}

- (void) createWayPoints{
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
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
	[self.meTestManager stopEntireCategory:self.meTestCategory];
	
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
	self.vectorLineStyle = [[[MELineStyle alloc]init]autorelease];
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
	self.terrainProfileView = [[[TerrainProfileView alloc]initWithFrame:frame]autorelease];
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
	MEVectorMapInfo* vectorMapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
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
	MEDynamicMarkerMapInfo* mapInfo = [[[MEDynamicMarkerMapInfo alloc]init]autorelease];
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
		
		/* This is for debugging
		 UIImage* textImage = [MEFontUtil newImageWithFontOutlined:@"Helvetica"
														 fontSize:10
														fillColor:[UIColor redColor]
													  strokeColor:[UIColor blackColor]
													  strokeWidth:0
															 text:[NSString stringWithFormat:@"%d", marker.uid]];
		CGPoint anchorPoint = CGPointMake(textImage.size.width / 2.0,
										  textImage.size.height / 2.0);
		dynamicMarker.uiImage = textImage;
		dynamicMarker.anchorPoint = anchorPoint;
		 */
		
		dynamicMarker.anchorPoint = CGPointMake(7,35);
		[self.meMapViewController addDynamicMarkerToMap:@"obstacles"
										  dynamicMarker:dynamicMarker];
		[dynamicMarker release];
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
	self.polygonStyle = [[[MEPolygonStyle alloc]initWithStrokeColor:[UIColor whiteColor]
														strokeWidth:2.0
														  fillColor:[UIColor blueColor]]autorelease];
	
	[self updateBoundingGraphics];
}

- (void) updateBoundingGraphics{
	return;
	if([self.meMapViewController containsMap:self.boundingGraphicsMapName]){
		[self.meMapViewController removeMap:self.boundingGraphicsMapName clearCache:YES];
	}
	
	//Add a vector map
	MEVectorMapInfo* mapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
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
	
	NSMutableArray* points = [[[NSMutableArray alloc]init]autorelease];
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
@implementation TerrainProfileDeathValley
- (id) init{
	if(self==[super init]){
		self.name = @"Death Valley";
		self.maxHeightInFeet = 8000;
	}
	return self;
}
- (void) createWayPoints{
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-106.060844, 39.747982)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-104.960838, 39.748114)]];
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
	
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-112.167794, 36.037388)]];
	[self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-112.149790, 36.103913)]];
    [self.wayPoints addObject:[NSValue valueWithCGPoint:
							   CGPointMake(-112.119263, 36.222129)]];
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
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
	self.wayPoints = [[[NSMutableArray alloc]init]autorelease];
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
	MEDynamicMarkerMapInfo* mapInfo = [[[MEDynamicMarkerMapInfo alloc]init]autorelease];
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
	MEAnimatedVectorCircle* vectorCircle = [[[MEAnimatedVectorCircle alloc]init]autorelease];
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
	self.highestMarker = [MEMarkerQuery getHighestMarkerAroundLocation:[MarkerTestData towerMarkerBundlePath]
																  tableNamePrefix:@""
																		 location:location
																		   radius:self.radius];
	
	//Return all markers
	return [MEMarkerQuery getMarkersAroundLocation:[MarkerTestData towerMarkerBundlePath]
									   tableNamePrefix:@""
											  location:location
												radius:self.radius];
	
	
}

- (void) showMarkers:(CLLocationCoordinate2D) location{
	
	__block NSArray* newMarkerSet;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		//Query for markers on background thread
		newMarkerSet = [self getMarkers:location];
		
		//Retain because we need it on another thread.
		[newMarkerSet retain];
		
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
					[dynamicMarker release];
					
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
			[newMarkerSet release];
			
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
	
	//Get highest marker
	self.highestMarker = [MEMarkerQuery getHighestMarkerInBoundingBox:[MarkerTestData towerMarkerBundlePath]
																 tableNamePrefix:@""
															   southWestLocation:self.swCorner
															   northEastLocation:self.neCorner];

	//Return the rest
	return [MEMarkerQuery getMarkersInBoundingBox:[MarkerTestData towerMarkerBundlePath]
											 tableNamePrefix:@""
										   southWestLocation:self.swCorner
										   northEastLocation:self.neCorner];
}

- (double) lineSegmentHitTestPixelBufferDistance{return 10;}
- (double) vertexHitTestPixelBufferDistance{return 10;}

- (void) addBoundingGraphics{
	
	//Create polygon style
	self.polygonStyle = [[[MEPolygonStyle alloc]initWithStrokeColor:[UIColor whiteColor]
														strokeWidth:2.0
														  fillColor:[UIColor blueColor]]autorelease];
	
	[self updateBoundingGraphics];
}

- (void) updateBoundingGraphics{
	
	if([self.meMapViewController containsMap:self.boundingGraphicsMapName]){
		[self.meMapViewController removeMap:self.boundingGraphicsMapName clearCache:YES];
	}
	
	//Add a vector map
	MEVectorMapInfo* mapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
	mapInfo.name = self.boundingGraphicsMapName;
	mapInfo.zOrder = 10;
	mapInfo.meVectorMapDelegate = self;
	mapInfo.alpha = 0.25;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	
	NSMutableArray* points = [[[NSMutableArray alloc]init]autorelease];
	
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
		self.lineStyle = [[[MELineStyle alloc]init]autorelease];
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
	return [MEMarkerQuery getMarkersOnRadial:[MarkerTestData towerMarkerBundlePath]
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
	MEVectorMapInfo* mapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
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
	
	NSMutableArray* points = [[[NSMutableArray alloc]init]autorelease];
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
	NSMutableArray* linePoints=[[[NSMutableArray alloc]init]autorelease];
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
	[self.meTestManager stopEntireCategory:self.meTestCategory];
	
	
	self.terrainMaps = [TerrainMapFinder getTerrainMaps];

	[TerrainProfileHelper showTowers:self.meTestManager];
	
	//Cache purple pin
	[self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"pinPurple"] withName:@"pinPurple" compressTexture:NO nearestNeighborTextureSampling:YES];
	
	//Turn on a grid for the planet
	self.vectorLines = [self.meTestManager testFromCategoryName:@"Vector Tile Providers"
													  withTestName:@"Simple Lines"];
	if(self.vectorLines){
		[self.vectorLines start];
	}
	
	[self addMarkers];
	[self updateCamera];
	self.isRunning = YES;
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
	[TerrainProfileHelper hideTowers:self.meTestManager];
	if(self.vectorLines){
		[self.vectorLines stop];
	}
	[self.meMapViewController removeMap:self.name clearCache:NO];
	[self.meMapViewController removeMap:@"highestTowers" clearCache:NO];
	
	self.isRunning = NO;
}

-(void) updateCamera{
	[self lookAtUnitedStates];
}

-(void) addMarkers{
	
	//Create a marker for every 1/2 degree in the US
	NSMutableArray* markers = [[[NSMutableArray alloc]init]autorelease];
	
	//Add lat lon labels for world
	for(double lon=-180; lon<180; lon+=1){
		for(double lat=-90; lat<90; lat+=1){
			//Add marker to label lat lon
			MEMarkerAnnotation* marker = [[MEMarkerAnnotation alloc] init];
			marker.coordinate = CLLocationCoordinate2DMake(lat, lon);
			marker.metaData = @"";
			[markers addObject:marker];
			[marker release];
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
			[marker release];
		}
	}
	
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
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
	MEDynamicMarkerMapInfo* dynMarkerMapInfo = [[[MEDynamicMarkerMapInfo alloc]init]autorelease];
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
	MEMarker* highestMarker = [MEMarkerQuery getHighestMarkerInBoundingBox:[MarkerTestData towerMarkerBundlePath]
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
	[textImage release];
}


- (void) addTerrainProfileView{
	CGFloat maxWidth = self.meMapViewController.meMapView.bounds.size.width;
	CGFloat left = maxWidth * (1.0 / 6.0);
	CGFloat windowWidth = maxWidth * (2.0 / 3.0);
	CGRect frame = CGRectMake(left,20,
							  windowWidth,
							  self.terrainProfileViewHeight);
	self.terrainProfileView = [[[TerrainProfileView alloc]initWithFrame:frame]autorelease];
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


- (void) start {
	if(self.isRunning){
		return;
	}
	[self.meTestManager stopEntireCategory:self.meTestCategory];
	[self addBoundingGraphics];
	[self lookAt];
	[self addMarkerMap];
	[self getTerrainMinMax];
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
	self.polygonStyle = [[[MEPolygonStyle alloc]initWithStrokeColor:[UIColor whiteColor]
														strokeWidth:2.0
														  fillColor:[UIColor redColor]]autorelease];
		
	//Add a vector map
	MEVectorMapInfo* mapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
	mapInfo.name = self.boundingGraphicsMapName;
	mapInfo.zOrder = 10;
	mapInfo.meVectorMapDelegate = self;
	mapInfo.alpha = 0.25;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	
	NSMutableArray* points = [[[NSMutableArray alloc]init]autorelease];
	
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
	MEDynamicMarkerMapInfo* mapInfo = [[[MEDynamicMarkerMapInfo alloc]init]autorelease];
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
					 maxFeet,
					 minMax.x,
					 minFeet,
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
	
	MEDynamicMarker* marker = [[[MEDynamicMarker alloc]init]autorelease];
	marker.uiImage = textImage;
	marker.anchorPoint = anchorPoint;
	marker.location = CLLocationCoordinate2DMake(lat,lon);
	[self.meMapViewController addDynamicMarkerToMap:@"markers" dynamicMarker:marker];
    
	[textImage release];
	
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
