//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#pragma once

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

/**
 Used to add an array of markers to an MEMarkerMapInfo object.
 */
@interface MEMarkerAnnotation : NSObject

/**
 Center latitude and longitude of the annotion.
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/**
 Indicates the relative importance of the annotation compared to others. Higher is more important lower is less important.
 */
@property (nonatomic, assign) double weight;

/**
 Minimum level the marker should appear. Defaults to 0. Set to higher if you want the marker to only appear at higher zoom levels.
 */
@property (nonatomic, assign) unsigned int minimumLevel;

/**
 A piece of identifiable informaton you supply that the engine will supply back to you when it requests a marker image.
 */
@property (nonatomic, copy) NSString* metaData;

/**Initial rotation of the marker.*/
@property (nonatomic, assign) double rotation;
@end