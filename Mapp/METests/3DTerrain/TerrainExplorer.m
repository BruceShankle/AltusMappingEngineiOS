//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "TerrainExplorer.h"
#import "../TerrainProfileTests/TerrainMapFinder.h"

@implementation MapExplorer

- (id) init{
	if(self = [super init]){
		self.name = @"Map Explorer";
	}
	return self;
}

- (void) start{
	if(self.isRunning){
		return;
	}
	
	self.isRunning = YES;
	
	//Construct and add UI
	self.terrainExplorerUI = [[[TerrainExplorerUI alloc]initWithNibName:@"TerrainExplorerUI" bundle:nil]autorelease];
	self.terrainExplorerUI.meMapViewController = self.meMapViewController;
	self.terrainExplorerUI.view.frame = CGRectMake(0,0,250,325);
	[self.meMapViewController.meMapView addSubview:self.terrainExplorerUI.view];
	
	//Tell the UI about all the terrain maps on the device.
	self.terrainExplorerUI.terrainMaps = [TerrainMapFinder getTerrainMaps];
	
	//Store old delegate
	self.oldDelegate = self.meMapViewController.meMapView.meMapViewDelegate;
	
	//Set UI delegate
	self.meMapViewController.meMapView.meMapViewDelegate = self.terrainExplorerUI;
	
	[self.terrainExplorerUI start];
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
	[self.terrainExplorerUI stop];
	self.meMapViewController.meMapView.meMapViewDelegate = self.oldDelegate;
	
	//remove ui
	[self.terrainExplorerUI.view removeFromSuperview];
	
	//destroy
	self.terrainExplorerUI=nil;
	
	self.oldDelegate = nil;
	self.isRunning = NO;
}

@end
