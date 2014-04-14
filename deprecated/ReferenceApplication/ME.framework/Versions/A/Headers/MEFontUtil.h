//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#include <QuartzCore/QuartzCore.h>

/**Utility class for using fonts.*/
@interface MEFontUtil : NSObject

/**
 Generates a UIImage with a transparent background with the specified string
 rendered using the specified font.
 */
+ (UIImage *) newImageWithFont:(NSString*) fontName
                   fontSize:(float) fontSize
                  fillColor:(UIColor*) fillColor
                strokeColor:(UIColor*) strokeColor
                strokeWidth:(float) strokeWidth
                       text:(NSString*) text;

/**
 Generates a UIImage with a transparent background with the specified string
 rendered using the specified font. Creates an outlne for the font using
 a multipass rendering technique.
 */
+ (UIImage *) newImageWithFontOutlined:(NSString*) fontName
                   fontSize:(float) fontSize
                  fillColor:(UIColor*) fillColor
                strokeColor:(UIColor*) strokeColor
                strokeWidth:(float) strokeWidth
                       text:(NSString*) text;


@end
