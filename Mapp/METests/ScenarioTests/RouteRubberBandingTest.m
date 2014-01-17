//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import "RouteRubberBandingTest.h"
#include "../METestManager.h"
#import "../../MapManager/MEMap.h"
#import "../../MapManager/MEMapCategory.h"
#import "../../MapManager/MapManager.h"

///////////////////////////////////////////////////////////////////////
@implementation RouteRubberBandingTest

- (id) init{
    if(self = [super init]){
        self.name=@"Route Rubber-banding";
        self.markerMapName = [NSString stringWithFormat:@"%@ Markers",
                              self.name];
        //Create gesture recognizer
        self.longPress = [[[UILongPressGestureRecognizer alloc]
                          initWithTarget:self
                          action:@selector(handleLongPress:)]autorelease];
        self.longPress.minimumPressDuration = 2.0;
        
        //Line fill
        self.fillStyle = [[[MELineStyle alloc]init]autorelease];
        self.fillStyle.strokeColor = [UIColor yellowColor];
        self.fillStyle.outlineColor = [UIColor blackColor];
        self.fillStyle.strokeWidth = 4;
        self.fillStyle.outlineWidth = 1;
        
        //Create route marker view controller
        self.routeMarkerViewController = [[[RouteMarkerViewController alloc]
                                          initWithNibName:@"RouteMarkerViewController"
                                          bundle:nil]autorelease];
		
		self.JFK = CGPointMake(-73.78208504094064,40.64365972925757);
		self.SFO = CGPointMake(-122.3736948394537,37.61931125933241);
		self.HOU = CGPointMake(-86.5538765, 34.6435065);
		self.MIA = CGPointMake(-80.27914615027547,25.79475488150219);
		self.RDU = CGPointMake(-78.790864, 35.882872);
        
    }
    return self;
}

- (void) dealloc{
    self.longPress = nil;
    self.fillStyle = nil;
    self.routeMarkerViewController = nil;
    self.markerMapName = nil;
    [super dealloc];
}


- (void) addMarkerMap{
	MEDynamicMarkerMapInfo* mapInfo = [[[MEDynamicMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.markerMapName;
	mapInfo.zOrder = 101;
	mapInfo.meDynamicMarkerMapDelegate = self;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

- (void) start{
	if(self.isRunning)
		return;
	[self.meTestManager stopEntireCategory:self.meTestCategory];
	
    //Register view to handle long presse gesture
    //with the MEMapView
	[self.meMapViewController.meMapView addGestureRecognizer:self.longPress];
    
	
	[self addMarkerMap];
	
    //Add markers to route endpoint
    [self addEndpointMarkers];
    
    [self lookAtUnitedStates];
	
	MEVectorMapInfo* vectorMapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
	vectorMapInfo.name = self.name;
	vectorMapInfo.zOrder = 100;
	[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
    [self.meMapViewController setTesselationThresholdForMap:vectorMapInfo.name withThreshold:40];
	
    //Add some mid-point between Raleigh and Houston
    
    
    CLLocationCoordinate2D coord;
    coord.longitude = (self.HOU.x + self.RDU.x)/2.0;
    coord.latitude = (self.HOU.y + self.RDU.y)/2.0;
    [self updateRoute:coord];
    
    self.isRunning = YES;
	
}

- (void) stop
{
	if(!self.isRunning)
		return;
	
    //Unregister the gesture recognizer
    [self.meMapViewController.meMapView removeGestureRecognizer:self.longPress];
    
    //Remove the vector layer
    [self.meMapViewController removeMap:self.name
                                           clearCache:YES];
    
    //Remove marker layer
    [self.meMapViewController removeMap:self.markerMapName
                                   clearCache:YES];
    
    self.isRunning = NO;
}


-(UIImage*) createMarkerImage:(NSString*) label{
	@synchronized(self.routeMarkerViewController){
		
		UIImage* markerImage;
		
		//Update text on the view
		[self.routeMarkerViewController updateRouteLabelText:label];
		
		//Render the marker to image and return the data
		markerImage = [MEImageUtil createImageFromView:self.routeMarkerViewController.view];
		
		return markerImage;
	}
}


- (void) addEndpointMarkers{
	//Add a marker for Houston
	MEDynamicMarker* marker = [[[MEDynamicMarker alloc]init]autorelease];
    marker.location = CLLocationCoordinate2DMake(self.HOU.y, self.HOU.x);
    marker.name=@"HOU";
	marker.uiImage=[self createMarkerImage:@"HOU"];
	marker.anchorPoint = CGPointMake(marker.uiImage.size.width/2, marker.uiImage.size.height/2);
	[self.meMapViewController addDynamicMarkerToMap:self.markerMapName dynamicMarker:marker];
	
	//Add a marker for Raleigh
	marker.location = CLLocationCoordinate2DMake(self.RDU.y, self.RDU.x);
	marker.name = @"RDU";
	marker.uiImage = [self createMarkerImage:@"RDU"];
	marker.anchorPoint = CGPointMake(marker.uiImage.size.width/2, marker.uiImage.size.height/2);
	[self.meMapViewController addDynamicMarkerToMap:self.markerMapName dynamicMarker:marker];
	
}

- (void) updateRoute:(CLLocationCoordinate2D) midPointCoord{
    
	CGPoint midPoint = CGPointMake(midPointCoord.longitude, midPointCoord.latitude);
	
	self.routePoints = [[[NSMutableArray alloc]init]autorelease];
    
    [self.routePoints addObject:[NSValue valueWithCGPoint:self.HOU]];
    [self.routePoints addObject:[NSValue valueWithCGPoint:midPoint]];
    [self.routePoints addObject:[NSValue valueWithCGPoint:self.RDU]];
	
	[self.meMapViewController clearDynamicGeometryFromMap:self.name];
	
    [self.meMapViewController addDynamicLineToVectorMap:self.name
												 lineId:@"route"
												 points:self.routePoints
												  style:self.fillStyle];
	
	//Update distance label
	double distance = [MEMath nauticalMilesInRoute:self.routePoints];
	NSString* label = [NSString stringWithFormat:@"Distance = %f", distance];
	[self.lblDistance setText:label];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture{
    CGPoint viewPoint=[gesture locationInView:self.meMapViewController.meMapView];
    
    CLLocationCoordinate2D coordinate=[self.meMapViewController.meMapView convertPoint:viewPoint];
    
    //Here you would add a new point to your path
    if(UIGestureRecognizerStateBegan == gesture.state){
        //Add a new point where the user tapped.
        [self updateRoute:coordinate];
    }
    
    //Here the new point is moved around
    if(UIGestureRecognizerStateChanged == gesture.state){
        [self updateRoute:coordinate];
    }
	
    //Here you might integrate the point into your path
    if(UIGestureRecognizerStateEnded == gesture.state){
        [self updateRoute:coordinate];
    }
}

@end


///////////////////////////////////////////////////////////////////////
@implementation TerrainProfileTest

- (id) init{
    if(self = [super init]){
        self.name=@"Terrain Profile";
    }
    return self;
}

- (void) dealloc{
    [super dealloc];
	self.terrainMaps = nil;
}


- (void) addTerrainProfileView{
	CGRect frame = CGRectMake(0,0,
							  self.meMapViewController.meMapView.bounds.size.width,
							  150);
	self.terrainProfileView = [[[TerrainProfileView alloc]initWithFrame:frame]autorelease];
	[self.meMapViewController.meMapView addSubview:self.terrainProfileView];
}

- (void) removeTerrainProfileView{
	[self.terrainProfileView removeFromSuperview];
	self.terrainProfileView = nil;
}

- (void) addTerrainMaps:(MEMapCategory*) mapCategory{
	for(MEMap* map in mapCategory.Maps){
		MEMapFileInfo* mapFileInfo = [[[MEMapFileInfo alloc]init]autorelease];
		mapFileInfo.sqliteFileName = map.MapIndexFileName;
		mapFileInfo.dataFileName = map.MapFileName;
		[self.terrainMaps addObject:mapFileInfo];
	}
}

- (void) findTerrainMaps{
	self.terrainMaps = [[[NSMutableArray alloc]init]autorelease];
	MapManager* mapManager = [[[MapManager alloc]init]autorelease];
	[self addTerrainMaps:[mapManager categoryWithName:@"BaseMaps"]];
	[self addTerrainMaps:[mapManager categoryWithName:@"Terrain_Subsets"]];
}

- (void) addLabel{
	CGRect lblFrame = CGRectMake(0,300,300,50);
	self.lblDistance = [[[UILabel alloc]initWithFrame:lblFrame]autorelease];
	[self.meMapViewController.meMapView addSubview:self.lblDistance];
	[self.lblDistance setText:@""];
}

- (void) removeLabel{
	[self.lblDistance removeFromSuperview];
	self.lblDistance = nil;
}

- (void) start{
	if(self.isRunning)
		return;
	
	[self findTerrainMaps];
	[self addLabel];
	[self addTerrainProfileView];
	
	//Cache a marker image.
	UIImage* markerImage = [UIImage imageNamed:@"blueCircleSolid"];
	self.markerAnchorPoint = CGPointMake(markerImage.size.width/2,
										 markerImage.size.height/2);
	[self.meMapViewController addCachedMarkerImage:markerImage
										  withName:@"bluedot"
								   compressTexture:NO
					nearestNeighborTextureSampling:NO];
	
	[super start];
	
	
}

- (void) addPointMarkerMap{
	MEDynamicMarkerMapInfo* mapInfo = [[[MEDynamicMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = @"dots";
	mapInfo.zOrder = 102;
	mapInfo.meDynamicMarkerMapDelegate = self;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

- (void) removePointMarkerMap{
	[self.meMapViewController removeMap:@"dots" clearCache:YES];
}

- (void) updateTerrainProfile{
	
	uint sampleCount = self.terrainProfileView.frame.size.width;
	__block NSMutableArray* wayPoints = [[NSMutableArray alloc]init];
	for(NSObject* point in self.routePoints){
		[wayPoints addObject:point];
	}
	//Ask mapping engine for terrain height and marker weights on another thread.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		//Update terrain height samples along route
		self.terrainProfileView.heightSamples =
		[METerrainProfiler getTerrainProfile:self.terrainMaps
										  wayPoints:wayPoints
								   samplePointCount:sampleCount
									   bufferRadius:0.1];
		
		
		//Update view on main thread.
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.terrainProfileView setNeedsDisplay];
		});
		
	});
}


- (void) updateRoute:(CLLocationCoordinate2D) midPointCoord{
    [super updateRoute:midPointCoord];
	
	[self removePointMarkerMap];
	[self addPointMarkerMap];
	
	MEDynamicMarker* marker = [[[MEDynamicMarker alloc]init]autorelease];
    
    marker.cachedImageName = @"bluedot";
	marker.anchorPoint = self.markerAnchorPoint;
	
	//Tesselate the route
	NSArray* tesselatedPoints = [MEMath tesselateRoute:self.routePoints pointCount:15];
	
	//Show the tesselated points for the route as marker dots
	int i = 0;
	for(NSValue* v in tesselatedPoints){
		CGPoint cgp = [v CGPointValue];
		marker.location = CLLocationCoordinate2DMake(cgp.y, cgp.x);
		marker.name = [NSString stringWithFormat:@"%d",i];
		i++;
		[self.meMapViewController addDynamicMarkerToMap:@"dots"
										  dynamicMarker:marker];
	}
	
	[self updateTerrainProfile];
}


- (void) stop{
	if(!self.isRunning)
		return;
    [super stop];
	[self removeLabel];
	[self removeTerrainProfileView];
	[self removePointMarkerMap];
}

@end
