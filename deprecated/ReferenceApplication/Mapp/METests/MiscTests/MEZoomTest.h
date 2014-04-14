//
//  MEZoomTest.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/23/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "METest.h"


@interface MEZoomInTest : METest
@end

@interface MEZoomOutTest : METest
@end

extern const double MEALTITUDETEST_MIN;
extern const double MEALTITUDETEST_MAX;

@interface MEAltitudeAnimatedTest : METest
@property (assign) double currentAltitude;
@property (assign) double altitudeDelta;
@end

@interface MEAltitudeNonAnimatedTest : MEAltitudeAnimatedTest
@end
