//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import "../../METest.h"
#import "../../METestCategory.h"
#import "../../METestManager.h"

@interface MapBoxStreets : METest
@property (retain) NSString* urlTemplate;
@property (assign) BOOL useNetworkCache;
@end

@interface MapBoxStreetsNoCache : MapBoxStreets
@end