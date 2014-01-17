//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"

//Toggle marker appearance using different UIImage objects
@interface BlinkingMarkerTest : METest <MEDynamicMarkerMapDelegate>
@property (assign) BOOL flipper;
@property (retain) NSString* imageName;
@end

//Toggle marker appearance by updating a single cached marker image
@interface CollisionMarkerTest : BlinkingMarkerTest
@end


//Toggle marker appearance by updating a single cached marker image
@interface BlinkingMarkerCachedTest : BlinkingMarkerTest
@end

//Toggle marker appearance by alternating between a UIImage
//object and a cached marker image
@interface BlinkingMarkerHybridTest : BlinkingMarkerTest
@end

//Toggle marker appearance using different UIImage objects
//while animating the marker's location back and forth
//across the United States
@interface BlinkingMovingMarkerTest : BlinkingMarkerTest
@property (assign) CLLocationCoordinate2D location;
@end;

//Toggle marker appears using different UIImage objects
//while animating the marker's rotation.
@interface BlinkingRotatingMarkerTest : BlinkingMarkerTest
@property (assign) double heading;
@end;
