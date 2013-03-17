//
//  MapLoading.m
//  Mapp
//
//  Created by Bruce Shankle III on 10/18/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MapLoading.h"
#import "../METestCategory.h"
#import "../METestManager.h"
#import "../../MapManager/MapManager.h"
#import "../../MapManager/MEMap.h"

@implementation LoadSingleMap_Sectional

@synthesize oldDelegate;
@synthesize mapCategory;
@synthesize currentMapIndex;
@synthesize loadingComplete;

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Load Single Map";
		self.categoryName = @"Sectional";
		self.categoryName=@"Sectional";
	}
	return self;
}

- (NSString*) label
{
	return self.categoryName;
}

- (BOOL) isEnabled
{
	[self loadCategory];
	return self.mapCategory.Maps.count!=0;
}

- (void) dealloc
{
	self.mapCategory = nil;
	self.categoryName = nil;
	[super dealloc];
}

- (void) loadCategory
{
	if(self.mapCategory!=nil)
		return;
	NSString* categoryPath = [MEMapObjectBase GetCategoryPath:self.categoryName];
	self.mapCategory = [[[MEMapCategory alloc]initWithName:self.categoryName andPath:categoryPath]autorelease];
}

- (void) start
{
	if(!self.isEnabled)
		return;
	
	[self loadCategory];
	self.currentMapIndex = 0;
	self.loadingComplete = NO;
	
	[self.meMapViewController removeAllMaps:YES];
	self.oldDelegate = self.meMapViewController.meMapView.meMapViewDelegate;
	self.meMapViewController.meMapView.meMapViewDelegate = self;
	self.interval = 0.25;
	[super start];
	[self loadMap:self.currentMapIndex];
}

- (void) loadMap:(unsigned int) index
{
	self.loadingComplete = NO;
	MEMap* map = [self.mapCategory.Maps objectAtIndex:index];
	if(map!=nil)
	{
		MEMapInfo* mapInfo = [[[MEMapInfo alloc]init]autorelease];
		mapInfo.name = map.Path;
		mapInfo.mapType = kMapTypeFileRaster;
		mapInfo.sqliteFileName = map.MapIndexFileName;
		mapInfo.dataFileName = map.MapFileName;
		mapInfo.zOrder = 2;
		[self.meMapViewController addMapUsingMapInfo:mapInfo];
	}
}

- (void) unloadMap:(unsigned int) index
{
	MEMap* map = [self.mapCategory.Maps objectAtIndex:index];
	if(map!=nil)
		[self.meMapViewController removeMap:map.Path clearCache:YES];
}

- (void) timerTick
{
	if(!self.loadingComplete)
		return;
	[self unloadMap:self.currentMapIndex];
	self.currentMapIndex++;
	if(self.currentMapIndex==self.mapCategory.Maps.count)
		self.currentMapIndex = 0;
	[self loadMap:self.currentMapIndex];
}

- (void) stop
{
	self.meMapViewController.meMapView.meMapViewDelegate = self.oldDelegate;
	self.oldDelegate = nil;
	[super stop];
}

- (void) mapView:(MEMapView *)mapView willStartLoadingMap:(NSString*) mapName
{
	
}

- (void) mapView:(MEMapView *)mapView didFinishLoadingMap:(NSString*) mapName
{
	@synchronized(self)
	{
		self.loadingComplete = YES;
	}
}

- (void) mapView:(MEMapView *)mapView singleTapAt:(CGPoint)screenPoint withLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate
{
}

@end

////////////////////////////////////////////////////////////////////////////////////////////
@implementation LoadAllMaps_Sectional
@synthesize willStartLoadingCount;
@synthesize didFinishLoadingCount;

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Load All Maps";
	}
	return self;
}

- (void) loadAllMaps
{
	self.willStartLoadingCount = 0;
	self.didFinishLoadingCount = 0;
	for(MEMap* map in self.mapCategory.Maps)
	{
		NSLog(@"Loading %@", map.Path);
		MEMapInfo* mapInfo = [[[MEMapInfo alloc]init]autorelease];
		mapInfo.name = map.Path;
		mapInfo.mapType = kMapTypeFileRaster;
		mapInfo.sqliteFileName = map.MapIndexFileName;
		mapInfo.dataFileName = map.MapFileName;
		mapInfo.zOrder = 2;
		[self.meMapViewController addMapUsingMapInfo:mapInfo];

	}
}

- (void) unloadAllMaps
{
	NSLog(@"Unload all maps");
	[self.meMapViewController removeAllMaps:YES];
}

- (void) start
{
	if(!self.isEnabled)
		return;
	
	[self loadCategory];
	self.currentMapIndex = 0;
	self.loadingComplete = NO;
	
	self.interval = 0.5;
	[self.meMapViewController removeAllMaps:YES];
	self.oldDelegate = self.meMapViewController.meMapView.meMapViewDelegate;
	self.meMapViewController.meMapView.meMapViewDelegate = self;
	[self loadAllMaps];
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    self.isRunning = YES;
	self.meTestCategory.lastTestStarted = self;
	[self.meTestManager testUpdated:self];
	
}

- (void) timerTick
{
	@synchronized(self)
	{
		if(self.willStartLoadingCount == self.didFinishLoadingCount)
		{
			[self unloadAllMaps];
			[self loadAllMaps];
		}
		else
		{
			NSLog(@"%d vs. %d", self.willStartLoadingCount, self.didFinishLoadingCount);
		}
	}
}

- (void) stop
{
	[self unloadAllMaps];
	self.meMapViewController.meMapView.meMapViewDelegate = self.oldDelegate;
	self.oldDelegate = nil;
	[super stop];
}

- (void) mapView:(MEMapView *)mapView willStartLoadingMap:(NSString*) mapName
{
	@synchronized(self)
	{
		//NSLog(@"*** start loading %@", mapName);
		self.willStartLoadingCount++;
	}
}

- (void) mapView:(MEMapView *)mapView didFinishLoadingMap:(NSString*) mapName
{
	@synchronized(self)
	{
		
		//NSLog(@"*** finish loading %@", mapName);
		self.didFinishLoadingCount++;
	}
}

@end

////////////////////////////////////////////////////////////////////////////////////////////
@implementation LoadAllMaps_IFRLow

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Load All Maps";
		self.categoryName = @"IFRLow.me";
	}
	return self;
}

- (void) loadAllMaps
{
	self.willStartLoadingCount = 0;
	self.didFinishLoadingCount = 0;
	for(MEMap* map in self.mapCategory.Maps)
	{
		if([map.Path rangeOfString:@"collar"].length > 0)
		{
			NSLog(@"Skipping collar %@", map.Path);
		}
		else
		{
			NSLog(@"Loading %@", map.Path);
			MEMapInfo* mapInfo = [[[MEMapInfo alloc]init]autorelease];
			mapInfo.name = map.Path;
			mapInfo.mapType = kMapTypeFileRaster;
			mapInfo.sqliteFileName = map.MapIndexFileName;
			mapInfo.dataFileName = map.MapFileName;
			mapInfo.zOrder = 2;
			[self.meMapViewController addMapUsingMapInfo:mapInfo];
			
		}
	}
}


- (void) timerTick
{
	@synchronized(self)
	{
		if(self.willStartLoadingCount == self.didFinishLoadingCount)
		{
			//[self unloadAllMaps];
			//[self loadAllMaps];
		}
	}
}


@end

////////////////////////////////////////////////////////////////////////////////////////////
@implementation LoadAllMaps_IFRLowPVR

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Load All Maps";
		self.categoryName = @"IFRLow.me.pvr";
	}
	return self;
}

@end

