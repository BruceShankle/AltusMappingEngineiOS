//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "METestMovingObject.h"

@implementation METestMovingObject

-(id) initWithName:(NSString*) name
          location:(CLLocationCoordinate2D) location
             speed:(float) speed
            course:(float) course
        rateOfTurn:(float) rateOfTurn{
    if(self = [super init]){
        self.name = name;
        self.currentLocation = location;
        self.oldLocation = location;
        self.speed = speed;
        self.currentCourse = course;
        self.oldCourse = course;
        self.rateOfTurn = rateOfTurn;
        self.distanceTraveled = 0;
    }
    return self;
}

- (void) update:(float)elapsedTime{
    
    //Update course
    self.currentCourse += elapsedTime * self.rateOfTurn;
    if(self.currentCourse > 360){
        self.currentCourse -= 360;
    }
    else if(self.currentCourse < 0) {
        self.currentCourse += 360;
    }
    
    //Compute new location based on course and speed
    CGPoint currentPoint = CGPointMake(self.currentLocation.longitude,
                                       self.currentLocation.latitude);
    
    CGPoint newPoint = [MEMath pointOnRadial:currentPoint
                                      radial:self.currentCourse
                                    distance:self.speed/3600];
    self.oldLocation = self.currentLocation;
    self.currentLocation = CLLocationCoordinate2DMake(newPoint.y, newPoint.x);
    
    //Accumulate distance
    self.distanceTraveled += [MEMath nauticalMilesBetween:currentPoint point2:newPoint];
    
    //Compute new course after location change (we might have crossed a pole)
    self.oldCourse = self.currentCourse;
    self.currentCourse = [MEMath courseFromPoint:newPoint toPoint:currentPoint] + 180;
    if(self.currentCourse>360){
        self.currentCourse-=360;
    }
}

@end
