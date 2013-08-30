//
//  RouteRubberBandingTest.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/29/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../METest.h"
#import "RouteMarkerViewController.h"
#include "../TerrainProfileTests/TerrainProfileView.h"

@interface RouteRubberBandingTest : METest <MEDynamicMarkerMapDelegate>
@property (retain) NSString* markerMapName;
@property (retain) UILongPressGestureRecognizer *longPress;
@property (retain) MELineStyle* fillStyle;
@property (retain) RouteMarkerViewController* routeMarkerViewController;
@property (assign) CGPoint JFK;
@property (assign) CGPoint SFO;
@property (assign) CGPoint HOU;
@property (assign) CGPoint MIA;
@property (assign) CGPoint RDU;
@property (retain) IBOutlet UILabel* lblDistance;
@property (retain) NSMutableArray* routePoints;
@end

@interface TerrainProfileTest : RouteRubberBandingTest
@property (retain) IBOutlet UILabel* lblDistance;
@property (assign) CGPoint markerAnchorPoint;
@property (retain) TerrainProfileView* terrainProfileView;
@property (retain) NSMutableArray* terrainMaps;
@end