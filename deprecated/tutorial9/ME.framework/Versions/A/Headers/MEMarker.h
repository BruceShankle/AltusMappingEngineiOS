//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**Represents a marker object.*/
@interface MEMarker : NSObject
@property (assign) unsigned int uid;
@property (retain) NSString* metaData;
@property (assign) CLLocationCoordinate2D location;
@property (assign) double weight;
@end
