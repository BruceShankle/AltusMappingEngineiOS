//
//  ViewController.m
//  MyMap
//
//  Created by Bruce Shankle III on 11/24/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//
// Tutorial 3:
//	* Initialize mapping engine and display an embedded low-res TileMill-generated map of planet Earth.
//	* Turn on GPS and update map to center on current GPS coordinate.
//	* Add and enable track-up mode so map rotates based on GPS course.

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
- (void) initializeGPS
{
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	self.locationManager.delegate = self;
	[self.locationManager startUpdatingLocation];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	//Initialize the mapping engine
	[self initializeMappingEngine];
	
	//Turn on the embedded raster map
	[self turnOnBaseMap];
	
	//Turn on the GPS
	[self initializeGPS];
	
	//Turn on trackup mode
	[self enableTrackupMode:YES];
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
