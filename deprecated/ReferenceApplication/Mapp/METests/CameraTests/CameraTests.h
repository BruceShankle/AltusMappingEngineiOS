//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"
#import "FlightPlayback.h"

@interface FlightPlaybackUnlocked : METest <MEDynamicMarkerMapDelegate>
@property (retain) NSMutableArray* flightPlaybackSamples;
@property (assign) int sampleIndex;
+(int) getSampleIndex;
+(void) setSampleIndex:(int) newSampleIndex;
@property (assign) BOOL isTrackUp;
- (void) setCameraLocation:(CLLocationCoordinate2D) location
		 animationDuration:(CGFloat) animationDuration;

@end

@interface FlightPlaybackUnlockedFlashing : FlightPlaybackUnlocked
@end

@interface FlightPlaybackCentered : FlightPlaybackUnlocked
@end

@interface FlightPlaybackTrackUpCentered : FlightPlaybackCentered
@end

@interface FlightPlaybackTrackUpCenteredPannable : FlightPlaybackTrackUpCentered
@end

@interface FlightPlaybackTrackUpForward : FlightPlaybackTrackUpCentered
@end

@interface FlightPlaybackTrackUpForwardPannable : FlightPlaybackTrackUpForward
@end

@interface FlightPlaybackTrackUpForwardAnimated : FlightPlaybackTrackUpForward
@property (assign) double trackupForwardDistance;
@end

@interface FlightAcrossAntimeridian : FlightPlaybackCentered
@property (assign) double longitude;
@end

@interface ZoomLimits : METest
@end

@interface ZoomLimitsIncreaseMax : METest
@end

@interface ZoomLimitsDecreaseMax : METest
@end

@interface ZoomLimitsIncreaseMin : METest
@end

@interface ZoomLimitsDecreaseMin : METest
@end


