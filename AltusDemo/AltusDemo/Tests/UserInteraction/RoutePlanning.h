//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "../METest.h"
#import "../METestCategory.h"

#import <Foundation/Foundation.h>

@interface RoutePlanning : METest <MEDynamicMarkerMapDelegate>
/**Contains an array of NSValues that wrap CGPoints for waypoints along the route.*/
@property (retain) NSMutableArray* wayPoints;
/**Style for drawing vector lines on the map.*/
@property (retain) MELineStyle* vectorLineStyle;
@property (retain) NSString* markerMapName;
@end
