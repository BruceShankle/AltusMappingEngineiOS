//
//  MapLayerListViewController.m
//  Mapp
//
//  Created by Edwin B Shankle III on 10/4/11.
//  Copyright 2011 BA3, LLC. All rights reserved.
//

#import "MapSelectorTableViewController.h"
#import "Libraries/JSONKit/JSONKit.h"
#import "TileProviders/MapStreamingTileProvider.h"
#import "MapViewController.h"
#import "METests/METest.h"
#import "MapManager/MapManager.h"
#import "METests/TerrainProfileTests/TerrainMapFinder.h"

@implementation MapSelectorTableViewController
@synthesize meViewController;
@synthesize remoteMapCatalog;
@synthesize mapViewController;
@synthesize meTestManager;
@synthesize mapManager;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
	self.remoteMapCatalog = [[RemoteMapCatalog alloc] init];
	
    return self;
}

-(void) dealloc
{
	meViewController = nil;
	self.remoteMapCatalog = nil;
	self.mapViewController = nil;
    self.meTestManager = nil;
	self.mapManager = nil;
	[super dealloc];
}

#pragma mark - View lifecycle


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	int totalCount;
	totalCount = self.mapManager.mapCategories.count;
	//totalCount++; //For streamed maps
	totalCount++; //For 3D terrain maps
	return totalCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSArray* categories=self.mapManager.mapCategories;
	if(section<=categories.count-1){
		MEMapCategory* category=[categories objectAtIndex:section];
		return category.Name;
	}
	return @"3D Terrain";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray* categories=self.mapManager.mapCategories;
	
	if(section<=categories.count-1){
		MEMapCategory* category=[categories objectAtIndex:section];
		return [category.Maps count];
	}
	
	//3D terrain category
	//Get number of terrain maps.
	NSMutableArray* terrainMaps = [TerrainMapFinder getTerrainMaps];
	return terrainMaps.count;
}

-(NSString*) get3DName:(NSString*) name{
	return [NSString stringWithFormat:@"%@_3D", name];
}

- (MEMapInfo*) getTerrain3DMapInfo:(int) index{
	NSMutableArray* terrainMaps = [TerrainMapFinder getTerrainMaps];
	MEMapInfo* mapInfo = [terrainMaps objectAtIndex:index];
	mapInfo.name = [self get3DName:mapInfo.name];
	return mapInfo;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	//Create a cell.
    UITableViewCell* cell;
	cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"]autorelease];
    
	NSString* cellName;
	
	//Get the category
	NSArray* categories=self.mapManager.mapCategories;
	
	if(indexPath.section<=categories.count-1)
	{
		MEMapCategory* category=[categories objectAtIndex:indexPath.section];
		
		//Get the map
		MEMap* map=[category.Maps objectAtIndex:indexPath.row];
		
		cellName=[NSString stringWithFormat:@"%@", map.Name];
		
		if([self.meViewController containsMap:map.Path])
		{
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		}
		
	}
	else
	{
		MEMapInfo* mapInfo = [self getTerrain3DMapInfo:indexPath.row];
		cellName = mapInfo.name;
		
		//Turn check on or off depending on whether or not map is on
		if([self.meViewController containsMap:mapInfo.name])
		{
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		}
		
	}
	
	[[cell textLabel] setText:cellName];
	
	
    return cell;
}


#pragma mark - Table view delegate
- (BOOL) toggleTerrain3DMap:(int) index{
	
	MEMapInfo* mapInfo = [self getTerrain3DMapInfo:index];
	
	BOOL isOn = [self.meViewController containsMap:mapInfo.name];
	
	if(!isOn){
		//Add map
		METerrain3DMapInfo* mapInfo3D = [[[METerrain3DMapInfo alloc]init]autorelease];
		mapInfo3D.name = mapInfo.name;
		mapInfo3D.sqliteFileName = mapInfo.sqliteFileName;
		mapInfo3D.dataFileName = mapInfo.dataFileName;
		[self.meViewController addMapUsingMapInfo:mapInfo3D];
		isOn = YES;
	}
	else
	{
		//Remove map
		[self.meViewController removeMap:mapInfo.name clearCache:NO];
		isOn = NO;
	}
	return isOn;
}


- (void) applyDefaultWorldVectorStyle:(BOOL) enable
{
	//Get label catetory and turn off all tests.
	METestCategory* testCategory = [self.meTestManager categoryFromName:@"Labeling"];
	if(!enable){
		//Disable all styling tests and exit
		[testCategory stopAllTests];
		return;
	}
	
	//Turn on the last labelStyle style, or default to plain style
	METest* labelStyle = testCategory.lastTestStarted;
	if(labelStyle==nil){
		labelStyle = [testCategory testWithName:@"Places - Plain Style"];
	}
    [labelStyle start];    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	NSArray* categories=self.mapManager.mapCategories;
	
	BOOL isOn;
	UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
	
	if(indexPath.section<=categories.count-1)
	{
		//Get the category
		MEMapCategory* category=[categories objectAtIndex:indexPath.section];
		//Get the map
		MEMap* map=[category.Maps objectAtIndex:indexPath.row];
		
		isOn = [self.meViewController containsMap:map.Path];
		
        NSString* earthMapPath = [MEMapObjectBase mapPathForCategory:@"BaseMaps" mapName:@"Earth"];
		NSString* earthSqliteFile = [NSString stringWithFormat:@"%@.sqlite",
									 earthMapPath];
		NSString* earthDataFile = [NSString stringWithFormat:@"%@.map",
									 earthMapPath];
        BOOL isWorldVectorMap = NO;
        NSRange range = [map.Path rangeOfString:@"WorldVector" options:NSCaseInsensitiveSearch];
        if(range.location != NSNotFound)
            isWorldVectorMap = YES;
		
		BOOL isTerrainSubset = NO;
		range = [map.Path rangeOfString:@"Terrain_Subsets" options:NSCaseInsensitiveSearch];
        if(range.location != NSNotFound)
            isTerrainSubset = YES;
        
		//Toggle map
		if(!isOn)
		{
			#ifdef TESTFLIGHT
			[TestFlight passCheckpoint:[NSString stringWithFormat:@"Enabled map: %@",map.Path]];
			#endif
            
			//Turn map on
			if(isTerrainSubset)
			{
				MEMapInfo* mapInfo = [[[MEMapInfo alloc]init]autorelease];
				mapInfo.name = map.Path;
				mapInfo.sqliteFileName = map.MapIndexFileName;
				mapInfo.dataFileName = map.MapFileName;
				mapInfo.mapType = kMapTypeFileTerrain;
				mapInfo.borderPixelCount = 1;
				mapInfo.zOrder = 2;
				[self.meViewController addMapUsingMapInfo:mapInfo];
			}
			else if(!isWorldVectorMap)
			{
            [self.meViewController addMap:map.Path
						mapSqliteFileName:map.MapIndexFileName
						  mapDataFileName:map.MapFileName
						 compressTextures:NO];
			}
			
            //If it's a world vector map turn off the earth map and apply the default style
            if(isWorldVectorMap)
            {
				MEVectorMapInfo* mapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
				mapInfo.mapType = kMapTypeFileVector;
				mapInfo.name = map.Path;
				mapInfo.sqliteFileName = map.MapIndexFileName;
				mapInfo.dataFileName = map.MapFileName;
				mapInfo.zOrder = 3;
				[self.meViewController addMapUsingMapInfo:mapInfo];
				
                [self.meViewController removeMap:earthMapPath clearCache:NO];
				
				//Turn on world vector styling.
                [self applyDefaultWorldVectorStyle:YES];
				
				//Show copyright notice for vector terrain.
				[self.meTestManager setCopyrightNotice:@"Data courtesy of OpenStreetMap. © OpenStreetMap contributors. Political names courtesy of geonames.org."];
            }
			
			isOn=YES;
		}
		else
		{
			#ifdef TESTFLIGHT
			[TestFlight passCheckpoint:[NSString stringWithFormat:@"Disabled map: %@",map.Path]];
			#endif
            
            if(isWorldVectorMap)
            {
                //Clear the cache with vector maps because we want be notifed when
                //they are loaded so we can style them in MapViewController.mm
                [self.meViewController removeMap:map.Path clearCache:NO];
                
                //Turn off world vector style
                [self applyDefaultWorldVectorStyle:NO];
                
                //Turn earth base map back on
				[self.meViewController addMap:earthMapPath
							mapSqliteFileName:earthSqliteFile
							  mapDataFileName:earthDataFile
							 compressTextures:NO];

                
				[self.meTestManager setCopyrightNotice:@""];
            }
            else
            {
                [self.meViewController removeMap:map.Path clearCache:NO];
            }
            
			isOn=NO;
		}
			
	}
	else
	{
		//Turn streamable map on or off
		isOn = [self toggleTerrain3DMap:indexPath.row];
	}
	
	//Check or uncheck cell
	if(isOn)
	{
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
	}
	else
	{
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
}

@end
