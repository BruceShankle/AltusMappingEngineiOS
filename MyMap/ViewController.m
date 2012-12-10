//
//  ViewController.m
//  MyMap
//
//  Created by Bruce Shankle III on 11/24/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//
// Tutorial 1: Initialize mapping engine and display an embedded low-res TileMill-generated map of planet Earth.

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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	//Initialize the mapping engine
	[self initializeMappingEngine];
	
	//Turn on the embedded raster map
	[self turnOnBaseMap];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
