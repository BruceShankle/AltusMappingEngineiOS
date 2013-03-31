//
//  ViewController.m
//  MyMap
//
//  Created by Bruce Shankle III on 11/24/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//
// Tutorial 7:
//	* Initialize mapping engine and display an embedded low-res TileMill-generated map of planet Earth.
//	* Turn on GPS and update map to center on current GPS coordinate.
//	* Add and enable track-up mode so map rotates based on GPS course.
//	* Add buttons to toggle GPS and track-up mode.
//	* Handle device rotations and starting up in landscape mode.
//	* Add support for an own-ship marker that updates based on current location and course.
//	* Add tile provider and virtual map that downloads MapBox street map.
//	* Add tile provider and UI support for MapBox landsat data
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void) initializeMappingEngine
{
	//Create view controller
	self.meMapViewController=[[[MEMapViewController alloc]init]autorelease];
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
	
	//Set tile bias level
	self.meMapViewController.meMapView.tileLevelBias = 1.0;
	
	//Add gray grid tile as pre-cached image
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"grayGrid"]
									withName:@"grayGrid"
							 compressTexture:YES];
}

- (void) turnOnBaseMap
{
	MEVirtualMapInfo* baseMap = [[[MEVirtualMapInfo alloc]init]autorelease];
	baseMap.name=@"graygrid";
	baseMap.zOrder = 1;
	baseMap.maxLevel = 12;
	baseMap.isSphericalMercator = NO;
	baseMap.meTileProvider = [[[MEBaseMapTileProvider alloc]initWithCachedImageName:@"grayGrid"]autorelease];
	[self.meMapViewController addMapUsingMapInfo:baseMap];
	
	//Determine the physical path of the map file file.
	NSString* databaseFile = [[NSBundle mainBundle] pathForResource:@"world"
															 ofType:@"mbtiles"];
	
	MEMBTilesMapInfo* mapInfo = [[[MEMBTilesMapInfo alloc]init]autorelease];
	mapInfo.name = @"Earth";
	mapInfo.imageDataType = kImageDataTypeJPG;
	mapInfo.mapType = kMapTypeFileMBTiles;
	mapInfo.maxLevel = 6;
	mapInfo.sqliteFileName = databaseFile;
	mapInfo.zOrder = 2;
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
	
	//Add landsat map button
	self.btnAerialMap = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.btnAerialMap setTitle:@"AM - Off" forState:UIControlStateNormal];
	[self.btnAerialMap setTitle:@"AM - On" forState:UIControlStateSelected];
	[self.view addSubview:self.btnAerialMap];
	[self.view bringSubviewToFront:self.btnAerialMap];
	self.btnAerialMap.frame=CGRectMake(self.btnStreetMap.frame.origin.x +
									   self.btnStreetMap.frame.size.width, 0, 90, 30);
	[self.btnAerialMap addTarget:self
						  action:@selector(aerialMapButtonTapped)
				forControlEvents:UIControlEventTouchDown];
		
}

- (void) streetMapButtonTapped
{
	self.isStreetMapMode = !self.isStreetMapMode;
	[self enableStreetMap:self.isStreetMapMode];
	self.btnStreetMap.selected = self.isStreetMapMode;
}

- (void) aerialMapButtonTapped
{
	self.isAerialMapMode = !self.isAerialMapMode;
	[self enableLandSatMap:self.isAerialMapMode];
	self.btnAerialMap.selected = self.isAerialMapMode;
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

- (void) enableLandSatMap:(BOOL) enabled
{
	//Add a virtual map layer using a tile provider that pulls tiles down from the internet
	if(self.aerialMap==nil)
	{
		self.aerialMap=[[[MEMapQuestAerialMap alloc]init]autorelease];
		self.aerialMap.meMapViewController = self.meMapViewController;
		self.aerialMap.zOrder = 4;
	}
	if(enabled)
		[self.aerialMap show];
	else
		[self.aerialMap hide];
	
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
