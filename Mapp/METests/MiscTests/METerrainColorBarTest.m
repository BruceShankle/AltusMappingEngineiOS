//
//  METerrainColorBarTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 9/20/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "METerrainColorBarTest.h"
#import "../../MapManager/MEMapObjectBase.h"

@implementation METerrainColorBarTest
@synthesize earthMapName;
@synthesize defaultColorBar;

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Terrain ColorBar";
        self.earthMapName = [MEMapObjectBase mapPathForCategory:@"BaseMaps" mapName:@"Earth"];
        [self createColorBars];
    }
    return self;
}

- (void) createColorBars
{
    //Alternate color bar 1
	self.altColorBar1=[[[METerrainColorBar alloc]init]autorelease];
	
	[self.altColorBar1.heightColors addObject:
	 [[MEHeightColor alloc]initWithHeight:-200 color:
	  [UIColor blackColor]]];
	
	[self.altColorBar1.heightColors addObject:
	 [[MEHeightColor alloc]initWithHeight:0 color:
	  [UIColor darkGrayColor]]];
	
	[self.altColorBar1.heightColors addObject:
	 [[MEHeightColor alloc]initWithHeight:200 color:
	  [UIColor lightGrayColor]]];
	
	[self.altColorBar1.heightColors addObject:
	 [[MEHeightColor alloc]initWithHeight:400 color:
	  [UIColor whiteColor]]];
	
	[self.altColorBar1.heightColors addObject:
	 [[MEHeightColor alloc]initWithHeight:1000 color:
	  [UIColor redColor]]];
	
	[self.altColorBar1.heightColors addObject:
	 [[MEHeightColor alloc]initWithHeight:1500 color:
	  [UIColor greenColor]]];
	
	[self.altColorBar1.heightColors addObject:
	 [[MEHeightColor alloc]initWithHeight:2500 color:
	  [UIColor blueColor]]];
	
	[self.altColorBar1.heightColors addObject:
	 [[MEHeightColor alloc]initWithHeight:4000 color:
	  [UIColor yellowColor]]];
	
	[self.altColorBar1.heightColors addObject:
	 [[MEHeightColor alloc]initWithHeight:6000 color:
	  [UIColor purpleColor]]];
	
	[self.altColorBar1.heightColors addObject:
	 [[MEHeightColor alloc]initWithHeight:10000 color:
	  [UIColor whiteColor]]];
    
    self.altColorBar1.waterColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:1];
    
}

- (void) dealloc
{
    self.earthMapName = nil;
    self.defaultColorBar = nil;
    self.altColorBar1 = nil;
    [super dealloc];
}

- (BOOL) isEnabled
{
    return [self.meMapViewController containsMap:self.earthMapName];
}


- (void) reloadEarth
{
    [self.meMapViewController removeMap:self.earthMapName clearCache:YES];
	NSString* earthSqliteFile = [self.earthMapName stringByAppendingString:@".sqlite"];
	NSString* earthDataFile = [self.earthMapName stringByAppendingString:@".map"];
	MEMapInfo* mapInfo = [[[MEMapInfo alloc]init]autorelease];
	mapInfo.name=self.earthMapName;
	mapInfo.mapType = kMapTypeFileTerrain;
	mapInfo.sqliteFileName = earthSqliteFile;
	mapInfo.dataFileName = earthDataFile;
	mapInfo.zOrder = 1;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
}

- (void) start
{
    //Save current color bar
    self.defaultColorBar = [self.meMapViewController terrainColorBar];
    
    //Set new color bar
    [self.meMapViewController updateTerrainColorBar:self.altColorBar1];
    
    //Reload earth
    [self reloadEarth];
    
    self.isRunning = YES;
}

- (void) stop
{
    //Set color bar back to default colors
    [self.meMapViewController updateTerrainColorBar:self.defaultColorBar];

    //Reload earth
    [self reloadEarth];

    self.isRunning = NO;
}

@end
