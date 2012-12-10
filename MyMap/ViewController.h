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

@interface ViewController : UIViewController <CLLocationManagerDelegate>

//Properties
@property (retain) CLLocationManager* locationManager;
@property (retain) MEMapViewController* meMapViewController;
@property (retain) MEMapView* meMapView;
@end
