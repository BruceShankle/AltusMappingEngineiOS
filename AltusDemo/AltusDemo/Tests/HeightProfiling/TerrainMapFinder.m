//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "TerrainMapFinder.h"
#import <AltusMappingengine/AltusMappingEngine.h>
@implementation TerrainMapFinder

+ (NSMutableArray*) getTerrainMaps{
	NSMutableArray* terrainMaps = [[NSMutableArray alloc]init];
	MEMapInfo* mapInfo = [[MEMapInfo alloc]init];
    mapInfo.name =@"Earth";
    mapInfo.sqliteFileName = [[NSBundle mainBundle] pathForResource:@"Earth"
															 ofType:@"sqlite"];
    
    mapInfo.dataFileName = [[NSBundle mainBundle] pathForResource:@"Earth"
                                                           ofType:@"map"];
    [terrainMaps addObject:mapInfo];
	return terrainMaps;
}

@end
