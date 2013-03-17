//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"

@interface AirTrafficMarker : NSObject
@property (retain) NSString* metaData;
@property (assign) CLLocationCoordinate2D location;
@property (assign) double heading;
@end

@interface AirTrafficTest : METest <MEMarkerMapDelegate>
@property (retain) NSMutableArray* airTrafficMarkers;
@property (assign) CGPoint bluePlaneAnchorPoint;
@end
