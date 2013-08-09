//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MEPolygonStyle.h"
#import "MEAnimatedVectorReticleStyles.h"

/**Describes an animated reticle of 4 triangles that can be used to highlight a point on a map.*/
@interface MEAnimatedVectorReticle : NSObject

/**Unique name of the animated vector circle. This should not conflict with any map names as internally a vector map will be created based on this name.*/
@property (copy) NSString* name;

/**Initial location of the animated vector circle.*/
@property (assign) CLLocationCoordinate2D location;

/**The layering order relevant to other map and marker layers.*/
@property (assign) int zOrder;

/**Style with which the center circle of the reticle.*/
@property (retain) MEPolygonStyle* circleStyle;

/**Style with to draw the animating arrows of the reticle.*/
@property (retain) MEPolygonStyle* arrowStyle;

/**The radius of the inner circle in screen points.*/
@property (assign) CGFloat circleRadius;

/**The in screen points from the center of the circle that reticle triangles animate (or bounce).*/
@property (assign) CGFloat bounceRadius;

/**The pixel height of the triangle component of the reticle.*/
@property (assign) CGFloat arrowSize;

/**The decay rate of the bounce frequency. Defaults to 1.5.*/
@property (assign) CGFloat bounceFrequencyDecay;

/**The decay rate of the bounce magnitude. Defaults to 1.0.*/
@property (assign) CGFloat bounceMagnitudeDecay;

/**The duration of the animation cycle.*/
@property (assign) CGFloat animationDuration;

/**The delay before repeating the animation.*/
@property (assign) CGFloat repeatDelay;

/**Style with which to create the reticle's geometry. Defaults to kAnimatedVectorReticleInwardPointingWithCircle.*/
@property (assign) MEAnimatedVectorReticleStyle style;

@end
