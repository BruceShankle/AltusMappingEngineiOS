//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import "CameraTests.h"
#import "../METestManager.h"
#import "../METestCategory.h"

///////////////////////////////////////////////////////////////
@implementation FlightPlaybackUnlocked
static int currentSampleIndex=-1;

+(int) getSampleIndex
{
	return currentSampleIndex;
}

+(void) setSampleIndex:(int) newSampleIndex
{
	currentSampleIndex = newSampleIndex;
}

-(id) init
{
	if(self=[super init])
	{
		self.name = @"Playback - Unlocked";
		NSString *filePath = [[NSBundle mainBundle]
							  pathForResource:@"recordedflight" ofType:@"csv"];
		self.flightPlaybackSamples = [FlightPlaybackReader loadRecordedFlightFromCSVFile:filePath];
		self.isTrackUp = NO;
	}
	return self;
}

- (void) dealloc
{
	self.flightPlaybackSamples = nil;
	[super dealloc];
}


//////////////////////////////////////////////////////////////////
//This demonstrates  how to add an animated pulsing circle beacon
//Under the hood, the engine will add a dynamic vector marker layer
//named beacon.name and use that layer to animate a dynamically
//tesselated circle with each drawn frame.
- (void) addOwnshipBeacon
{	
	FlightPlaybackSample* sample = [self currentPlaybackSample];
	
	//Create an animated vector circle object and set up all of its properties
	MEAnimatedVectorCircle* beacon = [[[MEAnimatedVectorCircle alloc]init]autorelease];
	beacon.location = CLLocationCoordinate2DMake(sample.latitude,
												 sample.longitude);
	beacon.name=@"ownship_beacon";
	beacon.lineStyle = [[[MELineStyle alloc]initWithStrokeColor:[UIColor whiteColor]
													strokeWidth:4]autorelease];
	
	UIColor* lightBlue = [UIColor colorWithRed:30.0/255.0
										 green:144.0/255.0
										  blue:255.0/255.0
										 alpha:1.0];
	
	beacon.outlineStyle = [[[MELineStyle alloc]initWithStrokeColor:lightBlue
													   strokeWidth:8]autorelease];
	beacon.minRadius = 5;
	beacon.maxRadius = 75;
	beacon.animationDuration = 2.5;
    beacon.repeatDelay = 0;
	beacon.fade = YES;
	beacon.fadeDelay = 1.0;
	beacon.zOrder= 998;
	
	//Add the animated vector circle
	[self.meMapViewController addAnimatedVectorCircle:beacon];
}

//This function: a) Creates a dynamic marker layer and adds 1 marker to it, then b) calls the addOwnshipBeacon function to add an animated circle that pulses around that marker
- (void) addOwnshipMarker
{
	FlightPlaybackSample* sample = [self currentPlaybackSample];
	
	//Create an array of markers (with one marker in it)
	NSMutableArray* markers= [[[NSMutableArray alloc]init]autorelease];
	MEMarkerAnnotation* ownShipMarker = [[[MEMarkerAnnotation alloc]init]autorelease];
	ownShipMarker.metaData = @"ownship";
	ownShipMarker.coordinate=CLLocationCoordinate2DMake(sample.latitude,
													sample.longitude);
	ownShipMarker.weight=0;
	
	[markers addObject:ownShipMarker];
	
	//Create a marker info object.
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeDynamicMarker;
	mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingSynchronous;
	mapInfo.zOrder = 999;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.markers = markers;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	[self.meMapViewController setMapIsVisible:self.name isVisible:YES];

	//Add a beacon
	[self addOwnshipBeacon];
}


//Update the location and heading of the dynamic marker
-(void) updateOwnShipMarkerLocation:(CLLocationCoordinate2D) location
							heading:(double) heading
				  animationDuration:(CGFloat) animationDuration

{
		
	[self.meMapViewController updateMarkerInMap:self.name
									   metaData:@"ownship"
									newLocation:location
									newRotation:heading
							  animationDuration:animationDuration];
	
	[self.meMapViewController updateAnimatedVectorCircleLocation:@"ownship_beacon"
													 newLocation:location
											   animationDuration:animationDuration];
	
}

- (void) removeOwnshipMarker
{
	[self.meMapViewController removeMap:self.name
								   clearCache:YES];
	
	[self.meMapViewController removeAnimatedVectorCircle:@"ownship_beacon"];
}

//Return the marker image when the engine requests it (this behavior is inconvenient for this scenario, and is derived from our 100,000+ marker scenarios. We may change how images are supplied in the future.
-(void)mapView:(MEMapView *)mapView updateMarkerInfo:(MEMarkerInfo *)markerInfo
	   mapName:(NSString *)mapName
{
	if([markerInfo.metaData isEqualToString:@"ownship"])
	{
		markerInfo.rotationType = kMarkerRotationTrueNorthAligned;
		markerInfo.uiImage=[UIImage imageNamed:@"blueplane"];
		markerInfo.anchorPoint=CGPointMake(markerInfo.uiImage.size.width/2,
										   markerInfo.uiImage.size.height/2);
		markerInfo.nearestNeighborTextureSampling = NO;
	}
}

- (void) preStart
{
}

- (void) postStop
{
	//Enable panning
	self.meMapViewController.meMapView.panEnabled = YES;
}

- (void) start
{
	[self.meTestCategory stopAllTests];
	
	//Add own-ship marker
	[self addOwnshipMarker];

	[self preStart];

	[self updateCameraAndMarker:0];
	
	[super start];
}

- (void) stop
{
	if(!self.isRunning)
		return;
	
	[super stop];
	
	//Remove own-ship marker
	[self removeOwnshipMarker];
	
	[self postStop];
}

- (void) setCameraLocation:(CLLocationCoordinate2D) location
		 animationDuration:(CGFloat) animationDuration
{
	//Since the camera is not locked, do nothing here, other tests derived from this
	//one will update the camera position
}

- (FlightPlaybackSample*) currentPlaybackSample
{
	//Get next flight playback sample using a static member of the base class
	//so as user switches between tests flight continues
	int sampleIndex = [FlightPlaybackCentered getSampleIndex];
	sampleIndex++;
	if(sampleIndex==self.flightPlaybackSamples.count)
		sampleIndex=0;
	[FlightPlaybackCentered setSampleIndex:sampleIndex];
	FlightPlaybackSample* sample = [self.flightPlaybackSamples objectAtIndex:sampleIndex];
	return sample;
}

- (void) updateCameraAndMarker:(CGFloat) animationDuration
{
	FlightPlaybackSample* sample = [self currentPlaybackSample];
	
	//Construct a location from the sample
	CLLocationCoordinate2D location = CLLocationCoordinate2DMake(sample.latitude, sample.longitude);
	
	//Update ownship marker
	[self updateOwnShipMarkerLocation:location
							  heading:sample.heading
					animationDuration:animationDuration];
	
	
	
	//Update camera
	[self setCameraLocation:location animationDuration:animationDuration];
	
	[self.meMapViewController.meMapView setCameraOrientation:sample.heading
														roll:sample.roll
													   pitch:sample.pitch
										   animationDuration:animationDuration];
	
	//Update TAWs altitude
    [self.meMapViewController updateTawsAltitude:sample.altitude];
}

- (void) timerTick
{
	[self updateCameraAndMarker:1.0];
}

@end

///////////////////////////////////////////////////////////////
@implementation FlightPlaybackCentered
-(id) init
{
	if(self=[super init])
	{
		self.name = @"Playback - Centered";
	}
	return self;
}

- (void) setCameraLocation:(CLLocationCoordinate2D) location
		 animationDuration:(CGFloat) animationDuration
{
	[self.meMapViewController.meMapView setCenterCoordinate:location
										  animationDuration:animationDuration];
}

- (void) preStart
{
	//Disable panning
	self.meMapViewController.meMapView.panEnabled = NO;
	[self updateCameraAndMarker:0];
}

- (void) postStop
{
	//Enable panning
	self.meMapViewController.meMapView.panEnabled = YES;
}

@end

///////////////////////////////////////////////////////////////
@implementation FlightAcrossAntimeridian
-(id) init
{
	if(self=[super init])
	{
		self.name = @"Cross Antimeridian";
	}
	return self;
}


- (void) preStart
{
	[super preStart];
	[FlightPlaybackCentered setSampleIndex:-1];
	self.longitude = -165;
	CLLocationCoordinate2D location = CLLocationCoordinate2DMake(0, self.longitude);
	[self.meMapViewController.meMapView setCenterCoordinate:location animationDuration:0];
	
}

- (FlightPlaybackSample*) currentPlaybackSample
{
	if(self.sampleIndex>10)
		self.sampleIndex=-1;
	
	self.sampleIndex++;
	
	FlightPlaybackSample* sample = [[[FlightPlaybackSample alloc]init]autorelease];
	sample.latitude = 0;
	sample.heading = 270;
	
	self.longitude -=1;	
	if (self.longitude<=-180)
		self.longitude=180;
	
	sample.longitude = self.longitude;
	NSLog(@"Longitude = %f", self.longitude);
	
	return sample;
}

@end

///////////////////////////////////////////////////////////////
@implementation FlightPlaybackUnlockedFlashing
-(id) init
{
	if(self=[super init])
	{
		self.name = @"Playback - Unlocked Flashing";
	}
	return self;
}

- (void) timerTick
{
	[super timerTick];
	BOOL mapIsVisible = [self.meMapViewController getMapIsVisible:self.name];
	mapIsVisible = !mapIsVisible;
	[self.meMapViewController setMapIsVisible:self.name isVisible:mapIsVisible];
}

@end

///////////////////////////////////////////////////////////////
@implementation FlightPlaybackTrackUpCentered
-(id) init
{
	if(self=[super init])
	{
		self.name = @"Playback - Track Up Centered";
		self.isTrackUp=YES;
	}
	return self;
}


- (void) preStart
{
	[super preStart];
	[self.meMapViewController updateMarkerRotationInMap:self.name
											   metaData:@"ownship"
											newRotation:0
									  animationDuration:0];
	
	[self.meMapViewController setTrackUpForwardDistance:0
									  animationDuration:0];
	
	[self.meMapViewController setRenderMode:METrackUp];
	
	[self updateCameraAndMarker:0];
	
}

- (void) postStop
{
	[super postStop];
	[self.meMapViewController unsetRenderMode:METrackUp];
}
@end


///////////////////////////////////////////////////////////////
@implementation FlightPlaybackTrackUpCenteredPannable
-(id) init
{
	if(self=[super init])
	{
		self.name = @"Playback - Track Up Centered Pan";
	}
	return self;
}


- (void) preStart
{
	[super preStart];
	self.meMapViewController.meMapView.panEnabled = YES;
}

@end


///////////////////////////////////////////////////////////////
@implementation FlightPlaybackTrackUpForward
-(id) init
{
	if(self=[super init])
	{
		self.name = @"Playback - Track Up Forward";
		self.isTrackUp=YES;
	}
	return self;
}

- (void) preStart
{
	[super preStart];
	[self.meMapViewController updateMarkerRotationInMap:self.name
											   metaData:@"ownship"
											newRotation:0
									  animationDuration:0];
	[self.meMapViewController setRenderMode:METrackUp];
	
	[self.meMapViewController setTrackUpForwardDistance:200
									  animationDuration:0];
	
	[self updateCameraAndMarker:0];
}


- (void) postStop
{
	[super postStop];
	[self.meMapViewController unsetRenderMode:METrackUp];
}
@end

///////////////////////////////////////////////////////////////
@implementation FlightPlaybackTrackUpForwardPannable
-(id) init
{
	if(self=[super init])
	{
		self.name = @"Playback - Track Up Forward Pan";
		self.isTrackUp=YES;
	}
	return self;
}

- (void) preStart
{
	[super preStart];
	self.meMapViewController.meMapView.panEnabled = YES;
}
@end


///////////////////////////////////////////////////////////////
@implementation FlightPlaybackTrackUpForwardAnimated
@synthesize trackupForwardDistance;
-(id) init
{
	if(self=[super init])
	{
		self.name = @"Playback - Track Up Forward Animated";
		self.isTrackUp = YES;
		self.bestFontSize = 12;
	}
	return self;
}

-(NSString*) label
{
	if(!self.isRunning)
		return @"";
	
	return [NSString stringWithFormat:@"%.1f",[self.meMapViewController getTrackUpForwardDistance]];;
}

- (void) preStart
{
	[super preStart];
	[self.meMapViewController setTrackUpForwardDistance:200
									  animationDuration:0];
}

- (void) userTapped
{
	if(!self.isRunning)
	{
		[self start];
		return;
	}
	double currValue = [self.meMapViewController getTrackUpForwardDistance];
	double newValue = currValue - 20;
	
	if(newValue<=0)
	{
		[self stop];
	}
	else
	{
		[self.meMapViewController setTrackUpForwardDistance:newValue
										  animationDuration:1.0];
	}
}


@end


///////////////////////////////////////////////////////////////
@implementation ZoomLimits
-(id) init
{
	if(self=[super init])
	{
		self.name = @"Zoom Limits";
		self.bestFontSize = 16.0;
	}
	return self;
}

- (NSString*) label
{
	return [NSString stringWithFormat:@"%f, %f",
			   self.meMapViewController.meMapView.minimumZoom,
			   self.meMapViewController.meMapView.maximumZoom];
	
}

- (void) start {}
- (void) stop {}

@end

///////////////////////////////////////////////////////////////
@implementation ZoomLimitsIncreaseMax
-(id) init
{
	if(self=[super init])
		self.name = @"Zoom Limits: Max +";
	return self;
}
- (void) start {}
- (void) stop {}
- (void) userTapped
{
	double delta;
	delta = self.meMapViewController.meMapView.maximumZoom / 10;
	self.meMapViewController.meMapView.maximumZoom += delta;
	[self.meTestManager testUpdated:self];
}
@end

///////////////////////////////////////////////////////////////
@implementation ZoomLimitsDecreaseMax
-(id) init
{
	if(self=[super init])
		self.name = @"Zoom Limits: Max -";
	return self;
}
- (void) start {}
- (void) stop {}
- (void) userTapped
{
	double delta;
	delta = self.meMapViewController.meMapView.maximumZoom / 10;
	self.meMapViewController.meMapView.maximumZoom -= delta;
	[self.meTestManager testUpdated:self];
}
@end


///////////////////////////////////////////////////////////////
@implementation ZoomLimitsIncreaseMin
-(id) init
{
	if(self=[super init])
		self.name = @"Zoom Limits: Min +";
	return self;
}
- (void) start {}
- (void) stop {}
- (void) userTapped
{
	double delta;
	delta = self.meMapViewController.meMapView.minimumZoom / 10;
	self.meMapViewController.meMapView.minimumZoom += delta;
	[self.meTestManager testUpdated:self];
}
@end

///////////////////////////////////////////////////////////////
@implementation ZoomLimitsDecreaseMin
-(id) init
{
	if(self=[super init])
		self.name = @"Zoom Limits: Min -";
	return self;
}
- (void) start {}
- (void) stop {}
- (void) userTapped
{
	double delta;
	delta = self.meMapViewController.meMapView.minimumZoom / 10;
	self.meMapViewController.meMapView.minimumZoom -= delta;
	[self.meTestManager testUpdated:self];
}
@end