//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import "../../METest.h"
#import "../../METestCategory.h"
#import "../../METestManager.h"
@interface AltusVectorPackage : METest
@property (retain) METest* placeLabelsTest;
@end

@interface AltusVectorPackageBenchmark : AltusVectorPackage
@property (retain) id<MEMapViewDelegate> oldMapViewDelegate;
@property (assign) int mapsLoadingCount;
@property (assign) int initialFPS;
@property (assign) int loadingFPS;
@end

