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
	return totalCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSArray* categories=self.mapManager.mapCategories;
	if(section<=categories.count-1)
	{
		MEMapCategory* category=[categories objectAtIndex:section];
		return category.Name;
	}
	return @"Streamed Maps";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray* categories=self.mapManager.mapCategories;
	
	if(section<=categories.count-1)
	{
		MEMapCategory* category=[categories objectAtIndex:section];
		return [category.Maps count];
	}
	
	//Must be stream category
	return self.remoteMapCatalog.mapCount;
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
		//Get name from json array
		cellName = [self.remoteMapCatalog mapName:indexPath.row];
		NSString* mapDomain = [self.remoteMapCatalog mapDomain:indexPath.row];
		
		//Turn check on or off
		if([self.meViewController containsMap:mapDomain])
		{
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		}
		
	}
	
	[[cell textLabel] setText:cellName];
	
	
    return cell;
}


#pragma mark - Table view delegate
- (BOOL) toggleStreamableMap:(int) index
{
	NSString* mapDomain = [self.remoteMapCatalog mapDomain:index];
	
	BOOL isOn = [self.meViewController containsMap:mapDomain];
	
	if(!isOn)
	{
		//Create a BA3 style streaming tile provider
		MapStreamingTileProvider* tileProvider;
		tileProvider = [[MapStreamingTileProvider alloc] init];
		tileProvider.mapDomain = mapDomain;
		tileProvider.meMapViewController = self.meViewController;
		
		RemoteMapInfo mapInfo = [self.remoteMapCatalog mapInfo:index];
		
		//Set up the the virtual map info
		MEVirtualMapInfo* vMapInfo = [[[MEVirtualMapInfo alloc]init]autorelease];
		vMapInfo.name = mapDomain;
		vMapInfo.meTileProvider = tileProvider;
		vMapInfo.maxLevel = mapInfo.maxLevel;
		vMapInfo.minX = mapInfo.minX;
		vMapInfo.minY = mapInfo.minY;
		vMapInfo.maxX = mapInfo.maxX;
		vMapInfo.maxY = mapInfo.maxY;
		vMapInfo.borderPixelCount = mapInfo.borderSize;
		vMapInfo.isSlippyMap = NO;
		tileProvider.isAsynchronous = YES;
		if(self.mapViewController.loadLowestDetailFirst)
			vMapInfo.loadingStrategy = kLowestDetailFirst;
		else
			vMapInfo.loadingStrategy = kHighestDetailOnly;
		vMapInfo.contentType = kZoomIndependent;
		
		//Add the virtual map
		[self.meViewController addMapUsingMapInfo:vMapInfo];
		
		
		isOn = YES;
		
	}
	else
	{
		//Turn virtual map off.
		[self.meViewController removeMap:mapDomain clearCache:NO];
		isOn = NO;
	}
	return isOn;
}


- (void) applyDefaultWorldVectorStyle:(BOOL) enable
{
   
	METestCategory* testCategory = [self.meTestManager categoryFromName:@"World Vector"];
	if(!enable)
	{
		//Disable all styling tests and exit
		[testCategory stopAllTests];
		return;
	}
	
	//Turn on the last vector style, or default to MapBox
	METest* vectorStyle = testCategory.lastTestStarted;
	if(vectorStyle==nil)
	{
		vectorStyle = [testCategory testWithName:@"MapBox Style"];
	}
    [vectorStyle start];    
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

                
				[self.meTestManager setCopyrightNotice:@"Terrain and water data courtesy of NASA SRTM."];
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
		isOn = [self toggleStreamableMap:indexPath.row];
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
