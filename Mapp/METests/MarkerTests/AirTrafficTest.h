//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"

@interface AirPlane : NSObject
@property (retain) NSString* metaData;
@property (assign) CLLocationCoordinate2D location;
@property (assign) double heading;
@property (assign) double altitude;
@property (assign) BOOL updated;
@property (assign) BOOL visible;
@property (assign) BOOL addedToMap;
@property (assign) double speed;
@property (assign) int staleCount;
@property (retain) NSString* carrierAndFlight;
@property (retain) NSString* airplaneType;
@property (assign) double timeStamp;
@end

@interface AirTrafficTest : METest <MEDynamicMarkerMapDelegate>
@property (retain) NSMutableDictionary* airPlanes;
@property (assign) CGPoint bluePlaneAnchorPoint;
@end
