//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "TerrainMapFinder.h"
#import "../../MapManager/MEMap.h"
#import "../../MapManager/MEMapCategory.h"
#import "../../MapManager/MapManager.h"
#import <ME/ME.h>
@implementation TerrainMapFinder

+ (void) addTerrainMaps:(MEMapCategory*) mapCategory terrainMaps:(NSMutableArray*) terrainMaps{
	for(MEMap* map in mapCategory.Maps){
		MEMapFileInfo* mapFileInfo = [[[MEMapFileInfo alloc]init]autorelease];
		mapFileInfo.sqliteFileName = map.MapIndexFileName;
		mapFileInfo.dataFileName = map.MapFileName;
		[terrainMaps addObject:mapFileInfo];
	}
}

+ (NSMutableArray*) getTerrainMaps{
	NSMutableArray* terrainMaps = [[[NSMutableArray alloc]init]autorelease];
	MapManager* mapManager = [[[MapManager alloc]init]autorelease];
	[TerrainMapFinder addTerrainMaps:[mapManager categoryWithName:@"BaseMaps"]
						 terrainMaps:terrainMaps];
	[TerrainMapFinder addTerrainMaps:[mapManager categoryWithName:@"Terrain_Subsets"]
						 terrainMaps:terrainMaps];
	return terrainMaps;
}

@end
