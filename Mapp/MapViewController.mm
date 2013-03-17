//
//  MapViewController.mm
//  Mapp
//
//  Created by Edwin B Shankle III on 10/5/11.
//  Copyright 2011 BA3, LLC. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import <ME/ME.h>

#import <vector>
#import <iostream>

#import "MapViewController.h"
#import "DownloadViewController.h"
#import "Libraries/ZipArchive/ZipArchive.h"

using namespace std;

@implementation MapViewController

//Properties
@synthesize loadLowestDetailFirst;
@synthesize meMapViewController;
@synthesize meMapView;
@synthesize mapSelectorTableViewController = __mapSelectorTableViewController;
@synthesize currentHeading;
@synthesize didAnimationFinish;
@synthesize appIsStarted;

//Buttons
@synthesize btnMaps;
@synthesize btnTests;
@synthesize btnPlay;
@synthesize btnTrackUp;
@synthesize btnLocationTracking;
@synthesize btnDownloads;
@synthesize btnFeedback;

//Other UI
@synthesize lblDebugInfo;
@synthesize lblCopyrightNotice;
@synthesize imgBluePlane;
@synthesize downloadedMapsNames;
@synthesize locationManager;
@synthesize isTrackingLocation;

//Booleans
@synthesize isNoDisplayListMode;
@synthesize isPlayMode;
@synthesize isTrackUpMode;

@synthesize isStressRunning;
@synthesize meTestManager;
@synthesize mapManager;

- (IBAction) didClickProvideFeedback:(id)sender
{
#ifdef TESTFLIGHT
	[TestFlight openFeedbackView];
#endif
}


-(void) unzipFile:(NSString*) zipFilePath destPath:(NSString*) destPath
{
	__block UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"Decompressing terrain data\nPlease Wait..."
										message:nil
									   delegate:self
							  cancelButtonTitle:nil
							  otherButtonTitles: nil];
	[alert show];
	
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	// Adjust the indicator so it is up a few pixels from the bottom of the alert
	indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
	[indicator startAnimating];
	[alert addSubview:indicator];
	[indicator release];
	
	dispatch_queue_t backgroundQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	__block NSString* blockZipFilePath = [zipFilePath copy];
	__block NSString* blockDestPath = [destPath copy];
	__block MapViewController* blockSelf = self;
	[blockZipFilePath retain];
	[blockDestPath retain];
	[blockSelf retain];
	dispatch_async(backgroundQ, ^{
		
		//Unzip on background thread
		ZipArchive *zipArchive = [[ZipArchive alloc] init];
		[zipArchive UnzipOpenFile:blockZipFilePath];
		[zipArchive UnzipFileTo:blockDestPath overWrite:YES];
		[zipArchive UnzipCloseFile];
		[zipArchive release];
		[blockZipFilePath release];
		[blockDestPath release];
		
		//Close dialog on main thread and clean up other resources
		dispatch_sync(dispatch_get_main_queue(), ^{
			[alert dismissWithClickedButtonIndex:0 animated:YES];
			[alert release];
			[blockSelf enableEarth];
			[blockSelf.mapManager refresh];
			[blockSelf release];
		});
	});
	
}

-(id) init
{
	self = [super init];
	if(self!=nil)
	{
		self.appIsStarted = NO;
		_playbackData=nil;
		self.isStressRunning = NO;
		self.mapManager = [[[MapManager alloc]init]autorelease];

	}
	return self;
}

-(void)dealloc {
    
    [__mapSelectorTableViewController release];
    __mapSelectorTableViewController = nil;
	
    
    self.locationManager = nil;
    self.meTestManager = nil;
	self.mapManager = nil;
	
	
    [super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated
{
	//Init non-mapping engine stuff
	if(!self.appIsStarted)
	{
		[self initialize];
	
		//Initialize mapping engine
		[self initializeMappingEngine];
		
		//Turn on earth
		[self enableEarth];
    
		//Initialize test
		[self initializeTests];
		
		self.appIsStarted = YES;
	}
	
	
	[self.view layoutSubviews];
	
	[super viewDidAppear:animated];
}

- (void) decompressBaseTerrain
{
	//Ensure that map directories and base maps are available
	//for ME map manager
	NSError *error;
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* mapsFolder=[MEMapObjectBase GetMapsPath];
	if([fileManager fileExistsAtPath:mapsFolder]==NO)
	{
		if (![[NSFileManager defaultManager] createDirectoryAtPath:mapsFolder
									   withIntermediateDirectories:YES
														attributes:nil
															 error:&error])
		{
			NSLog(@"Create directory error: %@", error);
			exit(1);
		}
	}
	
	NSString* earthMapFile=[MEMapObjectBase mapFileNameForCategory:@"BaseMaps" map:@"Earth"];
	if([fileManager fileExistsAtPath:earthMapFile]==NO)
	{
		NSString* baseMapsPath=[MEMapCategory GetCategoryPath:@"BaseMaps"];
		NSString *zipFilePath = [[NSBundle mainBundle] pathForResource:@"Earth" ofType:@"zip"];
		[self unzipFile:zipFilePath destPath:baseMapsPath];
	}
}

- (void) initializeTests
{
    //Create a test manager. This should be done after the engine is created and intialized.
    self.meTestManager = [[METestManager alloc]init];
	self.meTestManager.lblCopyrightNotice = self.lblCopyrightNotice;
    self.meTestManager.meMapViewController = self.meMapViewController;
    [self.meTestManager createAllTests];
	//[self.meTestManager backgroundCreateAllTests];
}

- (void) initialize
{
	[self decompressBaseTerrain];
	
	//If not linked with TestFlight hide TestFlight feedback button
#ifndef TESTFLIGHT
	//self.btnFeedback.hidden=YES;
	//self.imgHelpFeedback.hidden=YES;
#endif
    // Set up button actions
    [[self btnMaps] setTarget:self];
    [[self btnMaps] setAction:@selector(didClickMaps:)];
	
    [[self btnTests] setTarget:self];
    [[self btnTests] setAction:@selector(didClickTests:)];
    	
	[[self btnPlay] setTarget:self];
	[[self btnPlay] setAction:@selector(didClickPlay:)];
	
	[[self btnTrackUp] setTarget:self];
	[[self btnTrackUp] setAction:@selector(didClickTrackUp:)];
	
	[[self btnLocationTracking] setTarget:self];
	[[self btnLocationTracking] setAction:@selector(didClickLocationTracking:)];
    
    [[self btnDownloads] setTarget:self];
    [[self btnDownloads] setAction:@selector(didClickDownloads:)];
	
	[self.view bringSubviewToFront:self.btnFeedback];
}

//////////////////////////////////////////////////////////////////////////////

- (void) enableEarth
{
	//Turn on Earth map
	NSString* earthMapPath = [MEMapObjectBase mapPathForCategory:@"BaseMaps" mapName:@"Earth"];
	NSString* earthSqliteFile = [NSString stringWithFormat:@"%@.sqlite",
								 earthMapPath];
	NSString* earthDataFile = [NSString stringWithFormat:@"%@.map",
							   earthMapPath];
	
	[self.meMapViewController addMap:earthMapPath
				   mapSqliteFileName:earthSqliteFile
					 mapDataFileName:earthDataFile
					compressTextures:YES];
}

- (void) initializeMappingEngine
{
	self.meMapViewController.verboseMessagesEnabled = YES;
	
	//Setup 2D overlay
	//[self.meMapViewController createOverlayView];
	self.meMapViewController.delegate = self;
	
	//Set MapKit delegate of meMapView to self.
	self.meMapViewController.meMapView.meMapViewDelegate = self;
    
    //Allow zooming in very close
    self.meMapViewController.meMapView.minimumZoom=0.00003;
	
	//Add default tiles
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"grayGrid"]
									withName:@"grayGrid"
							 compressTexture:YES];
	
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"noData"]
									withName:@"noData"
							 compressTexture:YES];
	
	//Set maximum virtual tile parent search depth
	self.meMapViewController.maxVirtualMapParentSearchDepth = 5;
	
	//Set tile bias level
	self.meMapViewController.meMapView.tileLevelBias = 1.0;
	
}

- (void) shutdownMappingEngine
{
	[self.meMapViewController shutdown];
}


/////////////////////////////////////////////////////////
//MEMapViewDelegate functions
- (void) mapView:(MEMapView *)mapView singleTapAt:(CGPoint)screenPoint withLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate
{
    if( [self.meTestManager respondsToSelector:_cmd] )
    {
        [self.meTestManager mapView:mapView singleTapAt:screenPoint withLocationCoordinate:locationCoordinate];
    }
}

-(void) pinchBegan:(MEMapView *)mapView
{
	//NSLog(@"PinchBegan");
}

-(void) pinchEnded:(MEMapView *)mapView
{
	//NSLog(@"PinchEnded");
}

-(void) panBegan:(MEMapView *)mapView
{
	//NSLog(@"PanBegan");
}

-(void) panEnded:(MEMapView *)mapView
{
	//NSLog(@"PanEnded");
}


- (BOOL) gestureRecognizer : (UIGestureRecognizer *) gestureRecognizer shouldReceiveTouch : (UITouch *) touch
{
	return YES;
}

- (void) mapView:(MEMapView *)mapView willStartLoadingMap:(NSString*) mapName
{
    if( [self.meTestManager respondsToSelector:_cmd] )
    {
        [self.meTestManager mapView:mapView willStartLoadingMap:mapName];
    }
    
}

- (void) mapView:(MEMapView *)mapView didFinishLoadingMap:(NSString *)mapName
{
    if( [self.meTestManager respondsToSelector:_cmd] )
    {
        [self.meTestManager mapView:mapView didFinishLoadingMap:mapName];
    }
}

- (void) mapView:(MEMapView *)mapView animationFrameChangedOnMap:(NSString*) mapName withFrame:(int)frame
{
    //NSLog(@"Animation frame change, frame %d, %@", frame, mapName);
    
    if( [self.meTestManager respondsToSelector:_cmd] )
    {
        [self.meTestManager mapView:mapView animationFrameChangedOnMap:mapName withFrame:frame];
    }
}

/////////////////////////////////////////////////////////
- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	NSLog(@"Application received memory warning.");
	[self.meMapViewController applicationDidReceiveMemoryWarning:application];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	NSLog(@"Application will resign active.");
	[self.meMapViewController applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	NSLog(@"Application did enter background.");
	[self.meMapViewController applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	NSLog(@"Application will enter foreground.");
	[self.meMapViewController applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	NSLog(@"Application did become active.");
	[self.meMapViewController applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	NSLog(@"Application will terminate.");
	[self.meMapViewController applicationWillTerminate:application];
}


- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
#ifdef TESTFLIGHT
	self.lblDebugInfo.text=@"";
	return;
#else
	//Show debug info for internal / SDK builds
	CLLocationCoordinate2D currentLocation = self.meMapView.centerCoordinate;
    self.lblDebugInfo.text=[NSString stringWithFormat:
							@"FPS:%f\n"
							"DRC:%f\n"
							"RAMo:%d\n"
							"RAMc:%d\n"
							"TC:%d\n"
							"TIF:%d\n"
							"MTIF:%d\n"
							"QTotal:%d\n"
							"QSerialBg:%d\n"
							"QSerialLo:%d\n"
							"QSerialDef:%d\n"
							"QSerialHi:%d\n"
							"Center:%f, %f\n",
							meMapViewController.meInfo.frameRate,
							meMapViewController.meInfo.drawCallsPerFrame,
							meMapViewController.meInfo.appMemoryUsage,
                            meMapViewController.meInfo.tileCacheMemorySize,
							meMapViewController.meInfo.tileCacheTileCount,
                            meMapViewController.meInfo.inFlightTileCount,
							meMapViewController.meInfo.multiInFlightTileCount,
							meMapViewController.meInfo.totalWorkerCount,
							meMapViewController.meInfo.serialWorkerBackgroundCount,
							meMapViewController.meInfo.serialWorkerLowCount,
							meMapViewController.meInfo.serialWorkerDefaultCount,
							meMapViewController.meInfo.serialWorkerHighCount,
							currentLocation.longitude,
							currentLocation.latitude ];
#endif
	
}


- (void) didClickDownloads:(id)sender
{
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	self.downloadedMapsNames=nil;
	self.downloadedMapsNames=[[NSMutableArray alloc]init];
	
    DownloadViewController* downloadController=[[DownloadViewController alloc] initWithNibName:@"DownloadViewController" bundle:nil];
	downloadController.downloadedMapsNames=self.downloadedMapsNames;
	downloadController.meViewController1=self.meMapViewController;
	
	
    downloadController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    downloadController.modalPresentationStyle=UIModalPresentationFormSheet;
    downloadController.presenter=self;
	self.meMapViewController.paused = YES;
	
	
    [self presentModalViewController:downloadController animated:YES];
    [downloadController release];
}

- (void) didClickTests:(id)sender
{
    //Children classes for iPad and iPhone implement specific behavior here.
	//See MapViewController_iPad and MapViewController_iPhone
}

- (void) didClickTrackUp:(id)sender
{
	self.isTrackUpMode=!self.isTrackUpMode;
	if(self.isTrackUpMode)
	{
		[self.btnTrackUp setStyle:UIBarButtonItemStyleDone];
		[self.meMapViewController setRenderMode:METrackUp];
		[self animateImageViewRotation:imgBluePlane toNewRotation:0 overTime:0.25];
	}
	else
	{
		[self.btnTrackUp setStyle:UIBarButtonItemStyleBordered];
		[self.meMapViewController unsetRenderMode:METrackUp];
		[self animateImageViewRotation:imgBluePlane toNewRotation:self.currentHeading overTime:0.25];
	}
}

- (void) didClickPlay:(id)sender
{
	self.isPlayMode=!self.isPlayMode;
	if(self.isPlayMode)
	{
		//Enable trackup button
		[self.btnTrackUp setEnabled:YES];
		
		//Disable panning
		self.meMapView.panEnabled = NO;
		
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"MtRanierFlyby" ofType:@"csv"];
		[self loadRecordedFlightFromCSVFile:filePath];
		[self animateImageViewAlpha:self.imgBluePlane toNewAlpha:1.0 overTime:0.5];
		_currentPlaybackIndex=0;
		[self.btnPlay setStyle:UIBarButtonItemStyleDone];
		_currentLongitude=-124.0 - 46.0 / 60.0 - 18.1/3600.0;
		_playbackTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(nextFlightPlaybackSample) userInfo:nil repeats:YES];
		
		[[NSRunLoop mainRunLoop] addTimer:_playbackTimer forMode:NSRunLoopCommonModes];
		
	}
	else
	{
		//Disable panning
		self.meMapView.panEnabled = YES;
		
		//Turn off trackup mode
		[self.meMapViewController unsetRenderMode:METrackUp];
		[self.btnTrackUp setStyle:UIBarButtonItemStyleBordered];
		[self.btnTrackUp setEnabled:NO];
		self.isTrackUpMode=NO;
		
		[self animateImageViewAlpha:self.imgBluePlane toNewAlpha:0.0 overTime:0.5];
		[self.btnPlay setStyle:UIBarButtonItemStyleBordered];
		
		
		[_playbackTimer invalidate];
		if(_playbackData!=nil)
		{
			[_playbackData release];
			_playbackData=nil;
		}
	}
}

- (void) loadRecordedFlightFromCSVFile:(NSString*) filePath
{
	if(_playbackData!=nil)
	{
		[_playbackData release];
	}
	
	
	_playbackData = [[NSMutableArray alloc] init];
	NSString *flightData = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil ];
	NSScanner *scanner = [NSScanner scannerWithString:flightData];
	[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"\n, "]];
	NSString* timeStamp;
	double lon, lat, alt, hdg, roll, pitch;
	int count=0;
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
		
		[_playbackData addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithDouble:lon], @"lon",
								  [NSNumber numberWithDouble:lat], @"lat",
								  [NSNumber numberWithDouble:alt], @"alt",
								  [NSNumber numberWithDouble:hdg], @"hdg",
								  [NSNumber numberWithDouble:roll], @"roll",
								  [NSNumber numberWithDouble:pitch], @"pitch",
								  nil]];
		
		count++;
	}
}

- (void) nextFlightPlaybackSample
{
	//Reset playback index?
	if(_currentPlaybackIndex>=[_playbackData count])
	{
		_currentPlaybackIndex=0;
	}
	
	NSMutableDictionary *sample=[_playbackData objectAtIndex:_currentPlaybackIndex];
	NSNumber* lon=[sample objectForKey:@"lon"];
	NSNumber* lat=[sample objectForKey:@"lat"];
	NSNumber* alt=[sample objectForKey:@"alt"];
	NSNumber* hdg=[sample objectForKey:@"hdg"];
	NSNumber* roll=[sample objectForKey:@"roll"];
	NSNumber* pitch=[sample objectForKey:@"pitch"];
	
    // convert heading degrees to radians for little blue plane icon
    const double DEGREES_TO_RADIANS = M_PI / 180.0;
	self.currentHeading = hdg.doubleValue * DEGREES_TO_RADIANS;
	
	//Animate blue plan (only if not in track up mode)
	if(!self.isTrackUpMode)
	{
		[self animateImageViewRotation:imgBluePlane toNewRotation:self.currentHeading overTime:1];
	}
	
	//Set map view's 2D coordinate and orientation
	CLLocationCoordinate2D loc;
	loc.longitude = lon.floatValue;
	loc.latitude = lat.floatValue;
	[self.meMapView setCenterCoordinate:loc
					  animationDuration:1.0];
	[self.meMapView setCameraOrientation:hdg.floatValue
									roll:roll.floatValue
								   pitch:pitch.floatValue
					   animationDuration:1.0];
    [self.meMapViewController updateTawsAltitude:alt.floatValue];
	
	//Increment playback index.
	_currentPlaybackIndex++;
}

- (void) didClickLocationTracking:(id)sender
{
	[self enableLocationSystem:!self.isTrackingLocation];
}

- (void) animateImageViewAlpha:(UIImageView*) imageView toNewAlpha:(CGFloat) newAlpha overTime:(CGFloat) time
{
	[UIView beginAnimations:@"AnimateImageAlpha" context:nil];
	[UIView setAnimationDuration:time];
	imageView.alpha=newAlpha;
	[UIView commitAnimations];
}

- (void) rotateImageView:(UIImageView*) image toNewRotation:(CGFloat) rotation
{
	image.transform=CGAffineTransformMakeRotation(rotation);
}


- (void) animateImageViewRotation:(UIImageView*) image toNewRotation:(CGFloat) rotation overTime:(CGFloat) time
{
	//Create a smooth animation curve
	UIViewAnimationOptions easeType;
	if(self.didAnimationFinish)
		easeType=UIViewAnimationOptionCurveEaseInOut;
	else
		easeType=UIViewAnimationOptionCurveEaseOut;
	
	UIViewAnimationOptions options = easeType |
	UIViewAnimationOptionAllowUserInteraction |
	UIViewAnimationOptionBeginFromCurrentState |
	UIViewAnimationOptionOverrideInheritedCurve;
	
	
	self.didAnimationFinish=NO;
	__block MapViewController* blockSafeSelf = self;
	__block UIImageView* blockSafeImage = image;
	
	[UIView animateWithDuration:time
						  delay:0.0
						options:options
					 animations:^{[blockSafeSelf rotateImageView:blockSafeImage toNewRotation:rotation];}
					 completion:^(BOOL finished){ blockSafeSelf.didAnimationFinish=finished; }];
	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	[UIView setAnimationsEnabled:NO];
	return YES;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation
{
	if(!self.isTrackUpMode)
	{
		[self rotateImageView:imgBluePlane toNewRotation:self.currentHeading];
	}
	
	[super didRotateFromInterfaceOrientation: fromInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[self rotateImageView:imgBluePlane toNewRotation:0];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


- (void) enableLocationSystem:(bool) enabled
{
	if(enabled)
	{
		[self.locationManager startUpdatingLocation];
		[self.locationManager startUpdatingHeading];
		[self.btnLocationTracking setStyle:UIBarButtonItemStyleDone];
		self.isTrackingLocation=YES;
		[self rotateImageView:imgBluePlane toNewRotation:0];
		[self animateImageViewAlpha:self.imgBluePlane toNewAlpha:1.0 overTime:0.5];
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	}
	else
	{
		[self.locationManager stopUpdatingLocation];
		[self.locationManager stopUpdatingHeading];
		[self.btnLocationTracking setStyle:UIBarButtonItemStyleBordered];
		self.isTrackingLocation=NO;
		[self animateImageViewAlpha:self.imgBluePlane toNewAlpha:0.0 overTime:0.5];
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	}
	
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation;
{
	CLLocationDirection trueHeading=manager.heading.trueHeading;
	CLLocationDirection course=newLocation.course;
	
	//Rotate blue plane
	self.currentHeading=(course * 3.14159265358979) / 180;
	//[self rotateImageView:imgBluePlane toNewRotation:self.currentHeading];
	[self animateImageViewRotation:imgBluePlane toNewRotation:self.currentHeading overTime:1];
	
	
	//Set map view's 2D coordinate and orientation
	[self.meMapView setCenterCoordinate:newLocation.coordinate
					  animationDuration:1.0];
	
	//Just in case in 3D mode, set camera heading
	[self.meMapView setCameraOrientation:trueHeading
									roll:0
								   pitch:0
					   animationDuration:1.0];
	
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
	
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error;
{
	NSLog(@"Location error occured.");
	[self enableLocationSystem:NO];
}

- (void) didClickMaps:(id)sender
{
	if(__mapSelectorTableViewController!=nil)
		[__mapSelectorTableViewController release];
	__mapSelectorTableViewController = [[MapSelectorTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
	__mapSelectorTableViewController.meViewController=self.meMapViewController;
	__mapSelectorTableViewController.mapViewController = (MapViewController*)self;
    __mapSelectorTableViewController.meTestManager = self.meTestManager;
	__mapSelectorTableViewController.mapManager = self.mapManager;
	
}


//Modal views send a message here when they want to be destroyed
- (void)dismissModalViewController:(NSString *)viewControllerName {
	
	if([viewControllerName isEqualToString:@"DownloadViewController"])
	{
		//Enable the maps that were downloaded
		/*for(int i=0; i<self.downloadedMapsNames.count; i++)
		 {
		 [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:[self.downloadedMapsNames objectAtIndex:i]];
		 [[NSUserDefaults standardUserDefaults] synchronize];
		 }*/
		[self.downloadedMapsNames removeAllObjects];
		
		//Look for new downloaded maps
		[self.mapManager refresh];
		
		//Restart animation
		self.meMapViewController.paused = NO;
		
		if(!self.isTrackingLocation)
			[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	}
	
	//Dismiss modal view controller
	[self dismissModalViewControllerAnimated:YES];
	
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
		//Set up location management
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
		self.isTrackingLocation=NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(BOOL)isRetina
{
    return [MEImageUtil isRetina];
}


@end
