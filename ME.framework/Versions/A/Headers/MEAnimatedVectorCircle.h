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

/**Style with which the draw the outline of the circle's path.*/
@property (retain) MELineStyle* outlineStyle;

/**Style with which to draw the interior line of the circle's path. Generally this should have have a lesser stroke width than the outlineStyle stroke width.*/
@property (retain) MELineStyle* lineStyle;

/**The starting radius of the circle in screen points.*/
@property (assign) CGFloat minRadius;

/**The ending radius of the circle in screen points.*/
@property (assign) CGFloat maxRadius;

/**The duration of the animation cycle.*/
@property (assign) CGFloat animationDuration;

/**The delay before the animation repeats.*/
@property (assign) CGFloat repeatDelay;

/**If set to true, the circle will fade (alpha 1->0) linearly to invisible over the course of the animation.*/
@property (assign) BOOL fade;

@end
