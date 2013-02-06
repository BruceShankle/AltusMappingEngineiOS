//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MELineStyle.h"

/**Polygon style object.*/
@interface MEPolygonStyle : MELineStyle

/**Color to fill object with.*/
@property (atomic, retain) UIColor* fillColor;

/**Init with stroke color, stroke width, and fill color.*/
- (id) initWithStrokeColor:(UIColor*) color
               strokeWidth:(CGFloat) width
                 fillColor:(UIColor*) fcolor;

/**Inits with the specified fill color, clear stroke color and stroke width of 1.*/
- (id) initWithFillColor:(UIColor*) fColor;

@end
