//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"
#import "../METestMovingObject.h"

/**
 Demonstrates how to add line segments to a vector map in a way that they smoothely animate onto the map.
 */
@interface AnimatedLine : METest <MEDynamicMarkerMapDelegate>
@property (retain) METestMovingObject* redPlane;
@property (retain) METestMovingObject* bluePlane;
@property (retain) METestMovingObject* yellowPlane;
@property (retain) NSMutableArray* redPath;
@property (retain) NSMutableArray* bluePath;
@property (retain) NSMutableArray* yellowPath;

@property (retain) MELineStyle* blueLineStyle;
@property (retain) MELineStyle* redLineStyle;
@property (retain) MELineStyle* yellowLineStyle;
@property (retain) NSString* vehicleMarkerMapName;
@property (retain) NSString* wayPointMarkerMapName;
@property (retain) NSString* clipMarkerMapName;
@property (retain) METimer* meTimer;
@property (assign) CLLocationCoordinate2D currentLocation;
@property (assign) CGPoint markerAnchorPoint;
@property (assign) BOOL accumulate;
@end

@interface AnimatedLineAccumulate : AnimatedLine
@end
