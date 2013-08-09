//
//  InternetMaps.h
//  Mapp
//
//  Created by Bruce Shankle III on 9/27/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../METest.h"
@class MEInternetTileProvider;

@interface MEInternetMapLoadInvisible : METest
@end

@interface MEInternetMapTest : METest
-(MEInternetTileProvider*) createTileProvider;
+(NSString*) tileCacheRoot;
@property (assign) int maxLevel;
@property (assign) BOOL zoomIndependent;
@property (assign) BOOL compressTextures;
@property (assign) unsigned int zOrder;
@property (assign) BOOL loadInvisible;
@property (assign) MEMapLoadingStrategy loadingStrategy;
@end

@interface MEInternetMapClearCacheTest : METest
+(NSString*) cachePath;
@end

@interface MEInternetMapAnalyzeCacheTest : MEInternetMapClearCacheTest
@property (assign) long fileCount;
@property (assign) long byteCount;
@end

@interface MEMapBoxMarsMapTest : MEInternetMapTest
@end

@interface MERefreshMarsTest : METest
@end

@interface MEMapBoxLandCoverMapTest : MEInternetMapTest
@end

@interface MEMapQuestMapTest : MEInternetMapTest
@end

@interface MEMapQuestAerialMapTest : MEInternetMapTest
@end

@interface MEMapQuestAerialMapTest2 : MEMapQuestAerialMapTest
@end

@interface MEOpenStreetMapsMapTest : MEInternetMapTest
@end

@interface MEStamenTerrainMapTest : MEInternetMapTest
@end

@interface cMEMapBoxLandCoverMapTest : MEMapBoxLandCoverMapTest
@end

@interface cMEMapQuestMapTest : MEMapQuestMapTest
@end

@interface cMEMapQuestAerialMapTest : MEMapQuestAerialMapTest
@end

@interface cMEOpenStreetMapsMapTest : MEOpenStreetMapsMapTest
@end

@interface cMEStamenTerrainMapTest : MEStamenTerrainMapTest
@end

