//
//  MEInvisibleTileProviderTest.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/17/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../METest.h"
#import "MEInternetTileProvider.h"

#import <ME/ME.h>

@interface MEInvisibleTileProvider: METileProvider
@end
@interface MEInvisibleTileProviderTest : METest
@end

@interface MEIntermittentTileProvider : MEMapBoxTileProvider
@property (assign) BOOL returnTiles;
@end

@interface MEUnavailableTileProvider : MEIntermittentTileProvider
@end
@interface MEUnavailableTileProviderTest : METest
@end

@interface MEIntermittentTileProviderTest : METest
@end
