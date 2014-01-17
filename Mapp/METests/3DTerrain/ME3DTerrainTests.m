//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "ME3DTerrainTests.h"
#import "../METestCategory.h"

@implementation ME3DTerrainCategory

- (id) init{
    if(self = [super init]){
        self.heading = 0;
        self.roll = 0;
        self.pitch = -90;
	}
    return self;
}

@end

@implementation ME3DCameraToggle

- (id) init {
    if(self = [super init]){
        self.name=@"Camera 3D Toggle";
	}
    return self;
}

- (void) updateCamera {
    ME3DTerrainCategory *category = (ME3DTerrainCategory*)self.meTestCategory;
    
    [self.meMapViewController.meMapView setCameraOrientation:category.heading
														roll:category.roll
													   pitch:category.pitch
										   animationDuration:1];
}

- (void) start{
	if(self.isRunning){
		return;
	}

	//Stop all other tests.
	[self.meTestCategory stopAllTests];
    
    // reset 3d settings
    self.meMapViewController.meMapView.tileLevelBias = 0;
	[self.meMapViewController setRenderMode:MERender3D];
    
    ME3DTerrainCategory *category = (ME3DTerrainCategory*)self.meTestCategory;
    [self.meMapViewController.meMapView setCameraOrientation:category.heading
														roll:category.roll
													   pitch:category.pitch
										   animationDuration:0];
	
	self.isRunning = YES;
}

- (void) stop{
	if(!self.isRunning){
		return;
	}

    // reset 2d settings
    self.meMapViewController.meMapView.tileLevelBias = 1.0;
	[self.meMapViewController setRenderMode:MERender2D];
    
    
    [self updateCamera];

    self.isRunning = NO;
}
@end


@implementation ME3DCameraHeadingIncrement

- (id) init{
    if(self = [super init]){
        self.name=@"Camera Heading Increment";
	}
    return self;
}


- (void) start{
	if(self.isRunning){
		return;
	}
    
    ME3DTerrainCategory *category = (ME3DTerrainCategory*)self.meTestCategory;
    category.heading += 10;
    [self updateCamera];
}

- (void) stop{

}

@end

@implementation ME3DCameraHeadingDecrement

- (id) init{
    if(self = [super init]){
        self.name=@"Camera Heading Decrement";
	}
    return self;
}


- (void) start{
	if(self.isRunning){
		return;
	}
    
    ME3DTerrainCategory *category = (ME3DTerrainCategory*)self.meTestCategory;
    category.heading -= 10;
    [self updateCamera];
}

- (void) stop{
    
}

@end

@implementation ME3DCameraPitchIncrement

- (id) init{
    if(self = [super init]){
        self.name=@"Camera Pitch Increment";
	}
    return self;
}


- (void) start{
	if(self.isRunning){
		return;
	}
    
    ME3DTerrainCategory *category = (ME3DTerrainCategory*)self.meTestCategory;
    category.pitch += 10;
    [self updateCamera];
}

- (void) stop{
    
}

@end

@implementation ME3DCameraPitchDecrement

- (id) init{
    if(self = [super init]){
        self.name=@"Camera Pitch Decrement";
	}
    return self;
}


- (void) start{
	if(self.isRunning){
		return;
	}
    
    ME3DTerrainCategory *category = (ME3DTerrainCategory*)self.meTestCategory;
    category.pitch -= 10;
    [self updateCamera];
}

- (void) stop{
    
}

@end

@implementation ME3DJumpToBug

- (id) init{
    if(self = [super init]){
        self.name=@"Jump To NC";
	}
    return self;
}

- (void) start{
	if(self.isRunning){
		return;
	}
	
    
    [self.meMapViewController.meMapView setCenterCoordinate:CLLocationCoordinate2DMake(35.3834, -82.9076) animationDuration:1];
    [self.meMapViewController.meMapView setCameraAltitude:9648.58 animationDuration:1.0];
	//Update to looking down
    [self.meMapViewController.meMapView setCameraOrientation:70
														roll:0
													   pitch:-20
										   animationDuration:1];
    
}
@end

@implementation ME3DTerrainTest1

- (id) init{
    if(self = [super init]){
        self.name=@"3D Terrain Test 1";
		self.interval = 1.0;
	}
    return self;
}

- (void) dealloc{
	self.flightPlaybackSamples = nil;
	[super dealloc];
}


- (void) loadFlightPlaybackSamples{
	if(self.flightPlaybackSamples==nil){
		NSString *filePath = [[NSBundle mainBundle]
							  pathForResource:@"mtranierflight" ofType:@"csv"];
		self.flightPlaybackSamples = [FlightPlaybackReader loadRecordedFlightFromCSVFile:filePath];
		self.sampleIndex = 0;
	}
}

- (void) start{
	if(self.isRunning){
		return;
	}
	
	//Load flight playback samples
	[self loadFlightPlaybackSamples];
	
	//Stop all other tests.
	[self.meTestCategory stopAllTests];
	
	//Go into 3D mode.
	[self.meMapViewController setRenderMode:MERender3D];
    
//    [self.meMapViewController.meMapView lookAtCoordinate:CLLocationCoordinate2DMake(35.337254,-83.665745)
//                                           andCoordinate:CLLocationCoordinate2DMake(35.527756,-83.483098)
//                                    withHorizontalBuffer:0
//                                      withVerticalBuffer:0
//                                       animationDuration:0];
//    
    [self.meMapViewController setBaseMapImage:[UIImage imageNamed:@"tile_0.0.png"]];
    
    [self.meMapViewController addCachedImage:[UIImage imageNamed:@"tile_0.0.png"]
                                    withName:@"tile_1"
                             compressTexture:YES];
    [self.meMapViewController addCachedImage:[UIImage imageNamed:@"tile_1.0.png"]
                                    withName:@"tile_2"
                             compressTexture:YES];
    [self.meMapViewController addCachedImage:[UIImage imageNamed:@"tile_2.0.png"]
                                    withName:@"tile_3"
                             compressTexture:YES];
    [self.meMapViewController addCachedImage:[UIImage imageNamed:@"tile_3.0.png"]
                                    withName:@"tile_4"
                             compressTexture:YES];
    [self.meMapViewController addCachedImage:[UIImage imageNamed:@"tile_4.0.png"]
                                    withName:@"tile_5"
                             compressTexture:YES];
    
	
	//Update to looking down
    [self.meMapViewController.meMapView setCameraOrientation:0
														roll:0
													   pitch:-90
										   animationDuration:0];
    
    // animate to looking more towards the horizon
	[self.meMapViewController.meMapView setCameraOrientation:0
														roll:0
													   pitch:-40
										   animationDuration:2];

	
	//Start timer
	[self startTimer];
	
	self.isRunning = YES;
}

- (void) timerTick{
	//[self updateCamera:self.interval];
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
	
	//Stop timer
	[self stopTimer];
	
	
	[self.meMapViewController setRenderMode:MERender2D];
    
    // animate to looking down
    [self.meMapViewController.meMapView setCameraOrientation:0
														roll:0
													   pitch:-90
										   animationDuration:0];
	
	self.isRunning = NO;
}

- (FlightPlaybackSample*) currentPlaybackSample{
	self.sampleIndex++;
	if(self.sampleIndex==self.flightPlaybackSamples.count){
		self.sampleIndex=0;
	}
	FlightPlaybackSample* sample = [self.flightPlaybackSamples objectAtIndex:self.sampleIndex];
	return sample;
}


- (void) updateCamera:(CGFloat) animationDuration {
	
	//Get current sample
	FlightPlaybackSample* sample = [self currentPlaybackSample];
	
	//Construct a location from the sample
	CLLocationCoordinate2D location = CLLocationCoordinate2DMake(sample.latitude, sample.longitude);
	
	//Update camera location
	[self.meMapViewController.meMapView setCenterCoordinate:location
										  animationDuration:animationDuration];
	
	
	//Update camera orientation
	[self.meMapViewController.meMapView setCameraOrientation:sample.heading
														roll:sample.roll
													   pitch:sample.pitch
										   animationDuration:animationDuration];
	
	
	//Update camera height
	[self.meMapViewController.meMapView setCameraAltitude:sample.altitude
										animationDuration:animationDuration];
	
	
	
	//Update TAWs altitude
    [self.meMapViewController updateTawsAltitude:sample.altitude];
}

@end
