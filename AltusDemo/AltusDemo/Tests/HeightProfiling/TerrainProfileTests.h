//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "TerrainProfileView.h"
#import "../METest.h"

@interface TerrainProfileHelper : NSObject 
+(void) showTowers:(METestManager*) testManager;
+(void) hideTowers:(METestManager*) testManager;
@end

/**Demonstrates basic usage of terrain profile API.*/
@interface TerrainProfileBasicTest : METest <MEDynamicMarkerMapDelegate, MEVectorMapDelegate>

/**View that will display a basic terrain profile graph.*/
@property (retain) TerrainProfileView* terrainProfileView;

/**Style for drawing vector lines on the map.*/
@property (retain) MELineStyle* vectorLineStyle;

/**Style for drawing bounds of route.*/
@property (retain) MEPolygonStyle* polygonStyle;

/**Contains an array of NSValues that wrap CGPoints for waypoints along the route.*/
@property (retain) NSMutableArray* wayPoints;

/**Contains an array of MEMapFileInfo objects, one for each terrain map on the device.*/
@property (retain) NSMutableArray* terrainMaps;

/**Will contain an array of MEMarker objects that lie along the route.*/
@property (retain) NSArray* markersAlongRoute;

@property (assign) int routeViewHorizontalBuffer;
@property (assign) int routeViewVerticalBuffer;
@property (assign) CGFloat lookAtRouteAnimationDuration;

@property (retain) NSString* obstacleDatabasePath;
@property (assign) double bufferRadius;
@property (assign) bool drawTerrainProfile;
@property (assign) CGFloat terrainProfileViewHeight;
@property (assign) CGFloat maxHeightInFeet;
@property (retain) NSString* boundingGraphicsMapName;
/**Functions.*/
- (void) createWayPoints;
- (void) addTerrainProfileView;
- (void) removeTerrainProfileView;
- (void) addVectorMap;
- (void) removeVectorMap;
- (void) updateTerrainProfile;
- (void) terrainProfileUpdated;
- (void) addBoundingGraphics;
- (void) updateBoundingGraphics;
@end

@interface FF254205 : TerrainProfileBasicTest
@end

@interface TerrainProfileDeathValley : TerrainProfileBasicTest
@end

@interface TerrainProfileVeryClose : TerrainProfileBasicTest
@end

@interface TerrainProfileHighToLow : TerrainProfileBasicTest
@end

@interface TerrainProfileLowToHigh : TerrainProfileBasicTest
@end

@interface TerrainProfileAntiMeridian : TerrainProfileBasicTest
@end

@interface TerrainProfileMtRanier : TerrainProfileBasicTest
@end

@interface TerrainProfileMtRanierAcuteA : TerrainProfileBasicTest
@end

@interface TerrainProfileMtRanierAcuteB : TerrainProfileBasicTest
@end

@interface TerrainProfileMtRanierObtuseA : TerrainProfileBasicTest
@end

@interface TerrainProfileMtRanierObtuseB : TerrainProfileBasicTest
@end

@interface TerrainProfileMtRanierSpiral : TerrainProfileBasicTest
@end

@interface TerrainProfileMtRanierZigZag : TerrainProfileBasicTest
@end

@interface TerrainProfileArctic : TerrainProfileBasicTest
@end

@interface TerrainProfileGrandCanyon : TerrainProfileBasicTest
@end

@interface TerrainProfileGrandCanyonVeryShort : TerrainProfileBasicTest
@end

@interface TerrainProfileAtlanticOcean : TerrainProfileBasicTest
@end

@interface TerrainProfileEastBoundFlight : TerrainProfileBasicTest
@property (assign) double currLongitude;
@end

@interface TerrainProfileMtRanierScan : TerrainProfileBasicTest
@property (assign) double wLongitude;
@property (assign) double eLongitude;
@property (assign) double currLatitude;
@end

@interface TerrainProfileSeattleScan : TerrainProfileMtRanierScan
@end

@interface ShowObstacles: METest <MEDynamicMarkerMapDelegate>
@property (assign) CLLocationCoordinate2D currentLocation;
@property (assign) double heading;
@property (assign) double radius;
@property (assign) double distancePerCycle;
@property (retain) NSArray* lastMarkerSet;
@property (retain) NSString* boundingGraphicsMapName;
@property (retain) MEMarker* highestMarker;
- (void) updateLocation;
- (NSArray*) getMarkers:(CLLocationCoordinate2D) location;
- (void) addBoundingGraphics;
- (void) removeBoundingGraphics;
- (void) updateBoundingGraphics;
- (void) updateCamera;

@end

@interface ShowObstacles2 : ShowObstacles
@end

@interface ShowObstacles3 : ShowObstacles
@end

@interface ShowObstacles4 : ShowObstacles <MEVectorMapDelegate>
@property (assign) CLLocationCoordinate2D swCorner;
@property (assign) CLLocationCoordinate2D neCorner;
@property (retain) MEPolygonStyle* polygonStyle;
@end

@interface ShowObstacles5 : ShowObstacles4
@end

@interface ShowObstacles6 : ShowObstacles4
@property (assign) double bufferRadius;
@property (retain) MELineStyle* lineStyle;
@end


@interface TerrainMinMaxInBounds : METest <MEMarkerMapDelegate, MEDynamicMarkerMapDelegate>
@property (retain) NSMutableArray* terrainMaps;
@property (retain) METest* vectorLines;
@property (retain) TerrainProfileView* terrainProfileView;
@property (assign) CGFloat terrainProfileViewHeight;
@end

@interface TerrainMinMaxAroundLocation : TerrainMinMaxInBounds
@end

@interface TerrainMinMaxInBounds2 : METest <MEDynamicMarkerMapDelegate, MEVectorMapDelegate>
@property (assign) CLLocationCoordinate2D swCorner;
@property (assign) CLLocationCoordinate2D neCorner;
@property (retain) MEPolygonStyle* polygonStyle;
@property (retain) NSString* boundingGraphicsMapName;
@property (retain) NSMutableArray* terrainMaps;
@property (retain) NSString* expectedHeights;
@property (retain) NSData* srtmData;
@end

@interface TerrainMinMaxInBounds3 : TerrainMinMaxInBounds2
@end

@interface TerrainMinMaxInBoundsA : TerrainMinMaxInBounds2
@end

@interface TerrainMinMaxInBoundsB : TerrainMinMaxInBounds2
@end

@interface TerrainMinMaxInBoundsC : TerrainMinMaxInBounds2
@end


