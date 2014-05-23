//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MELineStyle.h"

/**Polygon style object.*/
@interface MEPolygonStyle : MELineStyle

/**Color to fill object with.*/
@property (atomic, retain) UIColor* fillColor;

/**Texture to use to fill the polygon.*/
@property (atomic, retain) NSString* textureName;

/**Color for drop shadow.*/
@property (atomic, retain) UIColor* shadowColor;

/**The x/y point offset of the drop shadow. The default is (2,-2)*/
@property (atomic, assign) CGPoint shadowOffset;

/**Init with stroke color, stroke width, and fill color.*/
- (id) initWithStrokeColor:(UIColor*) color
               strokeWidth:(CGFloat) width
                 fillColor:(UIColor*) fcolor;

/**Init with stroke color, stroke width, and texture.*/
- (id) initWithStrokeColor:(UIColor*) color
               strokeWidth:(CGFloat) width
               textureName:(NSString*) textureName;

/**Inits with the specified fill color, clear stroke color and stroke width of 1.*/
- (id) initWithFillColor:(UIColor*) fColor;

@end
