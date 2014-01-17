//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MEVectorTileProviderTests.h"
#import "MEVectorTileProvider.h"
#import "../../MapManager/MapManager.h"
#import "../METestCategory.h"
#import "../METestManager.h"

@implementation MEVectorTPSimpleLines

- (id) init {
	if(self=[super init]){
		self.name = @"Simple Lines";
	}
	return self;
}

- (void) start {
	if(self.isRunning)
		return;
	
	//Create tile provider
	self.meVectorTileProvider = [[[MEVectorTileProvider alloc]init]autorelease];
	self.meVectorTileProvider.meMapViewController = self.meMapViewController;
	
	//Create virtual map info
	MEVirtualMapInfo* mapInfo = [[[MEVirtualMapInfo alloc]init]autorelease];
	mapInfo.meMapViewController = self.meMapViewController;
	mapInfo.meTileProvider = self.meVectorTileProvider;
	mapInfo.mapType = kMapTypeVirtualVector;
	mapInfo.zOrder = 10;
	mapInfo.name = self.name;
	
	//Add map
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
		
	//Add styles
	MEPolygonStyle* style=[[[MEPolygonStyle alloc]init]autorelease];
	style.strokeWidth = 1;
	style.strokeColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.5];
	[self.meMapViewController addPolygonStyleToVectorMap:self.name featureId:1 style:style];
	style.strokeColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.1];
	[self.meMapViewController addPolygonStyleToVectorMap:self.name featureId:2 style:style];
	
	self.isRunning = YES;
}

- (void) stop {
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeMap:self.name clearCache:NO];
	self.isRunning = NO;
}
@end


@implementation MEWorldVectorVirtual

- (id) init {
	if(self=[super init]){
		self.name = @"World Vector - Style 1";
        self.styleName = @"Styles";
        self.mapName = @"World_Style2";
	}
	return self;
}

- (BOOL) isEnabled{
    
	NSString* worldMapPath = [MEMapObjectBase mapPathForCategory:@"WorldVector" mapName:self.mapName];
    NSString* worldSqliteFile = [NSString stringWithFormat:@"%@.sqlite", worldMapPath];
    NSString* worldDataFile = [NSString stringWithFormat:@"%@.map", worldMapPath];
	
	NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
	if(![fileManager fileExistsAtPath:worldSqliteFile]){
		return NO;
	}
	if(![fileManager fileExistsAtPath:worldDataFile]){
		return NO;
	}
	return YES;
}

- (void) start {
	if(self.isRunning)
		return;
    
	//Stop all other tests in this category
	[self.meTestCategory stopAllTests];
	
    NSString* worldMapPath = [MEMapObjectBase mapPathForCategory:@"WorldVector" mapName:self.mapName];
    NSString* worldSqliteFile = [NSString stringWithFormat:@"%@.sqlite", worldMapPath];
    NSString* worldDataFile = [NSString stringWithFormat:@"%@.map", worldMapPath];
    
    if (![self.meMapViewController containsMap:self.mapName]); {
        [self.meMapViewController addVectorMap:self.mapName mapSqliteFileName:worldSqliteFile mapDataFileName:worldDataFile];
    }
    [self.meMapViewController setStyleSetOnVectorMap:self.mapName styleFileName:worldSqliteFile styleSetName:self.styleName];
    
	self.isRunning = YES;
	
	//Show copyright notice for vector terrain.
	[self.meTestManager setCopyrightNotice:@"Data courtesy of OpenStreetMap. © OpenStreetMap contributors."];
	
}

- (void) stop {
	if(!self.isRunning)
		return;
	self.isRunning = NO;
}
@end

@implementation MEWorldVectorVirtualStyle2

- (id) init {
	if(self=[super init]){
		self.name = @"World Vector - Style 2";
        self.styleName = @"A_Styles";
	}
	return self;
}

@end

@implementation MEWorldVectorVirtualStyle3

- (id) init {
	if(self=[super init]){
		self.name = @"World Vector - Style 3";
        self.styleName = @"M_Styles";
	}
	return self;
}

- (void) stop {
	if(!self.isRunning)
		return;
	
	//[self.meMapViewController removeMap:self.mapName clearCache:NO];
	self.isRunning = NO;
}

@end

@implementation MEWorldVectorVirtualRemoveMap

- (id) init {
	if(self=[super init]){
		self.name = @"World Vector - Remove Map";
	}
	return self;
}

- (void) start{
}

- (void) stop {
}

- (void) userTapped{
	//Stop all other tests in this category
	[self.meTestCategory stopAllTests];
	[self.meMapViewController removeMap:self.mapName clearCache:NO];
}

@end



