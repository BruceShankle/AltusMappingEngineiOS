//
//  METileSizingTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/17/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "METileSizingTest.h"

@implementation METileSizingTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Tile Sizing";
    }
    return self;
}

- (NSString*) label
{
    return [NSString stringWithFormat:@"%d", self.meMapViewController.meMapView.maxTileRenderSize];
}

- (void) userTapped
{
    unsigned int testSizes[] = {128,256,380,512};
    int testCount = sizeof testSizes / sizeof(unsigned int);
    unsigned int currentSize = self.meMapViewController.meMapView.maxTileRenderSize;
    //Get next size.
    unsigned int nextSize = testSizes[0];
    for(int i=0; i<testCount; i++)
    {
        if(testSizes[i]>currentSize)
        {
            nextSize=testSizes[i];
            break;
        }
    }
    self.meMapViewController.meMapView.maxTileRenderSize=nextSize;
}


@end
