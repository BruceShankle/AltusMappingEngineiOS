//  Copyright (c) 2014 BA3, LLC. All rights reserved.
//Demonstrates how to programatically create a marker image
//that that is derived from a dynamically created view with sub-views.
//Feel free to use this code or portions of it as you wish your applications.
#import <Foundation/Foundation.h>
@interface WayPointMarkerImage : NSObject
+ (UIImage*) createCustomMarkerImage: (NSString*) labelText
                         anchorPoint: (CGPoint*) anchorPoint;
@end
