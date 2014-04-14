//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"

@interface MovingObject : NSObject
@property (retain) NSString* name;
@property (retain) NSString* labelMarkerName;
@property (assign) double heading;
@property (assign) CLLocationCoordinate2D currentLocation;
@property (assign) double velocity;
@property (assign) CLLocationCoordinate2D targetLocation;
@property (assign) BOOL alive;
@property (retain) NSString* imagename;
@property (assign) BOOL isBeingTracked;
@property (retain) NSString* textLabel;
@end

@interface AirTrafficScenario : METest <MEDynamicMarkerMapDelegate>
@property (assign) int uid;
@property (assign) int maxObjects;
@property (retain) NSMutableArray* movingObjects;
@property (assign) CGPoint markerAnchorPoint;
@property (assign) BOOL flipper;
@end
