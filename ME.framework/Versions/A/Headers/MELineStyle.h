//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**Describes the style of a line.*/
@interface MELineStyle : NSObject

/**Color to stroke object with.*/
@property (retain) UIColor* strokeColor;

/**Width in pixels of stroke.*/
@property (assign) CGFloat strokeWidth;

/**Color to outline stroke object with.*/
@property (retain) UIColor* outlineColor;

/**Width in pixels of outline on each side of the line.*/
@property (assign) CGFloat outlineWidth;

/**Initialize with stroke color and stroke width.*/
- (id) initWithStrokeColor:(UIColor*) sColor
               strokeWidth:(CGFloat) sWidth;
@end
