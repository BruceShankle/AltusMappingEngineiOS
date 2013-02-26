//
//  ViewController.m
//  MyMap
//
//  Created by Bruce Shankle III on 2/5/13.
//  Copyright (c) 2013 BA3, LLC. All rights reserved.
//
// Tutorial 10:
//	* Builds on Tutorial 8 and adds a simple route planning system.

#import "ViewController.h"
#import "LocationData.h"

@interface ViewController ()

@end

@implementation ViewController

- (void) initializeMappingEngine
{
	//Create view controller
	self.meMapViewController=[[[MEMapViewController alloc]init]autorelease];
	self.meMapViewController.verboseMessagesEnabled = YES;
	
	//Create view
	self.meMapView=[[[MEMapView alloc]init]autorelease];
	//Assign view to view controller
	self.meMapViewController.view = self.meMapView;
	
	//Add the map view as a sub view to our main view and size it.
	[self.view addSubview:self.meMapView];
	[self.view sendSubviewToBack:self.meMapView];
	self.meMapView.frame = self.view.bounds;

	//Initialize the map view controller
	[self.meMapViewController initialize];
	
	//Allow zooming in very close
    self.meMapViewController.meMapView.minimumZoom=0.0003;
	
	//Add a default tile that can be used when waiting on other tile to load
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"grayGrid"]
								   withName:@"grayGrid"
							compressTexture:YES];
	//Set tile bias level
	self.meMapViewController.meMapView.tileLevelBias = 1.0;
	
	//Create simple route planner and initialize it
	self.routePlanner = [[[SimpleRoutePlanner alloc]init]autorelease];
	self.routePlanner.meMapViewController = self.meMapViewController;
}

- (void) turnOnBaseMap
{
	//Determine the physical path of the map file file.
	NSString* databaseFile = [[NSBundle mainBundle] pathForResource:@"world"
															 ofType:@"mbtiles"];
	
	MEMBTilesMapInfo* mapInfo = [[[MEMBTilesMapInfo alloc]init]autorelease];
	mapInfo.name = @"Earth";
	mapInfo.imageDataType = kImageDataTypeJPG;
	mapInfo.mapType = kMapTypeFileMBTiles;
	mapInfo.maxLevel = 6;
	mapInfo.sqliteFileName = databaseFile;
	mapInfo.zOrder = 1;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
}

////////////////////////////////////////////////
//Init GPS
- (void) initializeGPS:(BOOL) enabled
{
	if(enabled)
	{
		if(self.locationManager==nil)
		{
			self.locationManager = [[[CLLocationManager alloc] init] autorelease];
			self.locationManager.delegate = self;
		}
		[self.locationManager startUpdatingLocation];
		[self addOwnShipMarker];

	}
	else
	{
		[self.locationManager stopUpdatingLocation];
		[self removeOwnShipMarker];
	}
}

///////////////////////////////////////////////
//Respond to GPS
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location: %@", [newLocation description]);
	
	[self.meMapView setCenterCoordinate:newLocation.coordinate
					  animationDuration:1.0];
	
	//Update own-ship marker position
	[self updateOwnShipMarkerLocation:newLocation.coordinate
							  heading:newLocation.course
					animationDuration:1.0];
	
	//If in track up mode, then the heading of the marker needs to be updated
	if(self.isTrackupMode)
	{
		[self.meMapViewController.meMapView setCameraOrientation:newLocation.course
															roll:0
														   pitch:0
											   animationDuration:1.0];
	}
	
}

///////////////////////////////////////////////
//Turn track-up mode on or off
- (void) enableTrackupMode:(BOOL) enabled
{
	if(enabled)
	{
		[self.meMapViewController setRenderMode:METrackUp];
		self.meMapView.panEnabled = NO;
	}
	else
	{
		[self.meMapViewController unsetRenderMode:METrackUp];
		self.meMapView.panEnabled = YES;
	}
	
	self.isTrackupMode = enabled;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", [error description]);
}

////////////////////////////////////////////////////////////////////////////
//Add some extremely simple UI right on top of the map.
//Normally you would do this using the interface builder, but our goal here
//is to keep this very simple to illustrate mapping-engine concepts.
- (void) addButtons
{
	//Add GPS button
	self.btnGPS = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.btnGPS setTitle:@"GPS - Off" forState:UIControlStateNormal];
	[self.btnGPS setTitle:@"GPS - On" forState:UIControlStateSelected];
	[self.view addSubview:self.btnGPS];
	[self.view bringSubviewToFront:self.btnGPS];
	self.btnGPS.frame=CGRectMake(0,0,90,30);
	[self.btnGPS addTarget:self
			   action:@selector(gpsButtonTapped)
	 forControlEvents:UIControlEventTouchDown];
	
	
	//Add trackup button
	self.btnTrackUp = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.btnTrackUp setTitle:@"TU - Off" forState:UIControlStateNormal];
	[self.btnTrackUp setTitle:@"TU - On" forState:UIControlStateSelected];
	[self.view addSubview:self.btnTrackUp];
	[self.view bringSubviewToFront:self.btnTrackUp];
	self.btnTrackUp.frame=CGRectMake(self.btnGPS.frame.size.width, 0, 90, 30);
	[self.btnTrackUp addTarget:self
					action:@selector(trackUpButtonTapped)
		  forControlEvents:UIControlEventTouchDown];
	
	//Add street map button
	self.btnStreetMap = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.btnStreetMap setTitle:@"SM - Off" forState:UIControlStateNormal];
	[self.btnStreetMap setTitle:@"SM - On" forState:UIControlStateSelected];
	[self.view addSubview:self.btnStreetMap];
	[self.view bringSubviewToFront:self.btnStreetMap];
	self.btnStreetMap.frame=CGRectMake(self.btnTrackUp.frame.origin.x +
									   self.btnTrackUp.frame.size.width, 0, 90, 30);
	[self.btnStreetMap addTarget:self
						action:@selector(streetMapButtonTapped)
			  forControlEvents:UIControlEventTouchDown];
	
	//Add open aerial
	self.btnOpenAerialMap = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.btnOpenAerialMap setTitle:@"Sat - Off" forState:UIControlStateNormal];
	[self.btnOpenAerialMap setTitle:@"Sat - On" forState:UIControlStateSelected];
	[self.view addSubview:self.btnOpenAerialMap];
	[self.view bringSubviewToFront:self.btnOpenAerialMap];
	self.btnOpenAerialMap.frame=CGRectMake(self.btnStreetMap.frame.origin.x +
									   self.btnStreetMap.frame.size.width, 0, 90, 30);
	[self.btnOpenAerialMap addTarget:self
						  action:@selector(landSatMapButtonTapped)
				forControlEvents:UIControlEventTouchDown];
	
	//Add route planning button
	self.btnRoutePlanning = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.btnRoutePlanning setTitle:@"Route - Off" forState:UIControlStateNormal];
	[self.btnRoutePlanning setTitle:@"Route - On" forState:UIControlStateSelected];
	[self.view addSubview:self.btnRoutePlanning];
	[self.view bringSubviewToFront:self.btnRoutePlanning];
	self.btnRoutePlanning.frame=CGRectMake(self.btnOpenAerialMap.frame.origin.x +
										self.btnOpenAerialMap.frame.size.width, 0, 90, 30);
	[self.btnRoutePlanning addTarget:self
						   action:@selector(routePlanningButtonTapped)
				 forControlEvents:UIControlEventTouchDown];

		
}

- (void) streetMapButtonTapped
{
	self.isStreetMapMode = !self.isStreetMapMode;
	[self enableStreetMap:self.isStreetMapMode];
	self.btnStreetMap.selected = self.isStreetMapMode;
}

- (void) landSatMapButtonTapped
{
	self.isLandSatMapMode = !self.isLandSatMapMode;
	[self enableOpenAerialMap:self.isLandSatMapMode];
	self.btnOpenAerialMap.selected = self.isLandSatMapMode;
}

- (void) gpsButtonTapped
{
	//Toggle GPS
	self.isGPSMode = !self.isGPSMode;
	[self initializeGPS:self.isGPSMode];
	self.btnGPS.selected = self.isGPSMode;
}

- (void) trackUpButtonTapped
{
	//Toggle trackup mode
	self.isTrackupMode = !self.isTrackupMode;
	[self enableTrackupMode:self.isTrackupMode];
	self.btnTrackUp.selected = self.isTrackupMode;
}

- (void) routePlanningButtonTapped
{
	//Toggle route planning mode
	self.isRoutePlanningMode = !self.isRoutePlanningMode;
	self.btnRoutePlanning.selected = self.isRoutePlanningMode;
	[self enableRoutePlanning:self.isRoutePlanningMode];
}

- (void) enableStreetMap:(BOOL) enabled
{
	//Add a virtual map layer using a tile provider that pulls tiles down from the internet
	if(self.streetMap==nil)
	{
		self.streetMap=[[[MEMapBoxLandCoverStreetMap alloc]init]autorelease];
		self.streetMap.compressTextures = YES;
		self.streetMap.meMapViewController = self.meMapViewController;
		self.streetMap.zOrder = 3;
	}
	if(enabled)
		[self.streetMap show];
	else
		[self.streetMap hide];
		
}

- (void) enableOpenAerialMap:(BOOL) enabled
{
	//Add a virtual map layer using a tile provider that pulls tiles down from the internet
	if(self.openAerialMap==nil)
	{
		self.openAerialMap=[[[MEMapQuestOpenAerialMap alloc]init]autorelease];
		self.openAerialMap.compressTextures = NO;
		self.openAerialMap.meMapViewController = self.meMapViewController;
		self.openAerialMap.zOrder = 4;
	}
	if(enabled)
		[self.openAerialMap show];
	else
		[self.openAerialMap hide];
	
}

- (void) enableRoutePlanning:(BOOL) enabled
{
	if(enabled)
	{
		[self.routePlanner enable];
		[self.routePlanner clearRoute];
		
		//Add two points
		[self.routePlanner addWayPoint:RDU_COORD];
		[self.routePlanner addWayPoint:SFO_COORD];
	}
	else
		[self.routePlanner disable];
}
////////////////////////////////////////////////////////////////////////////
//Size map view when device rotates
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	self.meMapView.frame = self.view.bounds;
}

////////////////////////////////////////////////////////////////////////////
//Size map view when view appears (handles landscape startup)
- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.meMapView.frame = self.view.bounds;
}

////////////////////////////////////////////////////////////////////////////
//Initialize things
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	//Add some UI
	[self addButtons];
	
	//Initialize the mapping engine
	[self initializeMappingEngine];
	
	//Turn on the embedded raster map
	[self turnOnBaseMap];
	
}



////////////////////////////////////////////////////////////////////////////
//Create a marker layer which will contain our 'own-ship' marker
- (void) addOwnShipMarker
{
	//Create an array to hold markers (even though we're only adding 1)
	NSMutableArray* markers= [[[NSMutableArray alloc]init]autorelease];
	
	//Create a single marker annotation which describes the marker
	MEMarkerAnnotation* ownShipMarker = [[[MEMarkerAnnotation alloc]init]autorelease];
	ownShipMarker.metaData = @"ownship";
	ownShipMarker.weight=0;
	[markers addObject:ownShipMarker];
	
	//Create a marker map info object which will describe the marker layer
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = @"ownship marker layer";
	mapInfo.mapType = kMapTypeDynamicMarker;
	mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingSynchronous;
	mapInfo.zOrder = 999;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.markers = markers;
	
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

////////////////////////////////////////////////////////////////////////////
//Update the location and heading of the dynamic marker
-(void) updateOwnShipMarkerLocation:(CLLocationCoordinate2D) location
							heading:(double) heading
				  animationDuration:(CGFloat) animationDuration

{
	
	[self.meMapViewController updateMarkerInMap:@"ownship marker layer"
									   metaData:@"ownship"
									newLocation:location
									newRotation:heading
							  animationDuration:animationDuration];
	
	
}

////////////////////////////////////////////////////////////////////////////
//Remove the own-ship marker layer
- (void) removeOwnShipMarker
{
	[self.meMapViewController removeMap:@"ownship marker layer" clearCache:NO];
}

////////////////////////////////////////////////////////////////////////////
//Implement MEMarkerMapDelegate methods
- (void) mapView:(MEMapView*)mapView
updateMarkerInfo:(MEMarkerInfo*) markerInfo
		 mapName:(NSString*) mapName
{
	//Return an image for the ownship marker
	if([markerInfo.metaData isEqualToString:@"ownship"])
	{
		markerInfo.rotationType = kMarkerRotationTrueNorthAligned;
		markerInfo.uiImage = [UIImage imageNamed:@"blueplane"];
		markerInfo.anchorPoint = CGPointMake(markerInfo.uiImage.size.width/2,
											 markerInfo.uiImage.size.height/2);
	}
}

- (void) dealloc {
	
	//Turn off the GPS
	[self.locationManager stopUpdatingLocation];
	self.locationManager = nil;
	
	//Shut down mapping engine
	[self.meMapViewController shutdown];
	self.meMapViewController = nil;
	self.meMapView = nil;
	
	[super dealloc];
}


@end
