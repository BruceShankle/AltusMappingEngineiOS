//
//  ViewController.m
//  MyMap
//
//  Created by Bruce Shankle III on 11/24/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//
// Tutorial 9:
//	* Initialize mapping engine and display an embedded low-res TileMill-generated map of planet Earth.
//	* Drop a marker wherever the user single taps.

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
	self.meMapView.frame = self.view.bounds;
	
	//Initialize the map view controller
	[self.meMapViewController initialize];
	
	//Set map view delegate so the view can notify us
	//of touch events
	self.meMapView.meMapViewDelegate = self;
	
	//Set tile level bias
	self.meMapView.tileLevelBias = 1.0;
	
}

//Handle single taps on the map view
- (void) mapView:(MEMapView *)mapView
	 singleTapAt:(CGPoint) screenPoint
withLocationCoordinate:(CLLocationCoordinate2D) locationCoordinate
{
	NSLog(@"User tapped at lat:%f lon:%f", locationCoordinate.latitude, locationCoordinate.longitude);
	
	//Increment marker id counter
	self.markerCounter++;
	
	//Create a dynamic marker
	MEDynamicMarker* marker = [[[MEDynamicMarker alloc]init]autorelease];
	marker.uiImage = [UIImage imageNamed:@"pinRed"];
	marker.anchorPoint = CGPointMake(7,35);
	marker.location = locationCoordinate;
	marker.name = [NSString stringWithFormat:@"%d", self.markerCounter];
	
	//Add it to the map.
	[self.meMapViewController addDynamicMarkerToMap:@"Red Pin Markers"
									  dynamicMarker:marker];
	
}

- (void) addMarkerLayer
{
	MEDynamicMarkerMapInfo* mapInfo = [[[MEDynamicMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = @"Red Pin Markers";
	mapInfo.zOrder = 5;	
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	//Initialize the mapping engine
	[self initializeMappingEngine];
	
	//Turn on the embedded raster map
	[self turnOnBaseMap];
	
	//Add a marker layer
	[self addMarkerLayer];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
