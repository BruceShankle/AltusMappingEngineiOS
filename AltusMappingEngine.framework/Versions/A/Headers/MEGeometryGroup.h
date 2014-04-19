//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>

/**Base class for ME geometry objects.*/
@interface MEGeometryObject : NSObject
@property (assign) unsigned int featureId;
@end

/**Represents a point.*/
@interface MEGeometryPoint : NSObject
+(MEGeometryPoint*) x:(double)x y:(double) y;
@property (assign) double x;
@property (assign) double y;
- (id) initWithX:(double) x Y:(double) y;
@end

/**Represents a line.*/
@interface MELine: MEGeometryObject
/**An array of MEGeometryPoints.*/
@property (retain) NSMutableArray* points;
/**Add a point. x = Longitude, y=Latitude.*/
-(void) addPoint:(double) x y:(double) y;
@end

/**Represents a polygon.*/
@interface MEPolygon : MEGeometryObject
/**An array of MEGeometryPoints.*/
@property (retain) NSMutableArray* shell;
/**An array of arrays containing MEGeometryPoints.*/
@property (retain) NSMutableArray* holes;
/**Add a point. x = Longitude, y=Latitude.*/
-(void) addPoint:(double) x y:(double) y;
/**Close the polygon.*/
-(void) close;
@end

/**Represents a set of triangles.*/
@interface METriangleSet : MEGeometryObject
/**An array of MEGeometryPoints (in sets of 3 please).*/
@property (retain) NSMutableArray* coords;
@end

/**Represents a geoup of geometry.*/
@interface MEGeometryGroup : NSObject
/**An array of MEPolygon objects.*/
@property (retain) NSMutableArray* polygons;
/**An array of MELine objects.*/
@property (retain) NSMutableArray* lines;
/**An array of METriangleSet objects.*/
@property (retain) NSMutableArray* triangleSets;
@end
