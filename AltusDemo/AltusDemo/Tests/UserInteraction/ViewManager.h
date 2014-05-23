//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <AltusMappingEngine/AltusMappingEngine.h>

//Helper class for keeping track of multiple map views
@interface ViewManager : NSObject
+(NSString*) registerView:(MEMapView*) meMapView;
+(void) unregisterView:(MEMapView*) meMapView;
+(int) getViewCount;
+(MEMapView*) getControllingView;
+(void) setControllingView:(MEMapView*) meMapView;
@end
