//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import <AltusMappingEngine/AltusMappingEngine.h>

/**Describes a moving object.*/
@interface MovingObject2D : NSObject

@property (assign) float longitude;         //Degrees -180 to 180
@property (assign) float latitude;          //Degrees -90 to 90
@property (assign) float course;            //Degrees 0 to 360
@property (assign) float courseRateOfTurn;  //Degrees per second
@property (assign) float heading;           //Degrees 0 to 360
@property (assign) float headingRateOfTurn; //Degrees per second
@property (assign) float speed;             //Knots
@property (assign) CLLocationCoordinate2D location;
-(void) update:(double) elapsedTimeInSeconds;


@end
