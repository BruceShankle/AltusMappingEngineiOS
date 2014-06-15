//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "Earth.h"

@implementation Earth

-(id) init{
    if(self=[super init]){
        self.name = @"Earth";
    }
    return self;
}

+ (MEHeightColor*) createColorEntry:(double)value withColor:(int)hex {
    
    MEHeightColor* heightColor = [[MEHeightColor alloc]init];
    heightColor.color =  [UIColor colorWithRed:((float)((hex & 0xFF000000) >> 24))/255.0
                                         green:((float)((hex & 0xFF0000) >> 16))/255.0
                                          blue:((float)((hex & 0xFF00) >> 8))/255.0
                                         alpha:((float)(hex & 0xFF))/255.0];
    heightColor.height = value;
    
    return heightColor;
}

+ (METerrainColorBar *) createNE1Colors {
    
    METerrainColorBar *colorBar = [[METerrainColorBar alloc] init];
    
    [colorBar.heightColors addObject:[self createColorEntry:0 withColor:0x0d603eff]];
    [colorBar.heightColors addObject:[self createColorEntry:50 withColor:0x238158ff]];
    [colorBar.heightColors addObject:[self createColorEntry:200 withColor:0x399365ff]];
    [colorBar.heightColors addObject:[self createColorEntry:600 withColor:0x74a174ff]];
    [colorBar.heightColors addObject:[self createColorEntry:1000 withColor:0xc1af87ff]];
    [colorBar.heightColors addObject:[self createColorEntry:2000 withColor:0xc5936cff]];
    [colorBar.heightColors addObject:[self createColorEntry:3000 withColor:0xc3a389ff]];
    [colorBar.heightColors addObject:[self createColorEntry:4000 withColor:0xc3bbb6ff]];
    [colorBar.heightColors addObject:[self createColorEntry:5000 withColor:0xcfd2d1ff]];
    [colorBar.heightColors addObject:[self createColorEntry:6000 withColor:0xeaeaedff]];
    [colorBar.heightColors addObject:[self createColorEntry:7000 withColor:0xffffffff]];
    
    colorBar.waterColor = [self createColorEntry:0 withColor:0x78a7cbff].color;
    return colorBar;
}

+ (METerrainColorBar *) createNE3Colors {
    
    METerrainColorBar *colorBar = [[METerrainColorBar alloc] init];
    
    [colorBar.heightColors addObject:[self createColorEntry:0 withColor:0x4e7a5fff]];
    [colorBar.heightColors addObject:[self createColorEntry:50 withColor:0x5c8563ff]];
    [colorBar.heightColors addObject:[self createColorEntry:200 withColor:0x6f8d6dff]];
    [colorBar.heightColors addObject:[self createColorEntry:600 withColor:0x9a9874ff]];
    [colorBar.heightColors addObject:[self createColorEntry:1000 withColor:0xa1a094ff]];
    [colorBar.heightColors addObject:[self createColorEntry:2000 withColor:0xcab9a6ff]];
    [colorBar.heightColors addObject:[self createColorEntry:3000 withColor:0xc6947cff]];
    [colorBar.heightColors addObject:[self createColorEntry:4000 withColor:0x957b66ff]];
    
    [colorBar.heightColors addObject:[self createColorEntry:5000 withColor:0xcab9a6ff]];
    [colorBar.heightColors addObject:[self createColorEntry:6000 withColor:0xd8e0edff]];
    [colorBar.heightColors addObject:[self createColorEntry:7000 withColor:0xecf1f8ff]];
    
    colorBar.waterColor = [self createColorEntry:0 withColor:0x005f99ff].color;
    return colorBar;
}

- (void) beginTest{
    [self.meTestCategory stopAllTests];
    
    NSString* sqliteFile = [[NSBundle mainBundle] pathForResource:@"Earth"
                                                           ofType:@"sqlite"];
    
    NSString* mapFile = [[NSBundle mainBundle] pathForResource:@"Earth"
                                                        ofType:@"map"];
    
    [self.meMapViewController addMap:self.name
                   mapSqliteFileName:sqliteFile
                     mapDataFileName:mapFile
                    compressTextures:NO];
    
    [self.meMapViewController setMapZOrder:self.name zOrder:1];
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//
//    NSString* usWestSqlite = [documentsDirectory stringByAppendingPathComponent:@"/Maps/USWest.sqlite"];
//    NSString* usWestMap = [documentsDirectory stringByAppendingPathComponent:@"/Maps/USWest.map"];
//    [self.meMapViewController addMap:@"USWest"
//                   mapSqliteFileName:usWestSqlite
//                     mapDataFileName:usWestMap
//                    compressTextures:NO];
//    
//    
//    [self.meMapViewController setMapZOrder:@"USWest" zOrder:2];
    
    
    [self.meMapViewController updateTerrainColorBar:[Earth createNE3Colors]];
}

- (void) endTest{
    [self.meMapViewController removeMap:self.name clearCache:NO];
}

@end
