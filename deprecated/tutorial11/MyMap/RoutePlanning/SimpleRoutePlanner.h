//
//  SimpleRoutePlanner.h
//  MyMap
//
//  Created by Bruce Shankle III on 2/5/13.
//  Copyright (c) 2013 BA3, LLC. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <ME/ME.h>

/** A simple route planning system.*/
@interface SimpleRoutePlanner : NSObject <MEVectorMapDelegate, MEDynamicMarkerMapDelegate>

//Properties
@property (retain) MEMapViewController* meMapViewController;
@property (retain) NSString* vectorLayerName;
@property (retain) NSString* markerLayerName;
@property (retain) NSMutableArray* routePoints;
@property (retain) MELineStyle* lineStyle;
@property (assign) CGPoint routeMarkerAnchorPoint;

//Functions
-(void) enable;
-(void) disable;
-(void) clearRoute;
-(void) addWayPoint:(CLLocationCoordinate2D) wayPoint;

@end
