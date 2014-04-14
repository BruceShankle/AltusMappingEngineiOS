//
//  ViewController.h
//  MyMap
//
//  Created by Bruce Shankle III on 11/24/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ME/ME.h>
#import <CoreLocation/CoreLocation.h>
#import "InternetMaps/MEInternetMaps.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, MEMarkerMapDelegate>

//Properties
@property (retain) CLLocationManager* locationManager;
@property (retain) MEMapViewController* meMapViewController;
@property (retain) MEMapView* meMapView;
@property (assign) BOOL isTrackupMode;
@property (assign) BOOL isGPSMode;
@property (assign) BOOL isStreetMapMode;
@property (assign) BOOL isAerialMapMode;

//UI properties
@property (retain) IBOutlet UIButton* btnGPS;
@property (retain) IBOutlet UIButton* btnTrackUp;
@property (retain) IBOutlet UIButton* btnStreetMap;
@property (retain) IBOutlet UIButton* btnAerialMap;

//Internet maps
@property (retain) MEMapBoxLandCoverStreetMap* streetMap;
@property (retain) MEMapQuestAerialMap* aerialMap;

//Methods
- (void) gpsButtonTapped;
- (void) trackUpButtonTapped;
- (void) streetMapButtonTapped;
- (void) aerialMapButtonTapped;

@end
