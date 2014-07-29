//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "METestManager.h"
#import "Core/Core.h"
#import "Stress/Stress.h"
#import "Artistic/Artistic.h"
#import "Maps/Maps.h"
#import "Markers/Markers.h"
#import "Weather/Weather.h"
#import "Terrain/Terrain.h"
#import "UserInteraction/UserInteraction.h"
#import "HeightProfiling/HeightProfiling.h"
#import "VectorOverlay/VectorOverlay.h"
#import "AnimatedShapes/AnimatedShapes.h"
#import "Lines/Lines.h"
#import "Polygons/Polygons.h"

@implementation METestManager

- (id) initWithMEMapViewController:(MEMapViewController*) meMapViewController{
    
    if(self = [super init]){
        self.meMapViewController = meMapViewController;
        self.meTestCategories = [[NSMutableArray alloc]init];
        [self createAllTests];
    }
    return self;
    
}

- (void) startInitialTest{
    [self startTestInCategory:@"Terrain" withName:@"Earth"];
    [self startTestInCategory:@"Core" withName:@"Stats"];
}

- (void) stopBaseMapTests{
    [self stopCategory:@"Terrain"];
    [self stopCategory:@"Raster Maps"];
    [self stopCategory:@"Vector Maps"];
}

- (void) stopCategory:(NSString*) categoryName{
    METestCategory* category = [self categoryWithName:categoryName];
    if(category!=nil){
        [category stopAllTests];
    }
}

- (void) stopAllTests{
    for(METestCategory* category in self.meTestCategories){
        [category stopAllTests];
	}
}

- (void) addCategory:(METestCategory*) newCategory{
    newCategory.meMapViewController = self.meMapViewController;
    newCategory.meTestManager = self;
    [self.meTestCategories addObject:newCategory];
}

- (METestCategory*) categoryWithName:(NSString*) categoryName{
	for(METestCategory* category in self.meTestCategories){
		if([category.name isEqualToString:categoryName])
			return category;
	}
	return nil;
}

- (void) createAllTests{
    [self createCoreTests];
    [self createStressTests];
    [self createVectorOverlayTests];
    [self createHeightProfilingTests];
    [self createUserInteractionTests];
    [self createTerrainTests];
    [self createRasterMapTests];
    [self createVectorMapTests];
    [self createVirtualVectorMapTests];
    [self createMarkerTests];
    [self createDynamicMarkerTests];
    [self createWeatherTests];
    [self createWMSTests];
    [self createArtisticTests];
}

- (void) createCoreTests{
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Core";
    [self addCategory:testCategory];
    [testCategory addTestClass:[Stats class]];
    [testCategory addTestClass:[MapLoadingStats class]];
}

- (void) createStressTests{
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Stress";
    [self addCategory:testCategory];
    [testCategory addTestClass:[ContentLoading class]];
    [testCategory addTestClass:[ContentLoadingAdjustPriorities class]];
    [testCategory addTestClass:[ContentLoadingNoBiasDynFPSAdjustPriorities class]];
    [testCategory addTestClass:[ContentLoadingNoBias class]];
    [testCategory addTestClass:[ContentLoadingNoBiasDynFPS class]];
    [testCategory addTestClass:[ContentLoadingNoBiasDynFPSTIF class]];
}

- (void) createVectorOverlayTests{
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Vector Overlay";
    [self addCategory:testCategory];
    [testCategory addTestClass:[PolygonStyle class]];
    [testCategory addTestClass:[AnimatedVectorCircle class]];
    [testCategory addTestClass:[AnimatedVectorCircleTrackObject class]];
    [testCategory addTestClass:[AnimatedVectorCircleTrackObjectRangeRings class]];
    [testCategory addTestClass:[AnimatedLine class]];
    [testCategory addTestClass:[AnimatedLineAccumulate class]];
    [testCategory addTestClass:[DynamicLines class]];
    [testCategory addTestClass:[DynamicPolygons class]];
    [testCategory addTestClass:[NonDynamicPolygons class]];
    [testCategory addTestClass:[PolygonPerfSlow class]];
    [testCategory addTestClass:[PolygonPerfFast class]];
}

- (void) createHeightProfilingTests{
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Height Profiling";
    [self addCategory:testCategory];
    [testCategory addTestClass:[TerrainRadiusPerf class]];
    [testCategory addTestClass:[TerrainRadiusPerfCached class]];
    [testCategory addTestClass:[TerrainRadiusPerfCachedBigRadius class]];
    [testCategory addTestClass:[TerrainProfileVeryClose class]];
	[testCategory addTestClass:[TerrainInRadiusTest class]];
	[testCategory addTestClass:[TerrainMinMaxInBounds2 class]];
	[testCategory addTestClass:[TerrainMinMaxInBounds3 class]];
	[testCategory addTestClass:[TerrainMinMaxInBoundsA class]];
    [testCategory addTestClass:[TerrainMinMaxInBoundsB class]];
    [testCategory addTestClass:[TerrainMinMaxInBoundsC class]];
	[testCategory addTestClass:[TerrainProfileBasicTest class]];
	[testCategory addTestClass:[TerrainProfileHighToLow class]];
	[testCategory addTestClass:[TerrainProfileLowToHigh class]];
	[testCategory addTestClass:[TerrainProfileDeathValley class]];
	[testCategory addTestClass:[TerrainProfileAntiMeridian class]];
	[testCategory addTestClass:[TerrainProfileMtRanier class]];
    [testCategory addTestClass:[TerrainProfileMtRanierAcuteA class]];
    [testCategory addTestClass:[TerrainProfileMtRanierAcuteB class]];
    [testCategory addTestClass:[TerrainProfileMtRanierObtuseA class]];
    [testCategory addTestClass:[TerrainProfileMtRanierObtuseB class]];
	[testCategory addTestClass:[TerrainProfileMtRanierSpiral class]];
	[testCategory addTestClass:[TerrainProfileMtRanierZigZag class]];
	[testCategory addTestClass:[TerrainProfileArctic class]];
	[testCategory addTestClass:[TerrainProfileGrandCanyon class]];
    [testCategory addTestClass:[TerrainProfileGrandCanyonVeryShort class]];
	[testCategory addTestClass:[TerrainProfileAtlanticOcean class]];
	[testCategory addTestClass:[TerrainProfileEastBoundFlight class]];
	[testCategory addTestClass:[TerrainProfileMtRanierScan class]];
	[testCategory addTestClass:[TerrainProfileSeattleScan class]];
	[testCategory addTestClass:[ShowObstacles class]];
	[testCategory addTestClass:[ShowObstacles2 class]];
	[testCategory addTestClass:[ShowObstacles3 class]];
	[testCategory addTestClass:[ShowObstacles4 class]];
	[testCategory addTestClass:[ShowObstacles5 class]];
	[testCategory addTestClass:[ShowObstacles6 class]];
	[testCategory addTestClass:[TerrainMinMaxInBounds class]];
	[testCategory addTestClass:[TerrainMinMaxAroundLocation class]];
}

- (void) createUserInteractionTests{
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"User Interaction";
    [self addCategory:testCategory];
    [testCategory addTestClass:[MultiView class]];
    [testCategory addTestClass:[MultiViewControl class]];
    [testCategory addTestClass:[RoutePlanning class]];
    [testCategory addTestClass:[RoutePlotting class]];
}

- (void) createRasterMapTests{
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Raster Maps";
    [self addCategory:testCategory];
    [testCategory addTestClass:[MapQuestAerial class]];
    [testCategory addTestClass:[MapBoxSatellite class]];
    [testCategory addTestClass:[MapBoxStreets class]];
    [testCategory addTestClass:[MapBoxStreetsNoCache class]];
    [testCategory addTestClass:[MBTilesNative class]];
    [testCategory addTestClass:[BA3NativeAcadia class]];
    [testCategory addTestClass:[AltusRasterPackageNative class]];
    [testCategory addTestClass:[AltusRasterPackageCustom class]];
}

- (void) createWMSTests {
	METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"WMS Maps";
    [self addCategory:testCategory];
    [testCategory addTestClass:[NOAARadar class]];
	[testCategory addTestClass:[MEWMSNationalAtlas2008Election class]];
	[testCategory addTestClass:[MEWMSNationalAtlasStates class]];
	[testCategory addTestClass:[MEWMSNationalAtlasCitiesTowns class]];
	[testCategory addTestClass:[MEWMSNationalAtlasUrbanAreas class]];
	[testCategory addTestClass:[MEWMSNationalAtlasTreeCanopy class]];
	[testCategory addTestClass:[MEWMSNationalAtlasPorts class]];
	[testCategory addTestClass:[MEWMSNationalAtlasPrecipitation class]];
	[testCategory addTestClass:[MEWMSBlueMarbleTest class]];
	[testCategory addTestClass:[MEWMSDCTest class]];
	[testCategory addTestClass:[MEWMSSeattleTest class]];
	[testCategory addTestClass:[MEWMSOregonTest class]];
}


- (void) createVectorMapTests{
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Vector Maps";
    [self addCategory:testCategory];
    [testCategory addTestClass:[AltusVectorPackage class]];
    [testCategory addTestClass:[AltusVectorPackageBenchmark class]];
    [testCategory addTestClass:[WorldSimple class]];
    [testCategory addTestClass:[HoustonStreetsStyle1 class]];
    [testCategory addTestClass:[HoustonStreetsStyle2 class]];
    [testCategory addTestClass:[HoustonStreetsStyle3 class]];
    [testCategory addTestClass:[SimpleWorld class]];
    [testCategory addTestClass:[SimpleWorldBenchmarkBias class]];
    [testCategory addTestClass:[SimpleWorldBenchmarkNoBias class]];
    [testCategory addTestClass:[Polygons class]];
    
}

- (void) createVirtualVectorMapTests{
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Virtual Vector Maps";
    [self addCategory:testCategory];
    [testCategory addTestClass:[VectorGrid class]];
}

- (void) createMarkerTests{
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Markers";
    [self addCategory:testCategory];
    [testCategory addTestClass:[Places class]];
    [testCategory addTestClass:[PlacesAvenir class]];
    [testCategory addTestClass:[PlacesFancyLabels class]];
    [testCategory addTestClass:[CustomClustering class]];
    [testCategory addTestClass:[Towers class]];
    [testCategory addTestClass:[BusStopsMemoryCached class]];
    [testCategory addTestClass:[BusStopsMemoryAsync class]];
    [testCategory addTestClass:[BusStopsMemorySync class]];
}

- (void) createDynamicMarkerTests{
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Dynamic Markers";
    [self addCategory:testCategory];
    [testCategory addTestClass:[AirTrafficScenario class]];
}

- (void) createWeatherTests{
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Weather";
    [self addCategory:testCategory];
    [testCategory addTestClass:[WorldSamples class]];
    [testCategory addTestClass:[ColorMosaicTest class]];
    [testCategory addTestClass:[ColorMosaicTest2 class]];
    [testCategory addTestClass:[RadarTest class]];
}

- (void) createTerrainTests {
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Terrain";
    [self addCategory:testCategory];
	[testCategory addTestClass:[Earth class]];
    [testCategory addTestClass:[DynamicColorBar class]];
    [testCategory addTestClass:[AltusTerrainPackage class]];
}

- (void) createArtisticTests {
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Artistic";
    [self addCategory:testCategory];
    [testCategory addTestClass:[SierpinskiTriangle class]];
    [testCategory addTestClass:[SierpinskiTriangleWorkers4 class]];
    [testCategory addTestClass:[SierpinskiTriangleWorkers3Sleep3 class]];
    [testCategory addTestClass:[SierpinskiTriangleLow class]];
    [testCategory addTestClass:[SierpinskiTriangleLowSleep1 class]];
    [testCategory addTestClass:[SierpinskiTriangleBackground class]];
    [testCategory addTestClass:[SierpinskiTriangleBackgroundSleep1 class]];
    [testCategory addTestClass:[Asteroids class]];
    [testCategory addTestClass:[AsteroidCount class]];
    [testCategory addTestClass:[AsteroidsRenderingMode class]];
    [testCategory addTestClass:[AsteroidsCameraMode class]];

}


- (void) startTestInCategory:(NSString*) categoryName
                    withName:(NSString*) testName{
    METestCategory* category = [self categoryWithName:categoryName];
    if(category==nil){
        NSLog(@"Category %@ not found. Exiting.", categoryName);
        exit(0);
    }
    [category startTestWithName:testName];
}

- (METest*) testInCategory:(NSString*) categoryName
                  withName:(NSString*) testName{
    METestCategory* category = [self categoryWithName:categoryName];
    if(category==nil){
        NSLog(@"Category %@ not found. Exiting.", categoryName);
        exit(0);
    }
    return [category testWithName:testName];
}

@end
