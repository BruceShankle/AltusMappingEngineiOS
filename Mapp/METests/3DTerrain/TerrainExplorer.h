//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"
#import "TerrainExplorerUI.h"

@interface MapExplorer : METest
@property (retain) TerrainExplorerUI* terrainExplorerUI;
@property (retain) id<MEMapViewDelegate> oldDelegate;
@end
