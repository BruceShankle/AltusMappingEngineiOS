//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "AirTrafficScenario.h"
#import "../../METestCategory.h"
#import "../../METestConsts.h"

@implementation MovingObject

- (void) dealloc{
	self.name = nil;
	self.imagename = nil;
	self.textLabel = nil;
	self.labelMarkerName = nil;
}

@end

@implementation AirTrafficScenario

- (id) init{
	if(self=[super init]){
		self.name = @"Air Traffic Scenario";
		self.interval = 0.5;
        self.animationDuration = 5;
		self.uid = 0;
		self.maxObjects = 200;
		self.movingObjects = [[NSMutableArray alloc]init];
		UIImage* imgBluePlane = [UIImage imageNamed:@"blueplane"];
		self.markerAnchorPoint = CGPointMake(imgBluePlane.size.width/2.0, imgBluePlane.size.height/2.0);
	}
	return self;
}

- (void) dealloc{
	self.movingObjects = nil;
}

- (CLLocationCoordinate2D) getRandomLocation{
	int lon = -[METest randomDouble:-RDU_COORD.longitude max:-SFO_COORD.longitude];
	int lat = [METest randomDouble:15 max:75];
	return CLLocationCoordinate2DMake(lat, lon);
}

- (CLLocationCoordinate2D) computeTargetLocation:(CLLocationCoordinate2D) currentLocation
										velocity:(double) velocity
										 heading:(double) heading
{
	CGPoint targetPoint = [MEMath pointOnRadial:CGPointMake(currentLocation.longitude,
															currentLocation.latitude)
										 radial:heading
									   distance:velocity / 3600];
	return CLLocationCoordinate2DMake(targetPoint.y, targetPoint.x);
}

- (MovingObject*) newObject{
	self.uid++;


	MovingObject* movingObject = [[MovingObject alloc]init];
	movingObject.heading = [METest randomDouble:0 max:360];
	movingObject.name = [NSString stringWithFormat:@"%d", self.uid];;
	movingObject.labelMarkerName = [NSString stringWithFormat:@"%d_label", self.uid];;
	
	movingObject.velocity = [METest randomDouble:100000 max:500000];
	movingObject.currentLocation = [self getRandomLocation];
	movingObject.targetLocation = [self computeTargetLocation:movingObject.currentLocation
													 velocity:movingObject.velocity
													  heading:movingObject.heading];
	movingObject.alive = YES;
	
	//Add the dynamic marker
	MEMarker* marker = [[MEMarker alloc]init];
	marker.uniqueName = movingObject.name;
	marker.cachedImageName = @"blueplane"; //you could otherwise set uiImage here
	marker.anchorPoint = self.markerAnchorPoint; //computed in init
	marker.location = movingObject.currentLocation;
	marker.rotation = movingObject.heading;
	marker.rotationType = kMarkerRotationTrueNorthAligned;
	[self.meMapViewController addDynamicMarkerToMap:self.name
									  dynamicMarker:marker];
	
	//Add dynamic label marker and hide it.
	marker.uniqueName = movingObject.labelMarkerName;
	marker.rotationType = kMarkerRotationScreenEdgeAligned;
	marker.rotation = 0;
	marker.offset = CGPointMake(0,64);
	[self.meMapViewController addDynamicMarkerToMap:self.name
									  dynamicMarker:marker];
	[self.meMapViewController hideDynamicMarker:self.name markerName:marker.uniqueName];
	
	//Animate the marker to it's target location.
	[self.meMapViewController updateDynamicMarkerLocation:self.name
											   markerName:movingObject.name
												 location:movingObject.targetLocation
										animationDuration:self.animationDuration];
	
	return movingObject;
}

- (void) cacheMarkerImage:(NSString*) name
{
	[self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:name]
										  withName:name
								   compressTexture:NO
					nearestNeighborTextureSampling:NO];
}

- (void) addMap
{
	//Pre-cache marker images we'll use for this scenario
	[self cacheMarkerImage:@"yellowplane"];
	[self cacheMarkerImage:@"orangeplane"];
	[self cacheMarkerImage:@"redplane"];
	[self cacheMarkerImage:@"whiteplaneredoutline"];
	[self cacheMarkerImage:@"blueplane"];
	[self cacheMarkerImage:@"purpleplane"];
	
	MEDynamicMarkerMapInfo* mapInfo = [[MEDynamicMarkerMapInfo alloc]init];
	mapInfo.name = self.name;
	mapInfo.zOrder = 200;
	mapInfo.hitTestingEnabled = YES;
	mapInfo.meDynamicMarkerMapDelegate = self;
	mapInfo.fadeInTime = 1.0;
	mapInfo.fadeOutTime = 1.0;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	
}

- (void) addObjects
{
	for(int i=0; i<self.maxObjects; i++)
	{
		MovingObject* movingObject = [self newObject];
		[self.movingObjects addObject:movingObject];
	}
}

- (void) addBeacon
{
	
	//Create an animated vector circle object and set up all of its properties
	MEAnimatedVectorCircle* beacon = [[MEAnimatedVectorCircle alloc]init];
	beacon.name=@"beacon";
	beacon.lineStyle = [[MELineStyle alloc]initWithStrokeColor:[UIColor whiteColor]
													strokeWidth:4];
	
	UIColor* lightBlue = [UIColor colorWithRed:30.0/255.0
										 green:144.0/255.0
										  blue:255.0/255.0
										 alpha:1.0];
	beacon.lineStyle.outlineColor = lightBlue;
	beacon.lineStyle.outlineWidth = 4;
	
	beacon.minRadius = 5;
	beacon.maxRadius = 75;
	beacon.animationDuration = 2.5;
    beacon.repeatDelay = 0;
	beacon.fade = YES;
	beacon.fadeDelay = 1.0;
	beacon.zOrder= 5;
	
	//Add the animated vector circle
	[self.meMapViewController addAnimatedVectorCircle:beacon];
}

//For any threats, toggle marker image so it 'flashes'
- (void) flashDangerousObjects
{
	BOOL update;
	for(MovingObject* movingObject in self.movingObjects)
	{
		update=NO;
		if(movingObject.alive)
		{
			if([movingObject.imagename isEqualToString:@"redplane"])
			{
				movingObject.imagename = @"whiteplaneredoutline";
				update=YES;
			}
			else if ([movingObject.imagename isEqualToString:@"whiteplaneredoutline"])
			{
				movingObject.imagename = @"redplane";
				update=YES;
			}
			if(update)
				[self.meMapViewController updateDynamicMarkerImage:self.name
														markerName:movingObject.name
												   cachedImageName:movingObject.imagename
													   anchorPoint:self.markerAnchorPoint
															offset:CGPointMake(0,0)];
			
		}
	}
    [self startTimer];
}

- (void) trackObject:(MovingObject*) objectToTrack
{
	MELocation loc = self.meMapViewController.meMapView.location;
	loc.center.longitude = objectToTrack.targetLocation.longitude;
	loc.center.latitude = objectToTrack.targetLocation.latitude;
	[self.meMapViewController.meMapView setLocation:loc animationDuration:self.animationDuration];
	[self.meMapViewController updateDynamicMarkerImage:self.name
											markerName:objectToTrack.name
									   cachedImageName:@"purpleplane"
										   anchorPoint:self.markerAnchorPoint
												offset:CGPointMake(0,0)];
	
	//Move animated beacon
	double beaconAnimationDuration = self.animationDuration;
	if(!objectToTrack.isBeingTracked)
		beaconAnimationDuration = 0;
	[self.meMapViewController updateAnimatedVectorCircleLocation:@"beacon"
													 newLocation:objectToTrack.targetLocation
											   animationDuration:beaconAnimationDuration];
	objectToTrack.isBeingTracked = YES;
	
	
	
	//Detect collisions and set images according to threat level
	CGPoint p1 = CGPointMake(objectToTrack.targetLocation.longitude,
							 objectToTrack.targetLocation.latitude);
	
	for(MovingObject* otherObject in self.movingObjects)
	{
		if(otherObject.alive && otherObject!=objectToTrack)
		{
			CGPoint p2 = CGPointMake(otherObject.targetLocation.longitude,
									 otherObject.targetLocation.latitude);
			double radiansBetween = [MEMath distanceBetween:p1 point2:p2];
			double distance = [MEMath radiansToNauticalMiles:radiansBetween];
			
			//Show a text label for threats?
			if(distance<500)
			{
				otherObject.textLabel = [NSString stringWithFormat:@"%0.1f NM H:%0.0f° %0.0f MPH",
										 distance,
										 otherObject.heading,
										 otherObject.velocity];
				UIImage* uiImage;
				uiImage = [MEFontUtil newImageWithFontOutlined:@"ArialMT"
														 fontSize:15
														fillColor:[UIColor whiteColor]
													  strokeColor:[UIColor blackColor]
													  strokeWidth:0
															 text:otherObject.textLabel];
				
				//Compute anchor point and offset for the label
				CGPoint anchorPoint = CGPointMake(uiImage.size.width / 2, uiImage.size.height);
				CGPoint offset = CGPointMake(0, self.markerAnchorPoint.y+15);
				
				//Update the threat label marker image.
				[self.meMapViewController updateDynamicMarkerImage:self.name
														markerName:otherObject.labelMarkerName
														   uiImage:uiImage
													   anchorPoint:anchorPoint
															offset:offset
												   compressTexture:NO];
				
				//Show the marker at current location and animate to target location.
				[self.meMapViewController showDynamicMarker:self.name markerName:otherObject.labelMarkerName];
				[self.meMapViewController updateDynamicMarkerLocation:self.name
														   markerName:otherObject.labelMarkerName
															 location:otherObject.currentLocation
													animationDuration:0];
				
				[self.meMapViewController updateDynamicMarkerLocation:self.name
														   markerName:otherObject.labelMarkerName
															 location:otherObject.targetLocation
													animationDuration:self.animationDuration];
			}
			else
			{
				//Animate and hide the label
				[self.meMapViewController updateDynamicMarkerLocation:self.name
														   markerName:otherObject.labelMarkerName
															 location:otherObject.targetLocation
													animationDuration:self.animationDuration];
				
				[self.meMapViewController hideDynamicMarker:self.name markerName:otherObject.labelMarkerName];
			}
			
			if(distance<200)
				otherObject.imagename = @"redplane";
			else if(distance<250)
				otherObject.imagename = @"orangeplane";
			else if(distance<500)
				otherObject.imagename = @"yellowplane";
			else
				otherObject.imagename = @"blueplane";
			
			//Update the target image.
			[self.meMapViewController updateDynamicMarkerImage:self.name
													markerName:otherObject.name
											   cachedImageName:otherObject.imagename
												   anchorPoint:self.markerAnchorPoint
														offset:CGPointMake(0,0)];
		}
	}

}

- (MovingObject*) findDeadObject
{
	for(int i=0; i<self.movingObjects.count; i++)
	{
		MovingObject* o = (MovingObject*)[self.movingObjects objectAtIndex:i];
		if(!o.alive)
			return o;
	}
	return nil;
}

- (void) updateObjects
{
	BOOL flip = NO;
		
	for(MovingObject* movingObject in self.movingObjects)
	{
		if(movingObject.alive)
		{
			movingObject.imagename = @"blueplane";
			movingObject.currentLocation = movingObject.targetLocation;
			flip = !flip;
			if(flip)
				movingObject.heading += 2.5;
			else
				movingObject.heading -= 2.5;
			
			movingObject.targetLocation = [self computeTargetLocation:movingObject.currentLocation
															 velocity:movingObject.velocity
															  heading:movingObject.heading];
			
			if(fabs(movingObject.currentLocation.latitude)>75 ||
			   fabs(movingObject.targetLocation.latitude)>75)
			{
				movingObject.alive = NO;
			}
		
			
			//Update marker attributes
			[self.meMapViewController updateDynamicMarkerLocation:self.name
													   markerName:movingObject.name
														 location:movingObject.targetLocation
												animationDuration:self.animationDuration];
						
			[self.meMapViewController updateDynamicMarkerRotation:self.name
													   markerName:movingObject.name
														 rotation:movingObject.heading animationDuration:0.7];
			
		}
	}
	
	//Remove dead objects
	int deadObjectCount = 0;
	MovingObject* deadObject = [self findDeadObject];
	while(deadObject)
	{
		deadObjectCount++;
		[self.meMapViewController removeDynamicMarkerFromMap:self.name
												  markerName:deadObject.name];
		[self.meMapViewController removeDynamicMarkerFromMap:self.name
												  markerName:deadObject.labelMarkerName];
		[self.movingObjects removeObject:deadObject];
		deadObject = [self findDeadObject];
	}
	
	//Replace dead objects with new ones
	for(int i=0; i<deadObjectCount; i++)
	{
		MovingObject* o = [self newObject];
		[self.movingObjects addObject:o];
	}
	
	//Track first object
	MovingObject* trackedObject = [self.movingObjects objectAtIndex:0];
	[self trackObject:trackedObject];
	
}

- (void) start
{
	if(self.isRunning)
		return;
	
	[self.meTestCategory stopAllTests];
	[self addMap];
	[self addBeacon];
	[self addObjects];
	[self startTimer];
	
	self.isRunning = YES;
}


- (void) timerTick
{
	//timer ticks on 0.5 second intervals.
	//we update everything on 1 second intervale (i.e. when self.flipper is true)
	//and we update danger targets every 0.5 seconds.
    [self stopTimer];
	self.flipper = !self.flipper;
	if(self.flipper)
	{
		//Occurs on 
		[self updateObjects];
	}
	[self flashDangerousObjects];
}

- (void) stop
{
	if(!self.isRunning)
		return;
	[self stopTimer];
	[self.meMapViewController removeMap:self.name clearCache:NO];
	[self.meMapViewController removeAnimatedVectorCircle:@"beacon"];
	[self.movingObjects removeAllObjects];
	self.isRunning = NO;
}


- (void) tapOnDynamicMarker:(NSString *)markerName
				  onMapView:(MEMapView *)mapView
					mapName:(NSString *)mapName
			  atScreenPoint:(CGPoint)screenPoint
			  atMarkerPoint:(CGPoint)markerPoint
{
	
	NSLog(@"Dynamic marker tap detected on map name: %@, marker name: %@, screen point:(%f, %f), longitude:%f latitude:%f",
		  mapName,
		  markerName,
		  screenPoint.x,
		  screenPoint.y,
		  markerPoint.x,
		  markerPoint.y);
}

@end
