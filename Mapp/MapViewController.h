//
//  MapViewController.h
//  Mapp
//
//  Created by Edwin B Shankle III on 10/5/11.
//  Copyright 2011 BA3, LLC. All rights reserved.
//

//Apple Frameworks
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MapSelectorTableViewController.h"
#import "Protocols.h"
#import "METests/METestManager.h"
#import "Mapmanager/MapManager.h"

//BA3 Mapping engine
#import <ME/ME.h>

@interface MapViewController : UIViewController <ModalViewPresenter, CLLocationManagerDelegate, GLKViewControllerDelegate, MEMapViewDelegate, MEMarkerMapDelegate>
{
	NSTimer* _playbackTimer;
	double _currentLongitude;
	NSMutableArray* _playbackData;
	int _currentPlaybackIndex;
	BOOL _showingAirports;
	BOOL _showingAirspaces;
	NSTimer* _dataLoadTimer;
	MEGeographicBounds* _lastBounds;
}
@property (nonatomic, retain) MapManager* mapManager;
@property (nonatomic, retain) METestManager* meTestManager;
@property (nonatomic, retain) IBOutlet MEMapViewController* meMapViewController;
@property (nonatomic, retain) IBOutlet MEMapView* meMapView;
@property (nonatomic, retain) MapSelectorTableViewController *mapSelectorTableViewController;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isTrackingLocation;
@property (nonatomic, assign) BOOL isNoDisplayListMode;
@property (nonatomic, assign) BOOL isPlayMode;
@property (nonatomic, assign) BOOL isTrackUpMode;
@property (nonatomic, assign) BOOL isStressRunning;
@property (nonatomic, assign) CGFloat currentHeading;
@property (nonatomic, assign) BOOL didAnimationFinish;
@property (nonatomic, assign) BOOL loadLowestDetailFirst;
@property (nonatomic, assign) BOOL appIsStarted;
//Buttons
@property (nonatomic, retain) IBOutlet UIBarButtonItem* btnMaps;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* btnTests;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* btnPlay;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* btnTrackUp;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* btnLocationTracking;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* btnDownloads;
@property (nonatomic, retain) IBOutlet UIButton* btnFeedback;

//Labels
@property (nonatomic, retain) IBOutlet UILabel* lblDebugInfo;
@property (nonatomic, retain) IBOutlet UILabel* lblCopyrightNotice;

//Images
@property (nonatomic, retain) IBOutlet UIImageView* imgBluePlane;
@property (nonatomic, retain) NSMutableArray* downloadedMapsNames;

//Events
- (void) didClickMaps:(id)sender;
- (void) didClickTests:(id)sender;
- (void) didClickPlay:(id)sender;
- (void) didClickTrackUp:(id)sender;
- (void) didClickDownloads:(id)sender;
- (void) didClickLocationTracking:(id)sender;
- (IBAction) didClickProvideFeedback:(id)sender;


//Functions
- (void) initialize;
- (void) initializeMappingEngine;
- (void) shutdownMappingEngine;
- (void) enableLocationSystem:(bool) enabled;

//Support for recorded flight playback
- (void) nextFlightPlaybackSample;
- (void) loadRecordedFlightFromCSVFile:(NSString*) filePath;

//Support for location services
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading;

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error;

- (void) animateImageViewAlpha:(UIImageView*) image toNewAlpha:(CGFloat) newAlpha overTime:(CGFloat) time;
- (void) animateImageViewRotation:(UIImageView*) image toNewRotation:(CGFloat) rotation overTime:(CGFloat) time;
- (void) rotateImageView:(UIImageView*) image toNewRotation:(CGFloat) rotation;


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;



@end
