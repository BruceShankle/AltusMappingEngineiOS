//  Copyright (c) 2013 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import "../METest.h"
#import "../METestCategory.h"
#import "../../MapManager/MapManager.h"

@interface LocalTerrainMapTestsCategory : METestCategory
@property (retain) MapManager* mapManager;
- (void) createTests:(MEMapCategory*) mapCategory;
@end

@interface METerrainTest : METest
-(id) initWithMap:(MEMap*) map compressTextures:(BOOL) compressTextures;
@property (retain) MEMap* map;
@property (assign) BOOL compressTextures;
-(void) addMap;
-(void) removeMap;
@end
