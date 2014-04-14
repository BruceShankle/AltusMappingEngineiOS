//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MELocalTerrainMaps.h"
#import "../METestCategory.h"

@implementation LocalTerrainMapTestsCategory

-(id) init
{
	if(self=[super init])
	{
		self.name = @"Terrain Tests";
		self.mapManager = [[[MapManager alloc]init]autorelease];
		
		MEMapCategory* mapCategory;
		
		//Add tests for base earth maps
		mapCategory = [self.mapManager categoryWithName:@"BaseMaps"];
		if(mapCategory!=nil)
			[self createTests:mapCategory];
		
		//Add tests for high-res terrain
		mapCategory = [self.mapManager categoryWithName:@"Terrain_Subsets"];
		if(mapCategory!=nil)
			[self createTests:mapCategory];
		
	}
	
	return self;
}

- (void) setMeMapViewController:(MEMapViewController *)meMapViewController
{
	[super setMeMapViewController:meMapViewController];
	for(METest* test in self.meTests)
		test.meMapViewController = meMapViewController;
}

- (void) setMeTestManager:(METestManager *)meTestManager
{
	[super setMeTestManager:meTestManager];
	for(METest* test in self.meTests)
		test.meTestManager = meTestManager;

}
- (void) createTests:(MEMapCategory*) mapCategory
{
	for(MEMap* map in mapCategory.Maps)
	{
		METest* test;
		
		test = [[[METerrainTest alloc]initWithMap:map
										compressTextures:NO]autorelease];
		test.meTestCategory = self;
		[self.meTests addObject:test];
		
		
		test = [[[METerrainTest alloc]initWithMap:map
										compressTextures:YES]autorelease];
		test.meTestCategory = self;
		[self.meTests addObject:test];
		
	}
}

-(void) dealloc
{
	self.mapManager = nil;
	[super dealloc];
}

@end

//////////////////////////////////////////////////////////////////////////////
@implementation METerrainTest

-(id) initWithMap:(MEMap*) map compressTextures:(BOOL) compressTextures
{
	if(self=[super init])
	{
		_compressTextures = compressTextures;
		_map=map;
		if(compressTextures)
			self.name=[NSString stringWithFormat:@"%@ 2 Byte",map.Name];
		else
			self.name=[NSString stringWithFormat:@"%@ 4 Byte",map.Name];
	}
	return self;
}

-(void) dealloc
{
	[_map release];
	[super dealloc];
}

-(void) addMap
{
	MEMapInfo* mapInfo=[[[MEMapInfo alloc]init]autorelease];
	mapInfo.name= self.name;
	mapInfo.sqliteFileName = self.map.MapIndexFileName;
	mapInfo.dataFileName = self.map.MapFileName;
	mapInfo.compressTextures = self.compressTextures;
	mapInfo.zOrder = 4;
	mapInfo.mapType = kMapTypeFileTerrain;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

-(void) removeMap
{
	[self.meMapViewController removeMap:self.name clearCache:NO];
}

- (void) start
{
	if(self.isRunning)
		return;
	//[self.meTestCategory stopAllTests];
	
	[self addMap];
	
	self.isRunning = YES;
}

- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self removeMap];
	
	self.isRunning = NO;
}

@end
