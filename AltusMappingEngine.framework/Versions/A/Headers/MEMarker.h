//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

/**Specifies how marker rotations are rendered by the engine.*/
typedef enum {
	kMarkerRotationScreenEdgeAligned,
	kMarkerRotationTrueNorthAligned
} MEMarkerRotationType;

/**Represents a marker object.*/
@interface MEMarker : NSObject

/**The row id of the marker from the sqlite database if it was loaded from a clustered marker map database produced by Altus tools.*/
@property (assign) unsigned int uid;

/**Contains meta data provided when the marker was generated. NOTE: internally, metaData and uniqueName are stored in the same string. Each property is present because this object is overloaded for clustered and dynamic marker maps.*/
@property (retain) NSString* metaData;

/**For markers added to dynamic marker maps, set this to a unique name. NOTE: internally, metaData and uniqueName are stored in the same string. Each property is present because this object is overloaded for clustered and dynamic marker maps.*/
@property (retain) NSString* uniqueName;

/**Weight of the marker. If a height color bar is applied for the dynamic marker map, this weight is treated as the parameter (altutide) for computing the color.*/
@property (assign) double weight;

/**Rotation of the marker in degrees.*/
@property (assign) double rotation;

/**Specifies how the engine will render rotation of the marker. The default is kMarkerRotationScreenEdgeAligned.*/
@property (assign) MEMarkerRotationType rotationType;

/**Geographic location of the marker.*/
@property (assign) CLLocationCoordinate2D location;

/**The name of a previously cached image to use for the marker. If this is set, the uiImage property is ignored.*/
@property (retain) NSString* cachedImageName;

/**The image point that acts as the center of rotation and geographic anchor.*/
@property (assign) CGPoint anchorPoint;

/**Amount to offset marker from projected location on screen (in points) from anchorPoint.*/
@property (assign) CGPoint offset;

/**
 Minimum level the marker should appear. Defaults to 0. Set to higher if you want the marker to only appear at higher zoom levels.
 */
@property (nonatomic, assign) unsigned int minimumLevel;

/**Dimensions of the hit-test box for the marker in points. When set to anything other than width=0, height=0 (the default), this property overrides the normal hitTesting logic for the marker which is based on the anchor point and size of the marker image. This property should only be set when the marker image size is small enough that targeting it with a finger-tap would be difficult due to it being too small. When set, this size is automatically scaled to physical coordinates to take into account retina displays. The hit testing logic considers a box of this size around the anchor point of the marker.*/
@property (assign) CGSize hitTestSize;

/**When a marker texture is drawn, the default sampling of it's texture is bilinear. For some markers, for example those with text that you wish to be as crisp as possible on-screen, this can appear less readable when a marker image pixel falls between screen pixels. Setting this to YES will force nearest-neighbor sampling of the texture. The down-side, is that when the marker is being animated or panned around the map it's image may appear to 'snap' to pixel alignment.*/
@property (assign) BOOL nearestNeighborTextureSampling;

/**UIImage that represents the marker. You should set this property if you do not set a cachedImageName.*/
@property (retain) UIImage* uiImage;

/**Whether or not to convert the provided uiImage to RGB565 or RGBA4444 2-byte format. This cuts texture memory size in half compared to 4-byte per pixel formats.*/
@property (assign) BOOL compressTexture;

/**Set to false to hide a marker.*/
@property (assign) BOOL isVisible;
@end
