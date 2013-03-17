//
//  MEZoomTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/23/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MEZoomTest.h"

@implementation MEZoomInTest
- (id) init
{
    if(self = [super init])
        self.name=@"Zoom In";
    return self;
}
- (void) start {}
- (void) stop { }
- (void)userTapped
{
    [self.meMapViewController.meMapView zoomIn];
}
@end

@implementation MEZoomOutTest
- (id) init
{
    if(self = [super init])
        self.name=@"Zoom Out";
    return self;
}
- (void) start {}
- (void) stop { }
- (void)userTapped
{
    [self.meMapViewController.meMapView zoomOut];
}
@end


const double MEALTITUDETEST_MIN = 0;
const double MEALTITUDETEST_MAX = 10000000;

@implementation MEAltitudeAnimatedTest
@synthesize currentAltitude;
@synthesize altitudeDelta;

- (id) init
{
    if(self = [super init])
        self.name=@"Altitude Animated";
    return self;
}

- (NSString*) label
{
    return [NSString stringWithFormat:@"%f m",
            self.meMapViewController.meMapView.location.altitude];
}

- (void) updateMapAltitude
{
    MELocation newLocation = self.meMapViewController.meMapView.location;
    newLocation.altitude = self.currentAltitude;
    [self.meMapViewController.meMapView setLocation:newLocation animationDuration:0.5];
    [self wasUpdated];
}

- (void) start
{
    [super start];
    self.currentAltitude = MEALTITUDETEST_MIN;
    [self updateMapAltitude];
    self.altitudeDelta = 500000;
    self.isRunning = YES;
}

- (void) stop
{
    [super stop];
    self.isRunning = NO;
}

- (void) timerTick
{
    
    //Clamp to min and max.
    if(self.currentAltitude>MEALTITUDETEST_MAX)
        self.currentAltitude = MEALTITUDETEST_MAX;
    
    if(self.currentAltitude<MEALTITUDETEST_MIN)
        self.currentAltitude = MEALTITUDETEST_MIN;
    
    //Adjust altitude
    self.currentAltitude+=self.altitudeDelta;
    
    //Flip delta if we hit a bounds
    if((self.currentAltitude>MEALTITUDETEST_MAX) ||
       (self.currentAltitude<MEALTITUDETEST_MIN))
    {
        self.altitudeDelta = -self.altitudeDelta;
        self.currentAltitude+=self.altitudeDelta;
    }
    
    NSLog(@"New altitude=%f", self.currentAltitude);
    [self updateMapAltitude];
}

@end

@implementation MEAltitudeNonAnimatedTest
- (id) init
{
    if(self = [super init])
        self.name=@"Altitude NonAnimated";
    return self;
}

- (void) updateMapAltitude
{
    MELocation newLocation = self.meMapViewController.meMapView.location;
    newLocation.altitude = self.currentAltitude;
    self.meMapViewController.meMapView.location = newLocation;
    [self wasUpdated];
}

@end
