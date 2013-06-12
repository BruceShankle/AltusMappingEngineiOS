//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MELineStyle.h"

/**Describes an animated vector circle that can be added to an MEMapViewController to highlight the location of vehicles or landmarks.*/
@interface MEAnimatedVectorCircle : NSObject

/**Unique name of the animated vector circle. This should not conflict with any map names as internally a vector map will be created based on this name.*/
@property (copy) NSString* name;

/**Initial location of the animated vector circle.*/
@property (assign) CLLocationCoordinate2D location;

/**The layering order relevant to other map and marker layers.*/
@property (assign) int zOrder;

/**Style with which to draw circle's path.*/
@property (retain) MELineStyle* lineStyle;

/**The starting radius of the circle in screen points.*/
@property (assign) CGFloat minRadius;

/**The ending radius of the circle in screen points.*/
@property (assign) CGFloat maxRadius;

/**The duration of the animation cycle.*/
@property (assign) CGFloat animationDuration;

/**The delay before the animation repeats.*/
@property (assign) CGFloat repeatDelay;

/**The delay that occurs before the circle fades.*/
@property (assign) CGFloat fadeDelay;

/**If set to true, the circle will fade (alpha 1->0) linearly to invisible over the course of the animation.*/
@property (assign) BOOL fade;

/**The number of segments that make up the circle. The default is 36 (10 degrees per segment).*/
@property (assign) unsigned int segmentCount;

/**If set to YES, the circle radius is treated as nautical miles on the sphere. Otherwise, the radius is converted to screen-space. In screen space, the radius will be consistent across all zoom levels, in world space, the radius will 'stick' to a geographic distance. The default is NO.*/
@property (assign) bool useWorldSpace;

@end
