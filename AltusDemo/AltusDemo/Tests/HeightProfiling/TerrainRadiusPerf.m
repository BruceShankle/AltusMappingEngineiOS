//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "TerrainRadiusPerf.h"
#import "../METestManager.h"
#import "../METestConsts.h"
#import "TerrainMapFinder.h"

@implementation TerrainRadiusPerf

- (id) init{
	if(self==[super init]){
		self.name = @"Radius Perf - No Cache";
		self.boundingGraphicsMapName = @"boundingGraphics";
		self.peakLocation = MT_RANIER;
		self.radialFromPeak = 0; //Radial on which to center circle
		self.nauticalMileRadius = 1.5; //Radius of circle to sample heights
		self.natticalMilesFromPeak = 1.4; //Distance from center of circle to peak
        self.useCache = NO;
        [self computeCenter];
        
	}
	return self;
}


- (void) computeCenter{
    
    //Compute the center location of the circle
    CGPoint peakPoint = CGPointMake(self.peakLocation.longitude,
                                    self.peakLocation.latitude);
    
    CGPoint centerPoint = [MEMath pointOnRadial:peakPoint
                                         radial:self.radialFromPeak
                                       distance:self.natticalMilesFromPeak];
    
    self.centerLocation = CLLocationCoordinate2DMake(centerPoint.y,
                                                     centerPoint.x);
}

- (void) start{
	if(self.isRunning){
		return;
	}
	
	//Stop other tests in this category
	[self.meTestManager stopCategory:self.meTestCategory.name];
    
    //Get all terrain maps to sample from
	self.terrainMaps = [TerrainMapFinder getTerrainMaps];
    
    //Move camera to area of focus
	[self.meMapViewController.meMapView lookAtCoordinate:self.peakLocation
										   andCoordinate:self.centerLocation
									withHorizontalBuffer:100
									  withVerticalBuffer:100
									   animationDuration:1.0];
    
    self.isRunning = YES;
    
    [self addMarkerMap];
    
    [self nextQuery];
}

- (void) nextQuery{
    
    if(!self.isRunning){
        return;
    }
    
    //Increment radial
    self.radialFromPeak=self.radialFromPeak+1.0;
    if(self.radialFromPeak>=360){
        self.radialFromPeak = 0;
    }
    [self computeCenter];
    
    //Remove last set of stuff
    [self removeBoundingGraphics];
	
    [self addBoundingGraphics];
	
	[self getTerrainMinMax];
}

- (void) stop{
    
	if(!self.isRunning){
		return;
	}
    
	[self removeBoundingGraphics];
	[self removeMarkerMap];
//    self.terrainProfileCache = nil;
	self.isRunning = NO;
}

- (double) lineSegmentHitTestPixelBufferDistance{return 10;}

- (double) vertexHitTestPixelBufferDistance{return 10;}

- (void) addBoundingGraphics{
	
	//Cache red pin.
	[self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"pinRed"]
										  withName:@"pinRed"
								   compressTexture:NO
					nearestNeighborTextureSampling:NO];
	
	//Add a dynamic marker map
	//Create polygon style
	self.polygonStyle = [[MEPolygonStyle alloc]initWithStrokeColor:[UIColor whiteColor]
														strokeWidth:2.0
														  fillColor:[UIColor blueColor]];
	
    
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
	
	[self addCircle:self.centerLocation nauticalMileRadius:self.nauticalMileRadius];
	
}

- (void) removeBoundingGraphics{
	[self.meMapViewController removeMap:self.boundingGraphicsMapName clearCache:YES];
}

- (void) addCircle:(CLLocationCoordinate2D) centerLocation nauticalMileRadius:(double) nauticalMileRadius{
	
	CGPoint centerPoint=CGPointMake(centerLocation.longitude, centerLocation.latitude);
	
	CGPoint startPoint = [MEMath pointOnRadial:centerPoint radial:0 distance:nauticalMileRadius];
	NSMutableArray* points = [[NSMutableArray alloc]init];
	[points addObject:[NSValue valueWithCGPoint:startPoint]];
	for(double radial=0; radial<350; radial+=10){
		CGPoint p = [MEMath pointOnRadial:centerPoint radial:radial distance:nauticalMileRadius];
		[points addObject:[NSValue valueWithCGPoint:p]];
	}
	[points addObject:[NSValue valueWithCGPoint:startPoint]];
	
	[self.meMapViewController addPolygonToVectorMap:self.boundingGraphicsMapName
											 points:points
											  style:self.polygonStyle];
	
}

- (void) addMarkerMap{
	MEDynamicMarkerMapInfo* mapInfo = [[MEDynamicMarkerMapInfo alloc]init];
	mapInfo.hitTestingEnabled = NO;
	mapInfo.name = @"markers";
	mapInfo.zOrder = 100;
	mapInfo.meDynamicMarkerMapDelegate = self;
    mapInfo.fadeEnabled = NO;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	//Add pin for peak
	MEMarker* marker = [[MEMarker alloc]init];
	marker.uniqueName = @"peak";
	marker.cachedImageName = @"pinRed";
	marker.anchorPoint = marker.anchorPoint = CGPointMake(7,35);
	marker.location = self.peakLocation;
	[self.meMapViewController addDynamicMarkerToMap:@"markers" dynamicMarker:marker];
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
	
	
	NSString* label=[NSString stringWithFormat:@"Time: %fs Min: %0.0f ft  Max: %0.0f ft ",
                     [self.endTime timeIntervalSinceDate:self.startTime],
					 minFeet,
					 maxFeet];
	
    NSLog(label);
	UIImage* textImage=[MEFontUtil newImageWithFontOutlined:@"Helvetica"
												   fontSize:15
												  fillColor:[UIColor whiteColor]
												strokeColor:[UIColor blackColor]
												strokeWidth:0
													   text:label];
    
    //Craete an anhor point based on the image size
    CGPoint anchorPoint = CGPointMake(textImage.size.width / 2.0,
                                      textImage.size.height / 2.0);
	
	MEMarker* marker = [[MEMarker alloc]init];
    marker.uniqueName = [NSString stringWithFormat:@"%f", self.radialFromPeak];
	marker.uiImage = textImage;
	marker.anchorPoint = anchorPoint;
	marker.location = self.centerLocation;
	[self.meMapViewController addDynamicMarkerToMap:@"markers" dynamicMarker:marker];
}

- (void) getTerrainMinMax{
	
	__block CGPoint minMax;
	
    self.startTime = [NSDate date];
	//Ask mapping engine for terrain height and marker weights on another thread.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        

            minMax = [METerrainProfiler getMinMaxTerrainHeightsAroundLocation:self.terrainMaps
                                                                 location:self.centerLocation
                                                                   radius:self.nauticalMileRadius];
 
        
		//Update view on main thread.
		dispatch_async(dispatch_get_main_queue(), ^{
            self.endTime = [NSDate date];
			[self addMarker: minMax];
            [self nextQuery];
		});
		
	});
	
}
@end


@implementation TerrainRadiusPerfCached
- (id) init{
	if(self==[super init]){
		self.name = @"Radius Perf - Cached";
        self.useCache = YES;
	}
	return self;
}
@end

@implementation TerrainRadiusPerfCachedBigRadius
- (id) init{
	if(self==[super init]){
		self.name = @"Radius Perf - Cached Larg";
        self.useCache = YES;
        self.nauticalMileRadius = 18.5; //Radius of circle to sample heights
		self.natticalMilesFromPeak = 18.4; //Distance from center of circle to peak
	}
	return self;
}
@end
