//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import "../../METest.h"
#import "../../METestCategory.h"
#import "../../METestManager.h"

/**Demonstrates showing a packaged map using mapping engine's native support
 for packaged maps.*/
@interface AltusRasterPackageNative : METest
@property (retain) METest* placeLabelsTest;
@property (retain) NSString* pacakgeFileName;
@end

/**Demonstrates showing a packaged map using the TileFactory approach which gives
 you much finer-grained control over how data is loaded.*/
@interface AltusRasterPackageCustom : METest
@property (retain) METest* placeLabelsTest;
@property (retain) NSString* pacakgeFileName;
@end
