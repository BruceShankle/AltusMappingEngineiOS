//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

/**Specifies how marker rotations are rendered by the engine.*/
typedef enum {
	kMarkerRotationScreenEdgeAligned,
	kMarkerRotationTrueNorthAligned
} MEMarkerRotationType;

/**
 Describes information about a marker. The engine will create and provide an instance of this object to a marker map's MEMarkerMapDelegate for each marker that needs to be displayed.
 */
@interface MEMarkerInfo : NSObject

/**Contains meta data provided when the marker was generated.*/
@property (nonatomic, copy) NSString* metaData;

/**The row id of the marker from the sqlite database.*/
@property (readonly, assign) unsigned int uid;

/**Weight of the marker.*/
@property (nonatomic, readonly) double weight;

/**Rotation of the marker in degrees.*/
@property (nonatomic, assign) double rotation;

/**Specifies how the engine will render rotation of the marker. The default is kMarkerRotationScreenEdgeAligned.*/
@property (nonatomic, assign) MEMarkerRotationType rotationType;

/**Geographic location of the marker.*/
@property (nonatomic, readonly) CLLocationCoordinate2D location;

/**UIImage that represents the marker. You should set this property when the mapping engine makes a request to the marker delegate to update the marker info.*/
@property (nonatomic, retain) UIImage* uiImage;

/**Point that represents which pixel on the marker should be placed on the
 geographic coordinate the marker represents. You should set this property when the mapping engine makes a request to the marker delegate to update the marker info.*/
@property (nonatomic, assign) CGPoint anchorPoint;

/**Create an MEMarkerInfo object.*/
- (id) initWidthUid:(unsigned int) uid
		   metaData:(NSString*) metaData
			 weight:(double) weight
		   location:(CLLocationCoordinate2D) location;

@end
