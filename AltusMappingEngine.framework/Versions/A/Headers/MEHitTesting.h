//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**Conveys the geometry (line or polygon) ther user has tapped on geometry in vector maps where hit testing is enabled.*/
@interface MEVectorGeometryHit : NSObject
/**The map name.*/
@property (retain) NSString* mapName;
/**The id of the geometry that was tapped.*/
@property (retain) NSString* shapeId;
/**The location of the tap.*/
@property (assign) CLLocationCoordinate2D location;
@end

/**Conveys the vertices nearest user taps when hit detection is trigered on a vector map where hit testing is enabled.*/
@interface MEVertexHit : MEVectorGeometryHit
/**The index of the vertex that nearest the tap.*/
@property (assign) unsigned int vertexIndex;
@end

/**Conveys start end end-indexes for line segments the user has tapped on a vector map where hit testing is enabled.*/
@interface MELineSegmentHit : MEVectorGeometryHit
/**The start index of the point of the line segment that was tapped.*/
@property (assign) unsigned int startPointIndex;
/**The end index of the point of the line segment that was tapped.*/
@property (assign) unsigned	int endPointIndex;
@end