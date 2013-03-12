//
//  MEInMemoryVectorLinesTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/20/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MEInMemoryVectorLinesTest.h"
#import "../MarkerTests/MarkerTestData.h"

@implementation MEInMemoryVectorLinesTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"In-Memory Lines - Bus Route";
    }
    return self;
}

- (void) start
{
    self.isRunning = YES;
    //Add an in-memory vector map
	MEVectorMapInfo* vectorMapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
	vectorMapInfo.name = self.name;
	vectorMapInfo.zOrder = 100;
	[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];

    //Get some marker test data
    MarkerTestData* markerTestData = [[[MarkerTestData alloc]init]autorelease];
    
    //Create a new line style
    MELineStyle* lineStyle=[[[MELineStyle alloc]init]autorelease];
    lineStyle.strokeColor = [UIColor redColor];
    lineStyle.strokeWidth = 5;
    lineStyle.outlineColor = [UIColor blackColor];
    lineStyle.outlineWidth = 1;
    [self.meMapViewController addLineToVectorMap:self.name
                                          points:markerTestData.sanFranciscoBusRoute
                                           style:lineStyle];
    
    
    [self lookAtSanFrancisco];
    
}

- (void) stop
{
    [self.meMapViewController removeMap:self.name
                                           clearCache:NO];
    self.isRunning = NO;
}


@end
