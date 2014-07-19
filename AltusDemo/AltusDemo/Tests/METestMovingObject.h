//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <AltusMappingEngine/AltusMappingEngine.h>

@interface METestMovingObject : NSObject

-(id) initWithName:(NSString*) name
          location:(CLLocationCoordinate2D) location
             speed:(float) speed
            course:(float) course
        rateOfTurn:(float) rateOfTurn;

/**Name*/
@property (retain) NSString* name;

/**Current location*/
@property (assign) CLLocationCoordinate2D currentLocation;

/**Old location*/
@property (assign) CLLocationCoordinate2D oldLocation;

/**Direction object is facing.*/
@property (assign) float currentCourse;

/**Direction object is facing.*/
@property (assign) float oldCourse;

/**Speed in knots*/
@property (assign) float speed;

/**Rate of turn in degrees per second.*/
@property (assign) float rateOfTurn;

@property (assign) double distanceTraveled;

/**Call passing elapsed time in seconds to udpate location and course.*/
-(void) update:(float) elapsedTime;
@end
