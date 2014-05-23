//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "MovingObject2D.h"
#import "../METest.h"

@implementation MovingObject2D

-(id) init{
    if(self = [super init]){
        [self randomize];
    }
    return self;
}

- (CLLocationCoordinate2D) location{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}
-(void) setLocation:(CLLocationCoordinate2D)location{
    self.longitude = location.longitude;
    self.latitude = location.latitude;
}

-(void) update:(double)elapsedTimeInSeconds{
    
    //Update heading
    self.heading += self.headingRateOfTurn * elapsedTimeInSeconds;
    if(self.heading>360) self.heading-=360;
    if(self.heading<0) self.heading+=360;
    
    //Update course
    self.course += self.courseRateOfTurn * elapsedTimeInSeconds;
    if(self.course>360) self.course-=360;
    if(self.course<0) self.course+=360;
    
    //Compute new location based on course and speed
    double distanceTraveled = self.speed / 3600 * elapsedTimeInSeconds;
    CGPoint currentLocation = CGPointMake(self.longitude, self.latitude);
    CGPoint newLocation = [MEMath pointOnRadial:currentLocation
                                         radial:self.course
                                       distance:distanceTraveled];
    self.longitude = newLocation.x;
    self.latitude = newLocation.y;
    
    //Compute new course
    self.course = [MEMath courseFromPoint:newLocation toPoint:currentLocation] + 180;
    if(self.course>360){
        self.course-=360;
    }
    
}

-(void) randomize{
    self.longitude = [METest randomFloat:-180 max:180];
    self.latitude = [METest randomFloat:-90 max:90];
    self.heading = [METest randomFloat:0 max: 360];
    self.course = self.heading;
    self.speed = [METest randomFloat:300 max:2000];
}

@end
