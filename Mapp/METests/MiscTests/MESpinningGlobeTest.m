//
//  MESpinningGlobeTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/16/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MESpinningGlobeTest.h"

@implementation MESpinningGlobeTest
@synthesize longitude;

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Spinning Globe";
		self.interval = 1.0;
    }
    return self;
}

- (void) updateLocation:(BOOL) animated
{
    CLLocationCoordinate2D newLocation = CLLocationCoordinate2DMake(0, longitude);
    [self.meMapViewController.meMapView setCenterCoordinate:newLocation
												   animationDuration:1.0];
}

- (void) start
{
    [super start];
    self.longitude = 180;
    [self updateLocation:NO];
}

- (void) timerTick
{
    self.longitude-=0.1;
    if(self.longitude==0)
        self.longitude = 180;
    [self updateLocation:YES];
}



@end
