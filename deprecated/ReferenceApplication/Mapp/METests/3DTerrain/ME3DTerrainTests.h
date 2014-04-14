//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"
#import "../CameraTests/FlightPlayback.h"
#import "../MapManagement/MapManagementCategory.h"

@interface ME3DTerrainTest1 : METest
@property (retain) NSMutableArray* flightPlaybackSamples;
@property (assign) int sampleIndex;
@end


@interface ME3DTerrainCategory : METestCategory
@property (assign) float heading;
@property (assign) float roll;
@property (assign) float pitch;
@end

@interface ME3DCameraToggle : METest
@end

@interface ME3DJumpToBug : METest

@end

@interface ME3DCameraHeadingIncrement : ME3DCameraToggle
@end

@interface ME3DCameraHeadingDecrement : ME3DCameraToggle
@end

@interface ME3DCameraPitchIncrement : ME3DCameraToggle
@end

@interface ME3DCameraPitchDecrement : ME3DCameraToggle
@end


//@interface ME3DCameraHeadingDecrement : METest
//@end
//
