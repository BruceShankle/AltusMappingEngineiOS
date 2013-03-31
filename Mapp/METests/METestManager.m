//
//  METestManager.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/16/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "METestManager.h"
#import "METest.h"
#import "MiscTests/MESpinningGlobeTest.h"
#import "MiscTests/METileSizingTest.h"
#import "MiscTests/MEIsRetinaDisplayTest.h"
#import "MiscTests/MELocationThatFitsTest.h"
#import "MiscTests/MEZoomTest.h"
#import "MiscTests/METerrainColorBarTest.h"
#import "Misctests/MEClearColorTest.h"
#import "MiscTests/ClippingPlaneTest.h"
#import "MiscTests/MEAnimatedVectorCircleTests.h"
#import "MiscTests/METrueNorthAlgnedMarkerTest.h"
#import "MiscTests/MECacheTests.h"
#import "MiscTests/MEInvalidMapInfoTests.h"
#import "VectorTests/MEInMemoryVectorPolygonsTest.h"
#import "VectorTests/MEInMemoryVectorLinesTest.h"
#import "VectorTests/MEDynamicLinesTest.h"
#import "VectorTests/MEShapeFileTest.h"
#import "VectorTests/MEKMLShapes.h"
#import "TileProviderTests/MEUIImageTileProviderTest.h"
#import "TileProviderTests/MEInvisibleTileProviderTest.h"
#import "TileProviderTests/MEMapServerTileProviderTest.h"
#import "MBTilesTests/MBTilesTileProviderTest.h"
#import "MarkerTests/MEMarkerTests.h"
#import "MarkerTests/MEMarkerFastLoad.h"
#import "MarkerTests/MEMarkerHitTest.h"
#import "MarkerTests/METemporalMarkerTests.h"
#import "MarkerTests/MEHideMarkerTest.h"
#import "MarkerTests/MEMarkerDatabaseCacheTest.h"
#import "MarkerTests/AirTrafficTest.h"
#import "SymbioteTests/MESymbioteTests.h"
#import "TAWSTests/METawsTest.h"
#import "AnimatedMapTests/MEAnimatedSlippyMapTest.h"
#import "ScenarioTests/RouteRubberBandingTest.h"
#import "ScenarioTests/ComplexRoute.h"
#import "WorldVectorTests/MEWorldVectorStyling.h"
#import "Core/MECoreTests.h"
#import "MapTests/MEInternetMapTests.h"
#import "MapManagement/MapZOrderTest.h"
#import "MapManagement/MapAlphaTest.h"
#import "MapManagement/MapIsVisibleTest.h"
#import "Demos/PerformanceDemos.h"
#import "PerfTests/MapLoading.h"
#import "CameraTests/CameraTests.h"
#import "RefreshMapTests/RefreshMapTests.h"
#import "MapTests/MELocalTerrainMaps.h"
#import "MapTests/METilesNotAvailableTest.h"
#import "MapTests/MERefreshMapTests.h"
#import "MapTests/MERefreshAllMapsTest.h"
#import "MapTests/MESparseTileMapTest.h"

@implementation METestManager

@synthesize meTestCategories;
@synthesize meMapViewController;
@synthesize meTestManagerDelegate;
@synthesize lblCopyrightNotice;

- (id) init
{
    if(self = [super init])
    {
        self.meTestCategories = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void) setCopyrightNotice:(NSString*) copyrightNotice
{
	if(self.lblCopyrightNotice==nil) return;
	[self.lblCopyrightNotice setText:copyrightNotice];
}

- (void) dealloc
{
    self.meTestCategories = nil;
    self.meMapViewController = nil;
    self.meTestManagerDelegate = nil;
    [super dealloc];
}

- (void) testUpdated:(METest*) meTest
{
    if(self.meTestManagerDelegate)
    {
        [self.meTestManagerDelegate testUpdated:meTest];
    }
}

- (void) addCategory:(METestCategory*) newCategory
{
    newCategory.meMapViewController = self.meMapViewController;
    newCategory.meTestManager = self;
    [self.meTestCategories addObject:newCategory];
}

- (METestCategory*) categoryFromIndex:(int) categoryIndex
{
    return (METestCategory*)[self.meTestCategories objectAtIndex:categoryIndex];
}

- (METestCategory*) categoryFromName:(NSString*) categoryName
{
	for(METestCategory* category in self.meTestCategories)
	{
		if([category.name isEqualToString:categoryName])
			return category;
	}
	NSLog(@"The test category %@ does not exist. Exiting.", categoryName);
	exit(1);
	return nil;
}

- (METest*) testFromCategory:(int) categoryIndex testIndex:(int)testIndex
{
    METestCategory* meTestCategory = [self categoryFromIndex:categoryIndex];
    return (METest*)[meTestCategory.meTests objectAtIndex:testIndex];
}

- (void) stopEntireCategory:(METestCategory *)category
{
	for(METest* test in category.meTests)
	{
		[test stop];
	}
	[self testUpdated:nil];
}

- (void) stopEntireCategoryWithName:(NSString*) categoryName
{
    for(METestCategory* category in self.meTestCategories)
    {
        if([category.name isEqualToString:categoryName])
        {
			[self stopEntireCategory:category];
        }
    }
}

- (METest*) testFromCategoryName:(NSString*) categoryName withTestName:(NSString*) testName
{
    for(METestCategory* category in self.meTestCategories)
    {
        if([category.name isEqualToString:categoryName])
        {
            for(METest* test in category.meTests)
            {
                if([test.name isEqualToString:testName])
                {
                    return test;
                }
            }
        }
    }
    return nil;
}

- (void) createCameraTests
{
    METestCategory* testCategory = [[[METestCategory alloc]init]autorelease];
    testCategory.name = @"Camera";
    [self addCategory:testCategory];
	[testCategory addTestClass:[FlightAcrossAntimeridian class]];
	[testCategory addTestClass:[FlightPlaybackUnlocked class]];
	[testCategory addTestClass:[FlightPlaybackUnlockedFlashing class]];
	[testCategory addTestClass:[FlightPlaybackCentered class]];
	[testCategory addTestClass:[FlightPlaybackTrackUpCentered class]];
	[testCategory addTestClass:[FlightPlaybackTrackUpCenteredPannable class]];
	[testCategory addTestClass:[FlightPlaybackTrackUpForward class]];
	[testCategory addTestClass:[FlightPlaybackTrackUpForwardPannable class]];
	[testCategory addTestClass:[FlightPlaybackTrackUpForwardAnimated class]];
	
	[testCategory addTestClass:[ZoomLimits class]];
	[testCategory addTestClass:[ZoomLimitsIncreaseMax class]];
	[testCategory addTestClass:[ZoomLimitsDecreaseMax class]];
	[testCategory addTestClass:[ZoomLimitsIncreaseMin class]];
	[testCategory addTestClass:[ZoomLimitsDecreaseMin class]];
}

- (void) createCoreTests
{
    METestCategory* testCategory = [[[METestCategory alloc]init]autorelease];
    testCategory.name = @"Core";
    [self addCategory:testCategory];
	[testCategory addTestClass:[MEInitializationTest class]];
	[testCategory addTestClass:[METileLevelBiasTest class]];
	[testCategory addTestClass:[METileLevelBiasSmoothingTest class]];
	[testCategory addTestClass:[MEChangeCacheSizeTest class]];
	[testCategory addTestClass:[MERemoveAllMapsClearCacheTest class]];
	[testCategory addTestClass:[METoggleMultiThreadingTest class]];
	[testCategory addTestClass:[METoggleAntialiasingTest class]];
	[testCategory addTestClass:[METoggleDisableDisplayListTest class]];
	[testCategory addTestClass:[METogglePanDecelerationTest class]];
	[testCategory addTestClass:[MESetPanDecelerationTest class]];
	[testCategory addTestClass:[MEPanVelocityScaleTest class]];
}


- (void) createPerfTests
{
	METestCategory* testCategory = [[[METestCategory alloc]init]autorelease];
	testCategory.name = @"Perf Tests";
	[self addCategory:testCategory];
	[testCategory addTestClass:[LoadSingleMap_Sectional class]];
	[testCategory addTestClass:[LoadAllMaps_Sectional class]];
	[testCategory addTestClass:[LoadAllMaps_IFRLow class]];
	[testCategory addTestClass:[LoadAllMaps_IFRLowPVR class]];
}

- (void) createMapZOrderUpTests
{
	METestCategory* testCategory = [[[MapZOrderUpCategory alloc]init]autorelease];
	testCategory.name = @"Map ZOrder +";
	[self addCategory:testCategory];
}

- (void) createMapZOrderDownTests
{
	METestCategory* testCategory = [[[MapZOrderDownCategory alloc]init]autorelease];
	testCategory.name = @"Map ZOrder -";
	[self addCategory:testCategory];
}

- (void) createMapAlphaUpTests
{
	METestCategory* testCategory = [[[MapAlphaUpCategory alloc]init]autorelease];
	testCategory.name = @"Map Alpha +";
	[self addCategory:testCategory];
}

- (void) createMapAlphaDownTests
{
	METestCategory* testCategory = [[[MapAlphaDownCategory alloc]init]autorelease];
	testCategory.name = @"Map Alpha -";
	[self addCategory:testCategory];
}

-(void) createMapIsVisibleTests
{
	METestCategory* testCategory = [[[MapIsVisibleCategory alloc]init]autorelease];
	testCategory.name = @"Map IsVisible";
	[self addCategory:testCategory];
}


- (void) createMapTests
{
	METestCategory* testCategory;
	
	//Add internet maps
	testCategory = [[[METestCategory alloc]init]autorelease];
    testCategory.name = @"Internet Maps";
    [self addCategory:testCategory];
	[testCategory addTestClass:[MEInternetMapLoadInvisible class]];
	[testCategory addTestClass:[MEInternetMapAnalyzeCacheTest class]];
	[testCategory addTestClass:[MEInternetMapClearCacheTest class]];
	[testCategory addTestClass:[MEMapBoxMarsMapTest class]];
	[testCategory addTestClass:[MERefreshMarsTest class]];
	[testCategory addTestClass:[MEMapBoxLandCoverMapTest class]];
	[testCategory addTestClass:[MEMapQuestMapTest class]];
	[testCategory addTestClass:[MEMapQuestAerialMapTest class]];
	[testCategory addTestClass:[MEMapQuestAerialMapTest2 class]];
	[testCategory addTestClass:[MEOpenStreetMapsMapTest class]];
	[testCategory addTestClass:[MEStamenTerrainMapTest class]];
	
	//Add compressed internet maps
	testCategory = [[[METestCategory alloc]init]autorelease];
    testCategory.name = @"Internet Maps - 2 Byte";
    [self addCategory:testCategory];
	[testCategory addTestClass:[MEInternetMapLoadInvisible class]];
	[testCategory addTestClass:[MEInternetMapAnalyzeCacheTest class]];
	[testCategory addTestClass:[MEInternetMapClearCacheTest class]];
	[testCategory addTestClass:[cMEMapBoxLandCoverMapTest class]];
	[testCategory addTestClass:[cMEMapQuestMapTest class]];
	[testCategory addTestClass:[cMEMapQuestAerialMapTest class]];
	[testCategory addTestClass:[cMEOpenStreetMapsMapTest class]];
	[testCategory addTestClass:[cMEStamenTerrainMapTest class]];
}

- (void) createVectorTests
{
    METestCategory* testCategory = [[[METestCategory alloc]init]autorelease];
    testCategory.name = @"Vectors";
    [self addCategory:testCategory];
	[testCategory addTestClass:[MECaliforniaPolygon class]];
    [testCategory addTestClass:[MEInMemoryVectorPolygonsTest class]];
	[testCategory addTestClass:[MEInMemoryVectorPolygonsStressTest class]];
	[testCategory addTestClass:[MEInMemoryVectorPolygonEdgeCases class]];
	[testCategory addTestClass:[MEInMemoryVectorPolygonsAlphaTest class]];
	[testCategory addTestClass:[MEInMemoryVectorLinesTest class]];
    [testCategory addTestClass:[MEDynamicLinesTest class]];
	[testCategory addTestClass:[MEShapeFileTest class]];
}

- (void) createMarkerTests
{
    METestCategory* testCategory = [[[METestCategory alloc]init]autorelease];
    testCategory.name = @"Markers";
	[self addCategory:testCategory];
	
	[testCategory addTestClass:[AirTrafficTest class]];
	[testCategory addTestClass:[MERemoveMarkerTest class]];
	[testCategory addTestClass:[MEMarkersFastPath class]];
	[testCategory addTestClass:[MEMarkersFastPathClustered class]];
	
	[testCategory addTestClass:[MEMarkerHitTest class]];
	[testCategory addTestClass:[MEMarkerHitTestSize class]];
	[testCategory addTestClass:[MEMarkerSynchronousLoad class]];
	[testCategory addTestClass:[MEMarkerAsynchronousLoad class]];
	
	//Metool generated markers
	[testCategory addTestClass:[MEWeatherMarkerTest class]];
	[testCategory addTestClass:[MEWeatherMarkerCachedTest class]];
	[testCategory addTestClass:[MEWeatherMarkerBadPrefixTest class]];
	[testCategory addTestClass:[MEMarkerPerfTest class]];
	[testCategory addTestClass:[MEMTCountriesAndStateMarkersFromDisk class]];
	[testCategory addTestClass:[MEMTCitiesFromDisk class]];
	[testCategory addTestClass:[METowersHeightsMarkersTest class]];
	[testCategory addTestClass:[METowersHeightsMarkersTestRandomFontSize class]];
	[testCategory addTestClass:[METowersHeightsMarkersTestHalfHidden class]];
	[testCategory addTestClass:[METowersJHeightsMarkersTest class]];

	[testCategory addTestClass:[METAWSTowersNonCached class]];
	[testCategory addTestClass:[METAWSTowersCached class]];
	[testCategory addTestClass:[MEAirportMarkersFromBundle class]];
	[testCategory addTestClass:[MEAirportMarkersFromBundleRotated class]];
	
	[testCategory addTestClass:[MEAirportMarkersInMemory class]];
	[testCategory addTestClass:[MEAirportMarkersToDiskCache class]];
	[testCategory addTestClass:[MEAirportMarkersFromDiskCache class]];

    [testCategory addTestClass:[MESFOBusAddInMemoryClusteredMarkerTest class]];
	[testCategory addTestClass:[BusStopsClusteredInMemoryFast class]];
	[testCategory addTestClass:[BusStopsNonClusteredInMemorySync class]];
	[testCategory addTestClass:[BusStopsNonClusteredInMemoryFast class]];
    [testCategory addTestClass:[MESFOBusCreateAndAddClusteredMarkerTest class]];
    [testCategory addTestClass:[MESFOBusAddExistingClusteredMarkerTest class]];
	[testCategory addTestClass:[MEBusDynamicMarker class]];
	[testCategory addTestClass:[MERotatingBusDynamicMarker class]];
    [testCategory addTestClass:[MECountryMarkersInMemory class]];
    [testCategory addTestClass:[MECountryMarkersSaveToDisk class]];
    [testCategory addTestClass:[MECountryMarkersFromDisk class]];
	[testCategory addTestClass:[MEMTCountryMarkersFromDisk class]];
	[testCategory addTestClass:[MEMTStateMarkersFromDisk class]];
	
//	[testCategory addTestClass:[MEMarkerDatabaseCacheTest class]];
//	[testCategory addTestClass:[MEHideMarkerTest class]];
//	[testCategory addTestClass:[METemporalMarkerTestA class]];
//	[testCategory addTestClass:[METemporalMarkerTestB class]];
//	[testCategory addTestClass:[METemporalMarkerTestC class]];
//	[testCategory addTestClass:[METemporalMarkerTestD class]];
	
}

- (void) createTileProviderTests
{
    METestCategory* testCategory = [[[METestCategory alloc]init]autorelease];
    testCategory.name = @"Tile Providers";
    [self addCategory:testCategory];
    [testCategory addTestClass:[MEUIImageTileProviderTest class]];
    [testCategory addTestClass:[MEAsyncUIImageTileProviderTest class]];
    [testCategory addTestClass:[MEMapServerTileProviderTest class]];
    [testCategory addTestClass:[MEUIImageMapServerTileProviderTest class]];
    [testCategory addTestClass:[MENSDataMapServerTileProviderTest class]];
    //[testCategory addTestClass:[MBTIlesTileProviderTest class]];
    [testCategory addTestClass:[MEInvisibleTileProviderTest class]];
    [testCategory addTestClass:[MEUnavailableTileProviderTest class]];
    [testCategory addTestClass:[MEIntermittentTileProviderTest class]];    	
    
}

- (void) createMiscTests
{
    METestCategory* testCategory = [[[METestCategory alloc]init]autorelease];
    testCategory.name = @"Misc";
    [self addCategory:testCategory];
	[testCategory addTestClass:[MESparseTileMapTest class]];
	[testCategory addTestClass:[MERefreshAllMapsTest class]];
	[testCategory addTestClass:[MERefreshDirtyAllMapsTest class]];
	[testCategory addTestClass:[MERefreshMapRegionTest class]];
	[testCategory addTestClass:[MERefreshMapRegionStress class]];
	[testCategory addTestClass:[METilesNotAvailableTest class]];
	[testCategory addTestClass:[METilesNotAvailableXYZTest class]];
	[testCategory addTestClass:[MENilStringsTest class]];
	[testCategory addTestClass:[MESmallCacheTest class]];
	[testCategory addTestClass:[METrueNorthAlgnedMarkerTest class]];
	[testCategory addTestClass:[MEAnimatedVectorCircleTests class]];
	[testCategory addTestClass:[RefreshMemoryMarkerMapTest class]];
	[testCategory addTestClass:[ClippingPlaneTest class]];
	[testCategory addTestClass:[MEClearColorTest class]];
    [testCategory addTestClass:[MESpinningGlobeTest class]];
    [testCategory addTestClass:[METileSizingTest class]];
    [testCategory addTestClass:[MEIsRetinaDisplayTest class]];
    [testCategory addTestClass:[MELocationThatFitsBoundsTest class]];
    [testCategory addTestClass:[MELocationThatFitsPointsTest class]];
    [testCategory addTestClass:[MEZoomInTest class]];
    [testCategory addTestClass:[MEZoomOutTest class]];
    [testCategory addTestClass:[MEAltitudeAnimatedTest class]];
    [testCategory addTestClass:[MEAltitudeNonAnimatedTest class]];
    [testCategory addTestClass:[METerrainColorBarTest class]];
}

- (void) createSymbioteTests
{
    METestCategory* testCategory = [[[METestCategory alloc]init]autorelease];
    testCategory.name = @"Symbiotes";
    [self addCategory:testCategory];
    [testCategory addTestClass:[MEUIViewSymbioteTest class]];
    [testCategory addTestClass:[MERouteSymbioteTest class]];
}

- (void) createTawsTests
{
    METestCategory* testCategory = [[[METestCategory alloc]init]autorelease];
    testCategory.name = @"TAWS";
    [self addCategory:testCategory];
    [testCategory addTestClass:[METawsTest class]];
	[testCategory addTestClass:[METawsHighestDetailOnlyTest class]];
	[testCategory addTestClass:[METawsColorBarTest class]];
}

- (void) createAnimatedMapTests
{
    METestCategory* testCategory = [[[METestCategory alloc] init] autorelease];
    testCategory.name = @"Animated Maps";
    [self addCategory:testCategory];
	[testCategory addTestClass:[MEAnimatedMapTest class]];
	[testCategory addTestClass:[MEAnimatedMapTest2 class]];
	[testCategory addTestClass:[MEAnimatedMapTest3 class]];
	[testCategory addTestClass:[MEAnimatedMapTest4 class]];
	[testCategory addTestClass:[MEAnimatedMapTest5 class]];
	
}

- (void) createScenarioTests
{
    METestCategory* testCategory = [[[METestCategory alloc] init] autorelease];
    testCategory.name = @"Scenarios";
    [self addCategory:testCategory];
    [testCategory addTestClass:[RouteRubberBandingTest class]];
	[testCategory addTestClass:[ComplexRoute class]];
	[testCategory addTestClass:[ParallelsAndMeridians class]];
}

- (void) createWorldVectorTests
{
    METestCategory* testCategory = [[[METestCategory alloc] init] autorelease];
    testCategory.name = @"World Vector";
    [self addCategory:testCategory];
    [testCategory addTestClass:[MEWorldVectorMapBoxStyle class]];
	[testCategory addTestClass:[MEWorldVectorGoogleStyle class]];
    [testCategory addTestClass:[MEWorldVectorHighContrastStyle class]];
    [testCategory addTestClass:[MEWorldVectorPurpleStyle class]];
	[testCategory addTestClass:[MEWorldVectorGeologyDotComStyle class]];
	[testCategory addTestClass:[MEWorldVectorInvisibleStyle class]];
}

- (void) createMBTilesTests
{
    METestCategory* testCategory = [[[METestCategory alloc] init] autorelease];
    testCategory.name = @"MB Tiles";
    [self addCategory:testCategory];
    [testCategory addTestClass:[MBTIlesTileProviderTest class]];
	[testCategory addTestClass:[MBTilesNativeTest class]];
}

- (void) createDemos
{
	METestCategory* testCategory = [[[METestCategory alloc] init] autorelease];
    testCategory.name = @"Demos";
    [self addCategory:testCategory];
    [testCategory addTestClass:[PlanetWatch class]];
	[testCategory addTestClass:[PlanetWatchRaster class]];
	[testCategory addTestClass:[PlanetWatchVector class]];
}

- (void) createLocalTerrainTests
{
	METestCategory* testCategory = [[[LocalTerrainMapTestsCategory alloc]init]autorelease];
    [self addCategory:testCategory];
}

- (void) backgroundCreateAllTests
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^ {
		[self createAllTests];
	});
}
- (void) createAllTests
{
	[self createLocalTerrainTests];
	[self createDemos];
	[self createCameraTests];
	[self createPerfTests];
	[self createCoreTests];
	[self createMapTests];
    [self createWorldVectorTests];
    [self createVectorTests];
    [self createTileProviderTests];
    [self createMiscTests];
	[self createMapZOrderUpTests];
	[self createMapZOrderDownTests];
	[self createMapAlphaUpTests];
	[self createMapAlphaDownTests];
	[self createMapIsVisibleTests];
    [self createScenarioTests];
    [self createSymbioteTests];
    [self createTawsTests];
    [self createAnimatedMapTests];
	[self createMBTilesTests];
	[self createMarkerTests];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    // Proxy all unimplemented method calls to our categories
    
    bool invocationProcessed = NO;
    
    for(METestCategory* cat in self.meTestCategories)
    {
        if ([cat respondsToSelector:[anInvocation selector]])
        {
            [anInvocation invokeWithTarget:cat];
            invocationProcessed = YES;
        }
    }
    
    if( !invocationProcessed )
    {
        [super forwardInvocation:anInvocation];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    for(METestCategory* cat in self.meTestCategories)
    {
        if( [cat respondsToSelector:aSelector] )
        {
            return YES;
        }
    }
    
    return [super respondsToSelector:aSelector];
}

@end
