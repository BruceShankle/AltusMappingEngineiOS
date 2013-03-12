//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>

@interface FlightPlaybackSample : NSObject
@property (assign) double longitude;
@property (assign) double latitude;
@property (assign) double altitude;
@property (assign) double heading;
@property (assign) double roll;
@property (assign) double pitch;
@end

@interface FlightPlaybackReader : NSObject
+ (NSMutableArray*) loadRecordedFlightFromCSVFile:(NSString*) filePath;
@end
