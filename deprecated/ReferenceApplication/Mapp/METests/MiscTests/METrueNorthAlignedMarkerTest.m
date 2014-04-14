//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import "METrueNorthAlgnedMarkerTest.h"
#import "../METestConsts.h"

@implementation METrueNorthAlgnedMarkerTest

- (id) init
{
	if(self=[super init])
	{
		self.name = @"True North Aligned Markers";
	}
	return self;
}

- (void) dealloc
{
	self.compassView = nil;
	[super dealloc];
}

- (void) start
{
	if(self.isRunning)
		return;
	
	self.compassView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"redarrow"]]autorelease];

	[self.meMapViewController.meMapView addSubview:self.compassView];
	self.compassView.contentMode = UIViewContentModeScaleAspectFit;
	self.compassView.frame = CGRectMake(0,0,32,32);
	self.compassView.center = CGPointMake(16,16);
	self.compassView.transform = CGAffineTransformMakeRotation([MEMath toRadians:0]);
	
	//Add a marker map
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.zOrder = 50;
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeDynamicMarker;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingSynchronous;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	MEMarkerAnnotation* marker1 = [[[MEMarkerAnnotation alloc]init]autorelease];
	marker1.coordinate = RDU_COORD;
	marker1.metaData=@"RDU_North";
	marker1.weight = 0;
	[self.meMapViewController addMarkerToMap:self.name
							markerAnnotation:marker1];
	
	//Add third marker - no special marker rotation
	MEMarkerAnnotation* marker2 = [[[MEMarkerAnnotation alloc]init]autorelease];
	marker2.coordinate = RDU_COORD;
	marker2.metaData=@"RDU_East";
	marker2.weight = 0;
	[self.meMapViewController addMarkerToMap:self.name
							markerAnnotation:marker2];
	
	self.interval = 1.0;
	[super start];
	self.isRunning = YES;
}

- (void) mapView:(MEMapView *)mapView updateMarkerInfo:(MEMarkerInfo *)markerInfo mapName:(NSString *)mapName
{
	    
	if([markerInfo.metaData isEqualToString:@"RDU_North"])
	{
		markerInfo.rotationType = kMarkerRotationTrueNorthAligned;
		markerInfo.uiImage = [UIImage imageNamed:@"rednortharrow"];
		markerInfo.anchorPoint = CGPointMake(markerInfo.uiImage.size.width / 2, markerInfo.uiImage.size.height);
		markerInfo.rotation = 0;
	}
	
	if([markerInfo.metaData isEqualToString:@"RDU_East"])
	{
		markerInfo.rotationType = kMarkerRotationTrueNorthAligned;
		markerInfo.uiImage = [UIImage imageNamed:@"greenarroweast"];
		markerInfo.anchorPoint = CGPointMake(markerInfo.uiImage.size.width / 2, markerInfo.uiImage.size.height);
		markerInfo.rotation = 90;
	}
	
}

- (void) timerTick
{
	
	//Rotate the on-screen compass
	CGFloat compassAngle = [self.meMapViewController screenRotationForMapCenterWithHeading:0];
	
	self.compassView.transform = CGAffineTransformMakeRotation([MEMath toRadians:compassAngle]);
}

- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self.compassView removeFromSuperview];
	[self.meMapViewController removeMap:self.name clearCache:NO];
	
	self.isRunning = NO;
}



@end
