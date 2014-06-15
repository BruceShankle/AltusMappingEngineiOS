//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <QuartzCore/QuartzCore.h>

/**
 Utility class for working with images.
 */
@interface MEImageUtil : NSObject

+ (CGContextRef) createBitmapContextSuitableForView:(UIView*) uiView;

/**Creates a context of the specified dimensions that is compatible with the rendering engine.*/
+ (CGContextRef) createContext:(CGSize) size
                         scale:(float) scale
                      flippedY:(BOOL) flippedY;

/**Creates a context that is power-of-two.*/
+ (CGContextRef) createContextPow2:(CGSize) size
							 scale:(float) scale
						  flippedY:(BOOL) flippedY
						   newSize:(CGSize*) newSize;

/**Destroys a context created by MEImageUtil*/
+ (void) destroyContext:(CGContextRef) context;

/**Converts a context into a UIImage.*/
+ (UIImage *) createImageFromContext:(CGContextRef) context;

/**Converts a UIView into a UIImage.*/
+ (UIImage *) createImageFromView:(UIView*) uiView;

/**Gets RGBA bitmap data from a UIImage, optionally flipping the Y.*/
+ (void *) bitmapFromImage:(UIImage *)image
                            fippedY:(BOOL) flippedY;

+ (void *) bitmapFromSingleChannelImage:(UIImage*)image flippedY:(BOOL) flippedY;

/**Gets a power-of-two RGBA bitmap from a UIImage. optionally flipping the Y.*/
+ (void *) bitmapFromImagePow2:(UIImage *) image
					  flippedY:(BOOL) flippedY
					   newSize:(CGSize*) newSize;

/**Returns true if device is retina-based.*/
+ (BOOL)isRetina;

/**Returns a UIColor for r g b a bytes.*/
+ (UIColor*) makeColor:(int) r g:(int) g b:(int) b a:(int) a;

@end
