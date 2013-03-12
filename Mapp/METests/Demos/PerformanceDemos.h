//
//  PerformanceDemo.h
//  Mapp
//
//  Created by Bruce Shankle III on 10/12/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../METest.h"

@interface PlanetWatch : METest
@property (assign) int demoStep;
@property (assign) double demoTime;

@end

@interface PlanetWatchRaster : PlanetWatch
@property (assign) int testIndex;
@property (retain) NSMutableArray* otherTests;
@end

@interface PlanetWatchVector : PlanetWatchRaster
@end
