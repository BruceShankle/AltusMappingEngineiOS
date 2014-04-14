//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MEVectorGeometryHit : NSObject

@property (retain) NSString* mapName;
@property (retain) NSString* shapeId;
@property (assign) CLLocationCoordinate2D location;

@end

@interface MEVertexHit : MEVectorGeometryHit
@property (assign) unsigned int vertexIndex;
@end

@interface MELineSegmentHit : MEVectorGeometryHit
@property (assign) unsigned int startPointIndex;
@property (assign) unsigned	int endPointIndex;
@end