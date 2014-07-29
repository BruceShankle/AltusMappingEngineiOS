//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import "../METest.h"
#import "../METestCategory.h"
#import "../METestManager.h"
#import "../Utilities/MovingObject2D.h"

////////////////////////////////////////////////////////////////////////
/**Demonstrates adding a single animate circle with the default style.*/
@interface AnimatedVectorCircle : METest
@end

////////////////////////////////////////////////////////////////////////
/**Use an animated vector circle to track an object.*/
@interface AnimatedVectorCircleTrackObject : METest
@property (retain) MovingObject2D* movingObject;
@property (retain) NSString* markerMapName;
@end

////////////////////////////////////////////////////////////////////////
/**Use an animated vector circle to track an object and place
 range rings around the object as well.*/
@interface AnimatedVectorCircleTrackObjectRangeRings : AnimatedVectorCircleTrackObject
@property (retain) NSString* rangeRingName;
@end
