//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma  once
#import <Foundation/Foundation.h>
#import "../METest.h"
#import "../METestCategory.h"
#import "../METestManager.h"
#import "../Maps/Vector/Virtual/VectorGrid.h"

@interface VectorObject : NSObject
@property (assign) float longitude;
@property (assign) float latitude;
@property (assign) float course;
@property (assign) float rotation;
@property (assign) float rotationDelta;
@property (assign) float speed;
@property (retain) NSMutableArray* radialPoints;
@property (retain) MELineStyle* lineStyle;
@property (retain) MEPolygonStyle* polygonStyle;

-(void) update;
-(void) drawLines:(MEMapViewController*) meMapViewController
          mapName:(NSString*) mapName;

-(void) drawPolygon:(MEMapViewController*) meMapViewController
            mapName:(NSString*) mapName
        withTexture:(NSString*) textureName;

@end

/////////////////////////////////////////////////////////////
@interface Asteroid : VectorObject
@end

/////////////////////////////////////////////////////////////
@interface Ship : VectorObject
-(void) updateShip:(NSArray*) asteroids;
@property (retain) Asteroid* nearestThreat;
@end


/////////////////////////////////////////////////////////////
@interface Asteroids : METest <MEMarkerMapDelegate>
@property (retain) VectorGrid* vectorGrid;
@property (retain) NSMutableArray* asteroids;
@property (retain) Ship* ship;
+(NSString*) drawStyle;
+(NSString*) cameraStyle;
@end

@interface AsteroidCount : METest
@end

@interface AsteroidsRenderingMode : METest
@end

@interface AsteroidsCameraMode : METest
@end
