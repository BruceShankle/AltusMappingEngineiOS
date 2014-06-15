//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "DynamicColorBar.h"

@implementation DynamicColorBar

-(id) init{
    if(self=[super init]){
        self.name = @"Dynamic colors";
    }
    return self;
}

- (void) beginTest{
    self.isRunning = NO;
    [self.meTestCategory stopAllTests];
    self.isRunning = YES;
    
    NSString* sqliteFile = [[NSBundle mainBundle] pathForResource:@"Earth"
                                                           ofType:@"sqlite"];
    
    NSString* mapFile = [[NSBundle mainBundle] pathForResource:@"Earth"
                                                        ofType:@"map"];
    
    MEMapInfo* mapInfo = [[MEMapInfo alloc]init];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeFileTerrainTAWS;
	mapInfo.sqliteFileName = sqliteFile;
	mapInfo.dataFileName = mapFile;
	mapInfo.zOrder = 5;

	[self.meMapViewController addMapUsingMapInfo:mapInfo];
//    [self.meMapViewController addMap:self.name
//                   mapSqliteFileName:sqliteFile
//                     mapDataFileName:mapFile
//                    compressTextures:NO];
    
    [self.meMapViewController setMapZOrder:self.name zOrder:1];
    
    [self.meMapViewController updateTawsAltitude:600];
    
    
    METerrainColorBar *colorBar = [[METerrainColorBar alloc]init];

    
    [colorBar.heightColors addObject:
     [[MEHeightColor alloc]initWithHeight:-1000.00001 color:
      [UIColor clearColor]]];
    
    [colorBar.heightColors addObject:
     [[MEHeightColor alloc]initWithHeight:-1000 color:
      [UIColor yellowColor]]];
    
    [colorBar.heightColors addObject:
     [[MEHeightColor alloc]initWithHeight:-100.000001 color:
      [UIColor yellowColor]]];
    
    [colorBar.heightColors addObject:
     [[MEHeightColor alloc]initWithHeight:-100 color:
      [UIColor redColor]]];

    [self.meMapViewController updateTawsColorBar:colorBar];
    self.isRunning = YES;
    
}

- (void) endTest{
    [self.meMapViewController removeMap:self.name clearCache:NO];
}

@end
