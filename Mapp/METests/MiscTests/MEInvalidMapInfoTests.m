//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MEInvalidMapInfoTests.h"

@implementation MENilStringsTest

- (id) init
{
	if(self=[super init])
	{
		self.name=@"Nil Strings";
	}
	return self;
}

- (void) start
{
	if(self.isRunning)
		return;
	
	//Try adding a bunch of invalid marker maps.
	NSLog(@"\n\nNil MEMarkerMapInfo Test:");
	MEMarkerMapInfo* markerMapInfo = nil;
	[self.meMapViewController addMapUsingMapInfo:markerMapInfo];
	
	markerMapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	[self.meMapViewController addMapUsingMapInfo:markerMapInfo];
	NSLog(@"\n\nUnfilled MEMarkerMapInfo Test:");
	
	markerMapInfo.name =self.name;
	[self.meMapViewController addMapUsingMapInfo:markerMapInfo];
	NSLog(@"\n\nName only MEMarkerMapInfo Test:");
	
	markerMapInfo.mapType = kMapTypeFileMarker;
	[self.meMapViewController addMapUsingMapInfo:markerMapInfo];
	NSLog(@"\n\nName and Type only MEMarkerMapInfo Test:");
	
	self.isRunning = YES;
}

- (void) stop
{
	if(!self.isRunning)
		return;
	self.isRunning = NO;
}

@end
