//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import "FlightPlayback.h"

///////////////////////////////////////
@implementation FlightPlaybackSample
@synthesize longitude;
@synthesize latitude;
@synthesize altitude;
@synthesize heading;
@synthesize roll;
@synthesize pitch;
@end

/////////////////////////////////////////
@implementation FlightPlaybackReader

+ (NSMutableArray*) loadRecordedFlightFromCSVFile:(NSString*) filePath
{
	
	NSMutableArray* playbackSamples = [[[NSMutableArray alloc]init]autorelease];
	
	NSString *flightData = [NSString stringWithContentsOfFile:filePath
													 encoding:NSUTF8StringEncoding
														error:nil ];
	
	NSScanner *scanner = [NSScanner scannerWithString:flightData];
	
	[scanner setCharactersToBeSkipped:
	 [NSCharacterSet characterSetWithCharactersInString:@"\n, "]];
	
	NSString* timeStamp;
	double lon, lat, alt, hdg, roll, pitch;
	const double FEET_TO_METERS = 0.3048;
	while([scanner scanUpToString:@"," intoString:&timeStamp] &&
		  [scanner scanDouble:&lon] &&
		  [scanner scanDouble:&lat] &&
		  [scanner scanDouble:&alt] &&
		  [scanner scanDouble:&hdg] &&
		  [scanner scanDouble:&roll] &&
		  [scanner scanDouble:&pitch])
	{
		alt = alt * FEET_TO_METERS;
		FlightPlaybackSample* sample = [[[FlightPlaybackSample alloc]init]autorelease];
		sample.longitude = lon;
		sample.latitude = lat;
		sample.altitude = alt;
		sample.heading = hdg;
		sample.roll = roll;
		sample.pitch = pitch;
		[playbackSamples addObject:sample];
	}
	return playbackSamples;
}


@end
