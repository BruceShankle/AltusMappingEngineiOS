//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"

@interface MESphericalMercatorMosiacPNG : METest
@property (retain) NSString* fileName;
@property (assign) double minX;
@property (assign) double minY;
@property (assign) double maxX;
@property (assign) double maxY;
@property (assign) BOOL compressTextures;
@property (assign) MEMapLoadingStrategy mapLoadingStrategy;
@property (assign) uint maxLevel;
@property (assign) uint zOrder;
@property (retain) NSString* defaultTileName;
@end
