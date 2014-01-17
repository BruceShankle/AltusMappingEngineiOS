//  Copyright (c) 2013 BA3, LLC. All rights reserved.

#import "TerrainExplorerUI.h"

@interface TerrainExplorerUI ()

@end

@implementation ExplorerPoint
@end

@implementation TerrainExplorerUI

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


///////////////////////////////////////////////////////////////////////////////////////
//Marker map handling
- (void) addMarkerMap{
	MEDynamicMarkerMapInfo* markerMapInfo = [[[MEDynamicMarkerMapInfo alloc]init]autorelease];
	markerMapInfo.name = self.markerMapName;
	markerMapInfo.meDynamicMarkerMapDelegate = self;
	markerMapInfo.meMapViewController = self.meMapViewController;
	markerMapInfo.zOrder = 100;
	markerMapInfo.hitTestingEnabled = NO;
	[self.meMapViewController addMapUsingMapInfo:markerMapInfo];
	self.markers = [[[NSMutableArray alloc]init]autorelease];
	
	UIImage* markerImage = [UIImage imageNamed:@"blueCircleSolid"];
	
	self.markerAnchorPoint = CGPointMake(markerImage.size.width/2.0,
										 markerImage.size.height/2.0);
	
	[self.meMapViewController addCachedMarkerImage:markerImage
										  withName:@"blueCircleSolid"
								   compressTexture:NO
					nearestNeighborTextureSampling:NO];
	
}

- (void) addMarker:(CLLocationCoordinate2D) location{
	//Store new marker
	MEDynamicMarker* newMarker = [[[MEDynamicMarker alloc]init]autorelease];
	newMarker.cachedImageName = @"blueCircleSolid";
	newMarker.location = location;
	newMarker.rotation = 0;
	newMarker.rotationType = kMarkerRotationScreenEdgeAligned;
	newMarker.anchorPoint = self.markerAnchorPoint;
	newMarker.name = [NSString stringWithFormat:@"%d", self.markers.count];
	[self.markers addObject:newMarker];
	
	//Display new marker
	[self.meMapViewController addDynamicMarkerToMap:self.markerMapName
									  dynamicMarker:newMarker];
	
	//Redraw route
	[self updateRouteLine];
	
	[self updateUIState];
}

- (void) mapView:(MEMapView *)mapView singleTapAt:(CGPoint) screenPoint withLocationCoordinate:(CLLocationCoordinate2D) locationCoordinate{
	
	if(self.isPlaying){
		return;
	}
	
	[self addMarker:locationCoordinate];
}

- (void) removeMarkerMap{
	[self.meMapViewController removeMap:self.markerMapName clearCache:YES];
}

///////////////////////////////////////////////////////////////////////////////////////
//Vectpr map handling

- (void) addVectorMap{
	MEVectorMapInfo* vectorMapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
	vectorMapInfo.name = self.routeLineMapName;
	vectorMapInfo.zOrder = 99;
	vectorMapInfo.meVectorMapDelegate = self;
	vectorMapInfo.meMapViewController = self.meMapViewController;
	[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
	
	//Set vector tesselation threshold
	//[self.meMapViewController setTesselationThresholdForMap:self.routeLineMapName
	//										  withThreshold:40];
	
	//Set the alpha
    [self.meMapViewController setMapAlpha:self.routeLineMapName
									alpha:0.6];
	
	//Create route line style
	self.routeLineStyle = [[[MELineStyle alloc]init]autorelease];
	self.routeLineStyle.strokeColor = [UIColor blueColor];
	self.routeLineStyle.outlineColor = [UIColor blackColor];
	self.routeLineStyle.outlineWidth = 1;
	self.routeLineStyle.strokeWidth = 5;
	
}

- (double) lineSegmentHitTestPixelBufferDistance{
	return 10;
}

- (double) vertexHitTestPixelBufferDistance{
	return 10;
}

- (NSMutableArray*) getRoutePoints{
	NSMutableArray* points = [[[NSMutableArray alloc] init] autorelease];
	for(MEMarker* marker in self.markers){
		[points addObject:[NSValue valueWithCGPoint:CGPointMake(marker.location.longitude,
																marker.location.latitude)]];
	}
	return points;
}

- (void) updateRouteLine{
	[self.meMapViewController clearDynamicGeometryFromMap:self.routeLineMapName];
	if(self.markers.count<=1){
		return;
	}
	[self.meMapViewController addDynamicLineToVectorMap:self.routeLineMapName
												 lineId:@"foo"
												 points:[self getRoutePoints]
												  style:self.routeLineStyle];
}

- (void) removeVectorMap{
	[self.meMapViewController removeMap:self.routeLineMapName clearCache:YES];
}


///////////////////////////////////////////////////////////////////////////////////////
//Timer management
- (void) startTimer{
	self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval
												  target:self selector:@selector(timerTick)
												userInfo:nil
												 repeats:YES];
	NSRunLoop *runloop = [NSRunLoop currentRunLoop];
	[runloop addTimer:self.timer forMode:NSRunLoopCommonModes];
	[runloop addTimer:self.timer forMode:UITrackingRunLoopMode];
}

- (void) stopTimer{
	if(self.timer!=nil){
        [self.timer invalidate];
		self.timer = nil;
    }
}

- (void) initTrackUpMode {
	[self.meMapViewController setRenderMode:METrackUp];
}

- (void) showRoute:(BOOL) isVisible{
	[self.meMapViewController setMapIsVisible:self.markerMapName isVisible:isVisible];
	[self.meMapViewController setMapIsVisible:self.routeLineMapName isVisible:isVisible];
}

- (void) init3DMode {
	
	//Hide route
	[self showRoute:NO];
	
	//Disable tile level biasing
	self.meMapViewController.meMapView.tileLevelBias = 0;
	
	//Go into 3D mode.
	[self.meMapViewController setRenderMode:MERender3D];
	
	//Look down
    [self.meMapViewController.meMapView setCameraOrientation:0
														roll:0
													   pitch:-90
										   animationDuration:0];
    
    //Look towards horizon
	[self.meMapViewController.meMapView setCameraOrientation:0
														roll:0
													   pitch:-40
										   animationDuration:0.4];
}

- (void) initializeCamera {
	
	switch (self.scModeSelect.selectedSegmentIndex) {
		case 0:
			return;
			break;
		case 1:
			[self initTrackUpMode];
			break;
		case 2:
			[self init3DMode];
			break;
		default:
			break;
	}
}

- (void) resetCamera {
	
	//Leave trackup mode
	[self.meMapViewController unsetRenderMode:METrackUp];
	
	//Leave 3D mode
	[self.meMapViewController setRenderMode:MERender2D];
	
	//Re-enable tile level biasing
	self.meMapViewController.meMapView.tileLevelBias = 1.0;
	
	//Place camera at reasonable altitude
	if(self.scAltitudeSelect.selectedSegmentIndex==0){
		[self.meMapViewController.meMapView setCameraAltitude:200000
											animationDuration:0.5];
	}
	
	//Look down
	[self.meMapViewController.meMapView setCameraOrientation:0
														roll:0
													   pitch:-90
										   animationDuration:0];
	
	//Show route
	[self showRoute:YES];
	
}

- (void) startPlayBack{
	
	if(self.isPlaying){
		return;
	}
	self.isPlaying = YES;
	
	//Fade out maps
	[self.meMapViewController setMapAlpha:self.routeLineMapName alpha:0.1];
	[self.meMapViewController setMapAlpha:self.markerMapName alpha:0.1];
	
	//Update UI
	[self updateUIState];
	
	//Reset route index
	self.routeIndex = 0;
	
	//Set camera
	[self initializeCamera];
	
	//Queue playback
	[self queueNewPlayback];
}

- (void) stopPlayback{
	if(!self.isPlaying){
		return;
	}
	
	//Stop timer
	[self stopTimer];
	self.isPlaying = NO;
	
	//Fade in maps
	[self.meMapViewController setMapAlpha:self.routeLineMapName alpha:1.0];
	[self.meMapViewController setMapAlpha:self.markerMapName alpha:1.0];
	
	//Update UI
	[self updateUIState];
	
	//Reset camera
	[self resetCamera];
}

- (void) queueNewPlayback{
	
	__block NSArray* heightSamples;
	
	//Ask mapping engine for terrain height on another thread
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		//Get height samples along the route
		heightSamples =
		[METerrainProfiler getTerrainProfile:self.terrainMaps
										  wayPoints:[self getRoutePoints]
								   samplePointCount:100
									   bufferRadius:0];
		
		//Retain for main thread access.
		[heightSamples retain];
		
		//Back on the main thread begin playback by starting timer.
		dispatch_async(dispatch_get_main_queue(), ^{
			
			//Generate a new set of points to play back
			[self generateExplorerPoints];
			
			//Set altitude of each explorer point based on the cooresponding height sample
			for(int i=0; i<self.explorerPoints.count; i++){
				ExplorerPoint* point = [self.explorerPoints objectAtIndex:i];
				MEHeightSample* heightSample = [heightSamples objectAtIndex:i];
				point.altitude = heightSample.height;
				//NSLog(@"Point %d is at height %d", i, height.shortValue);
			}
			
			//Releas the height samples
			[heightSamples release];
			
			//Star the timer
			[self startTimer];
		});
		
	});
}


- (void) generateExplorerPoints{
	
	//Reset out points
	self.explorerPoints = [[[NSMutableArray alloc]init]autorelease];
	
	//Convert the way points into something we can play into the camera
	//Tesselate the route
	NSArray* tesselatedPoints = [MEMath tesselateRoute:[self getRoutePoints] pointCount:100];
	
	
	for(int i=0; i<tesselatedPoints.count-1; i++){
		//Get current tesselated route point
		NSValue* vCurr = [tesselatedPoints objectAtIndex:i];
		CGPoint pCurr = [vCurr CGPointValue];
		
		//Get next tesselated route point
		NSValue* vNext = [tesselatedPoints objectAtIndex:i+1];
		CGPoint pNext = [vNext CGPointValue];
		
		//Create an explorer point that is the current location and heading to the next point
		ExplorerPoint* newPoint = [[[ExplorerPoint alloc]init]autorelease];
		newPoint.location = CLLocationCoordinate2DMake(pCurr.y, pCurr.x);
		newPoint.heading = [MEMath courseFromPoint:pCurr toPoint:pNext];
		newPoint.altitude = 100000;
		
		//Save point
		[self.explorerPoints addObject:newPoint];
	}
}

- (void) moveCamera:(ExplorerPoint*) newPoint animationDuration:(double) animationDuration{
	
	
	[self.meMapViewController.meMapView setCenterCoordinate:newPoint.location
										  animationDuration:animationDuration];
	[self.meMapViewController.meMapView setCameraOrientation:newPoint.heading
														roll:newPoint.roll
													   pitch:newPoint.pitch
										   animationDuration:animationDuration];
	
	
	//Set camera altitude?
	if(self.scAltitudeSelect.selectedSegmentIndex==0){
		[self.meMapViewController.meMapView setCameraAltitude:newPoint.altitude+self.sliderAGL.value
											animationDuration:animationDuration];
	}
	
}

- (void) timerTick {
	
	
	double duration = self.animationDuration;
	
	//Reset camera?
	if(self.routeIndex>=self.explorerPoints.count){
		//Reset camera to start
		self.routeIndex = 0;
		duration = 0;
	}
	
	//Get point
	ExplorerPoint* newPoint = [self.explorerPoints objectAtIndex:self.routeIndex];
	
	//Move camera
	[self moveCamera:newPoint animationDuration:duration];
	
	//Increment route index
	self.routeIndex++;
}

- (void) removeAllMarkers{
	
	//Remove all the markers from the map
	for(MEDynamicMarker* marker in self.markers){
		[self.meMapViewController removeDynamicMarkerFromMap:self.markerMapName
												  markerName:marker.name];
	}
	
	//Clear out our array
	[self.markers removeAllObjects];
	
	//Update the route
	[self updateRouteLine];
	
}

///////////////////////////////////////////////////////////////////////////////////////
//UI Handlers
- (IBAction)removeLastTapped:(id)sender {
	if(self.markers.count<=0){
		return;
	}
	MEDynamicMarker* lastMarker = [self.markers objectAtIndex:self.markers.count-1];
	[self.meMapViewController removeDynamicMarkerFromMap:self.markerMapName markerName:lastMarker.name];
	[self.markers removeObjectAtIndex:self.markers.count-1];
	[self updateRouteLine];
}

- (IBAction)playTapped:(id)sender {
	[self startPlayBack];
}

- (IBAction)stopTapped:(id)sender {
	[self stopPlayback];
}


- (IBAction)removeAllTapped:(id)sender {
	
	[self removeAllMarkers];
	
	//Update the UI
	[self updateUIState];
}

- (IBAction)scAltitudeSelectChanged:(id)sender {
	[self updateUIState];
}

- (IBAction)sliderAGLChanged:(id)sender {
	[self updateUIState];
}

- (IBAction)saveTapped:(id)sender {
	[self saveRoute];
}

- (void) updateUIState{
	
	//Toggle stuff
	self.btnPlay.enabled = !self.isPlaying;
	self.btnRemoveLast.enabled = !self.isPlaying;
	self.btnStop.enabled = self.isPlaying;
	self.scModeSelect.enabled = !self.isPlaying;
	self.scAltitudeSelect.enabled = !self.isPlaying;
	self.btnRemoveAll.enabled = !self.isPlaying;
	self.btnSave.enabled = !self.isPlaying;
	
	//Not enough points to play?
	if(self.markers.count<2){
		self.btnPlay.enabled = NO;
	}
	
	//Not enough points to delete last?
	if(self.markers.count==0){
		self.btnRemoveLast.enabled = NO;
	}
	
	//Not enough points to remove all?
	if(self.markers.count==0){
		self.btnRemoveAll.enabled = NO;
	}
	
	//Enable AGL slider?
	self.sliderAGL.enabled = (self.scAltitudeSelect.selectedSegmentIndex==0);
	
	//Update AGL label?
	if(self.sliderAGL.enabled){
		self.lblAGL.alpha = 1.0;
		self.lblAGL.text = [NSString stringWithFormat:@"%0.0fm AGL",
							self.sliderAGL.value];
	}
	else{
		self.lblAGL.alpha = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////////////
//Persistence
- (void) saveRoute{
	NSString* filePath = [[DirectoryInfo sharedDirectoryInfo] GetDocumentFilePath:self.routeFileName];
	NSLog(@"Saving %@", filePath);
	int pointCount = self.markers.count;
	FILE* outfile = fopen(filePath.UTF8String, "wb");
	if(!outfile){
		NSLog(@"Could not open route file for writing.");
		return;
	}
	fwrite(&pointCount, sizeof(int), 1, outfile);
	for(MEDynamicMarker* marker in self.markers){
		double lon = marker.location.longitude;
		double lat = marker.location.latitude;
		fwrite(&lon, sizeof(double), 1, outfile);
		fwrite(&lat, sizeof(double), 1, outfile);
	}
	fclose(outfile);
}

- (void) loadRoute{
	[self removeAllMarkers];
	NSString* filePath = [[DirectoryInfo sharedDirectoryInfo] GetDocumentFilePath:self.routeFileName];
	NSLog(@"Loading %@", filePath);
	FILE* infile = fopen(filePath.UTF8String, "rb");
	if(!infile){
		NSLog(@"Could not open route file for reading.");
		return;
	}
	int pointCount;
	fread(&pointCount, sizeof(int), 1, infile);
	for(int i=0; i<pointCount; i++){
		double lon;
		double lat;
		fread(&lon, sizeof(double), 1, infile);
		fread(&lat, sizeof(double), 1, infile);
		[self addMarker:CLLocationCoordinate2DMake(lat, lon)];
	}
	fclose(infile);
	
	//Have camera look at route endpoints
	if(pointCount>=2){
		MEDynamicMarker* start = [self.markers objectAtIndex:0];
		MEDynamicMarker* end = [self.markers objectAtIndex:pointCount-1];
		[self.meMapViewController.meMapView lookAtCoordinate:start.location
											   andCoordinate:end.location
										withHorizontalBuffer:75
										  withVerticalBuffer:75
										   animationDuration:0.5];
	}
	
}

///////////////////////////////////////////////////////////////////////////////////////
//Main tasks
- (void) start{
	self.scModeSelect.selectedSegmentIndex=0;
	self.scAltitudeSelect.selectedSegmentIndex=0;
	self.isPlaying = NO;
	self.markerMapName = @"TerrainExplorerMarkers";
	self.routeLineMapName = @"TerrainExplorerRoute";
	self.routeFileName = @"myroute.dat";
	self.interval = 1.0;
	self.animationDuration = 1.0;
	[self addMarkerMap];
	[self addVectorMap];
	[self updateUIState];
	[self loadRoute];
}

- (void) stop{
	[self stopPlayback];
	[self removeMarkerMap];
	[self removeVectorMap];
}

- (void)dealloc {
	[_btnPlay release];
	[_btnRemoveLast release];
	[_btnStop release];
	[_scModeSelect release];
	[_scAltitudeSelect release];
	[_btnRemoveAll release];
	[_btnSave release];
	[_sliderAGL release];
	[_lblAGL release];
	[super dealloc];
}
- (void)viewDidUnload {
	[self setBtnPlay:nil];
	[self setBtnRemoveLast:nil];
	[self setBtnStop:nil];
	[self setScModeSelect:nil];
	[self setScAltitudeSelect:nil];
	[self setBtnRemoveAll:nil];
	[self setBtnSave:nil];
	[self setSliderAGL:nil];
	[self setLblAGL:nil];
	[super viewDidUnload];
}


@end
