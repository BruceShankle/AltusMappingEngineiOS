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
	
}

//Handle single taps on the map view
- (void) mapView:(MEMapView *)mapView singleTapAt:(CGPoint) screenPoint withLocationCoordinate:(CLLocationCoordinate2D) locationCoordinate
{
	NSLog(@"User tapped at lat:%f lon:%f", locationCoordinate.latitude, locationCoordinate.longitude);
	
	//Add a marker where the user tapped
	self.markerCounter++;
	MEMarkerAnnotation* marker = [[[MEMarkerAnnotation alloc]init]autorelease];
	marker.coordinate = locationCoordinate;
	marker.metaData = [NSString stringWithFormat:@"%d", self.markerCounter];
	
	[self.meMapViewController addMarkerToMap:@"Red Pin Markers"
							markerAnnotation:marker];
}

- (void) addMarkerLayer
{
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name=@"Red Pin Markers";
	mapInfo.mapType = kMapTypeDynamicMarker;
	mapInfo.meMapViewController = self.meMapViewController;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.zOrder = 5;
	mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingSynchronous;
	
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

- (void) mapView:(MEMapView*)mapView
updateMarkerInfo:(MEMarkerInfo*) markerInfo
		 mapName:(NSString*) mapName
{
	//Set marker image and anchor point
	markerInfo.uiImage = [UIImage imageNamed:@"pinRed"];
	markerInfo.anchorPoint = CGPointMake(7,35);
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
