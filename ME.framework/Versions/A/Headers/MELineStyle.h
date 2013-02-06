//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MELineStyle : NSObject

/**Color to stroke object with.*/
@property (atomic, retain) UIColor* strokeColor;

/**Width in pixels of stroke.*/
@property (nonatomic, assign) CGFloat strokeWidth;

/**Color to outline stroke object with.*/
@property (atomic, retain) UIColor* outlineColor;

/**Width in pixels of outline on each side of the line.*/
@property (nonatomic, assign) CGFloat outlineWidth;

/**Initialize with stroke color and stroke width.*/
- (id) initWithStrokeColor:(UIColor*) sColor
               strokeWidth:(CGFloat) sWidth;
@end
