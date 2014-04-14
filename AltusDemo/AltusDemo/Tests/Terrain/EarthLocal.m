//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "Terrain.h"

@implementation EarthLocal

-(id) init{
    if(self=[super init]){
        self.name = @"Earth - Terrain";
    }
    return self;
}

- (void) start{
    if(self.isRunning){
        return;
    }
    
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
    self.isRunning = YES;
    
}

- (void) stop{
    if(!self.isRunning){
        return;
    }
    [self.meMapViewController removeMap:self.name clearCache:NO];
    self.isRunning = NO;
}

@end
