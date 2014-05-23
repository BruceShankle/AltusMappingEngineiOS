//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "AnimatedVectorCircle.h"
#import "../METestConsts.h"

////////////////////////////////////////////////////////////////////////
@implementation AnimatedVectorCircle
- (id) init{
	if(self==[super init]){
		self.name = @"Animated Circle - Simple";
	}
	return self;
}

- (void) addCircle{
    MEAnimatedVectorCircle* haloPulse = [[MEAnimatedVectorCircle alloc]init];
    haloPulse.name = self.name;
    haloPulse.location = RDU_COORD;
    [self.meMapViewController addAnimatedVectorCircle:haloPulse];
}

- (void) removeCircle{
    [self.meMapViewController removeAnimatedVectorCircle:self.name];
}

- (void) start{
	if(self.isRunning){
		return;
	}
    [self addCircle];
    [self lookAtUnitedStates];
	self.isRunning = YES;
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
    [self removeCircle];
	self.isRunning = NO;
}
@end

////////////////////////////////////////////////////////////////////////
@implementation AnimatedVectorCircleTrackObject
- (id) init{
	if(self==[super init]){
		self.name = @"Animated Circle - Track Object";
        self.markerMapName = @"markers";
        self.movingObject = [[MovingObject2D alloc]init];
        self.movingObject.speed = [METest randomFloat:300000 max:500000];
        self.interval = 1.0;
	}
	return self;
}

- (void) addLayers{
    
    //Add halo pulse
    MEAnimatedVectorCircle* haloPulse = [[MEAnimatedVectorCircle alloc]init];
    haloPulse.name = self.name;
    haloPulse.location = self.movingObject.location;
    haloPulse.zOrder = 100;
    [self.meMapViewController addAnimatedVectorCircle:haloPulse];
    
    //Add dynamic marker layer
    MEDynamicMarkerMapInfo* mapInfo = [[MEDynamicMarkerMapInfo alloc]init];
    mapInfo.name = self.markerMapName;
    mapInfo.zOrder = 101;
    [self.meMapViewController addMapUsingMapInfo:mapInfo];
    
    //Add marker to map
    UIImage* shuttleImage = [UIImage imageNamed:@"shuttle"];
    CGPoint anchorPoint = CGPointMake(shuttleImage.size.width / 2,
                                      shuttleImage.size.height / 2);
    
    [self.meMapViewController addCachedMarkerImage:shuttleImage
                                          withName:@"shuttle"
                                   compressTexture:NO
                    nearestNeighborTextureSampling:NO];
    
    MEMarker* marker = [[MEMarker alloc]init];
    marker.uniqueName = @"shuttle";
    marker.cachedImageName = @"shuttle";
    marker.anchorPoint = anchorPoint;
    marker.location = self.movingObject.location;
    marker.rotation = self.movingObject.heading;
    marker.rotationType = kMarkerRotationTrueNorthAligned;
    
    [self.meMapViewController addDynamicMarkerToMap:self.markerMapName dynamicMarker:marker];
    
    //Position camera to new location
    [self.meMapViewController.meMapView setCenterCoordinate:haloPulse.location];
}

- (void) removeLayers{
    [self.meMapViewController removeAnimatedVectorCircle:self.name];
    [self.meMapViewController removeMap:self.markerMapName clearCache:YES];
}

- (void) timerTick{
    //Update the moving object
    [self.movingObject update:self.elapsedTime];
    
    //Update animate circle location
    [self.meMapViewController updateAnimatedVectorCircleLocation:self.name
                                                     newLocation:self.movingObject.location
                                               animationDuration:self.elapsedTime];
    
    //Update marker location and rotation
    [self.meMapViewController updateDynamicMarkerLocation:self.markerMapName
                                               markerName:@"shuttle"
                                                 location:self.movingObject.location
                                        animationDuration:self.elapsedTime];
    
    [self.meMapViewController updateDynamicMarkerRotation:self.markerMapName
                                               markerName:@"shuttle"
                                                 rotation:self.movingObject.course
                                        animationDuration:self.elapsedTime];
    
    //Update camera
    [self.meMapViewController.meMapView setCenterCoordinate:self.movingObject.location
                                          animationDuration:self.elapsedTime];

}

- (void) start{
	if(self.isRunning){
		return;
	}
    
    [self addLayers];
    [self startTimer];
	self.isRunning = YES;
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
    [self stopTimer];
    [self removeLayers];
	self.isRunning = NO;
}
@end

////////////////////////////////////////////////////////////////////////
@implementation AnimatedVectorCircleTrackObjectRangeRings
- (id) init{
	if(self==[super init]){
		self.name = @"Animated Circle - Range Rings";
        self.rangeRingName = @"Range Ring";
	}
	return self;
}

-(void) addRangeRing:(int) distance{
    NSString* labelText = [NSString stringWithFormat:@"%d", distance];
    NSString* name=[NSString stringWithFormat:@"rangeRing_%d", distance];
    
    //Add range ring
    MEAnimatedVectorCircle* rangeRing = [[MEAnimatedVectorCircle alloc]init];
    rangeRing.useWorldSpace = YES;
    rangeRing.minRadius = distance;
    rangeRing.maxRadius = distance;
    rangeRing.segmentCount = 72;
    rangeRing.lineStyle.strokeColor = [UIColor whiteColor];
    rangeRing.lineStyle.outlineColor = [UIColor blackColor];
    rangeRing.name = name;
    rangeRing.location = self.movingObject.location;
    rangeRing.zOrder = 99;
    [self.meMapViewController addAnimatedVectorCircle:rangeRing];
    
    //Add a label for the range ring
    //1. Create a label image
    UIImage* labelImage = [MEFontUtil newImageWithFontOutlined:@"Helvetica-Bold"
                                                      fontSize:20
                                                     fillColor:[UIColor whiteColor]
                                                   strokeColor:[UIColor blackColor]
                                                   strokeWidth:0
                                                          text:labelText];
    
    //2. Cache the image
    [self.meMapViewController addCachedMarkerImage:labelImage
                                          withName:name
                                   compressTexture:NO
                    nearestNeighborTextureSampling:NO];
    
    //3. Compute its anchor point
    CGPoint anchorPoint = CGPointMake(labelImage.size.width / 2,
                                      labelImage.size.height / 2);
    
    //4. Compute the label's location (i.e. on the range ring)
    CGPoint location = [MEMath pointOnRadial:CGPointMake(self.movingObject.longitude,
                                                         self.movingObject.latitude)
                                      radial:45
                                    distance:distance];
    
    //5. Add a dynamic marker using the cached image, location, and anchor point
    MEMarker* rangeRingLabel = [[MEMarker alloc]init];
    rangeRingLabel.uniqueName=name;
    rangeRingLabel.cachedImageName=name;
    rangeRingLabel.location=CLLocationCoordinate2DMake(location.y, location.x);
    rangeRingLabel.anchorPoint = anchorPoint;
    [self.meMapViewController addDynamicMarkerToMap:self.markerMapName
                                      dynamicMarker:rangeRingLabel];
    
}

-(void) updateRangeRing:(int) distance{
    NSString* name=[NSString stringWithFormat:@"rangeRing_%d", distance];
    
    //Update range ring position
    [self.meMapViewController updateAnimatedVectorCircleLocation:name
                                                     newLocation:self.movingObject.location
                                               animationDuration:self.elapsedTime];
    
    
    
    //Updat range ring label location
    CGPoint newPoint = [MEMath pointOnRadial:CGPointMake(self.movingObject.longitude,
                                                         self.movingObject.latitude)
                                      radial:45
                                    distance:distance];
    CLLocationCoordinate2D newLocation = CLLocationCoordinate2DMake(newPoint.y, newPoint.x);
    
    //Update the location
    [self.meMapViewController updateDynamicMarkerLocation:self.markerMapName
                                               markerName:name
                                                 location:newLocation
                                        animationDuration:self.elapsedTime];
}

-(void) addLayers{
    [super addLayers];
    [self addRangeRing:500];
    [self addRangeRing:1000];
    [self addRangeRing:1500];
}

-(void) removeLayers{
    [super removeLayers];
    [self.meMapViewController removeAnimatedVectorCircle:self.rangeRingName];
}


-(void) timerTick{
    [super timerTick];
    [self updateRangeRing:500];
    [self updateRangeRing:1000];
    [self updateRangeRing:1500];
}

@end
