//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import "../../METest.h"
#import "../../METestCategory.h"
#import "../../METestManager.h"
@interface SimpleWorld : METest
@property (retain) METest* placeLabelsTest;
@property (assign) BOOL showLabels;
@property (retain) NSString* packageFileName;
@end


@interface SimpleWorldBenchmarkBias : SimpleWorld <MEMapViewDelegate>
@property (retain) id oldDelegate;
@property (assign) double oldTileLevelBias;
@property (assign) BOOL oldTileBiasSmoothingEnabled;
@property (assign) double tileLevelBias;
@property (assign) BOOL tileBiasSmoothingEnabled;
@end

@interface SimpleWorldBenchmarkNoBias : SimpleWorldBenchmarkBias
@end