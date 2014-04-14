//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import "../../METest.h"
#import "../../METestCategory.h"
#import "../../METestManager.h"
@interface HoustonStreetsStyle1 : METest
@property (assign) BOOL texturesCached;
@property (retain) NSString* styleName;
@property (retain) NSString* mapName;
@end

@interface HoustonStreetsStyle2 : HoustonStreetsStyle1
@end

@interface HoustonStreetsStyle3 : HoustonStreetsStyle1
@end

