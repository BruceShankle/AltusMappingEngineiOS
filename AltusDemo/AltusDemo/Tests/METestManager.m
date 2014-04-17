//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "METestManager.h"
#import "Maps/Maps.h"
#import "Markers/Markers.h"
#import "Weather/Weather.h"
#import "Terrain/Terrain.h"

@implementation METestManager

- (id) initWithMEMapViewController:(MEMapViewController*) meMapViewController{
    
    if(self = [super init]){
        self.meMapViewController = meMapViewController;
        self.meTestCategories = [[NSMutableArray alloc]init];
        [self createAllTests];
    }
    return self;
    
}

- (void) stopCategory:(NSString*) categoryName{
    METestCategory* category = [self categoryWithName:categoryName];
    if(category!=nil){
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
    [self createTerrainTests];
    [self createMapTests];
    [self createMarkerTests];
    [self createWeatherTests];
}

- (void) createMapTests{
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Maps";
    [self addCategory:testCategory];
    [testCategory addTestClass:[AltusRasterPackage class]];
    [testCategory addTestClass:[AltusVectorPackage class]];
    [testCategory addTestClass:[WorldSimple class]];
    [testCategory addTestClass:[HoustonStreetsStyle1 class]];
    [testCategory addTestClass:[HoustonStreetsStyle2 class]];
    [testCategory addTestClass:[HoustonStreetsStyle3 class]];
    [testCategory addTestClass:[MapQuestAerial class]];
    [testCategory addTestClass:[MapBoxSatellite class]];
    [testCategory addTestClass:[MapBoxStreets class]];
    [testCategory addTestClass:[MBTilesNative class]];
    [testCategory addTestClass:[BA3NativeAcadia class]];
    
}

- (void) createMarkerTests{
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Markers";
    [self addCategory:testCategory];
    [testCategory addTestClass:[CustomClustering class]];
    [testCategory addTestClass:[Places class]];
    [testCategory addTestClass:[Towers class]];
}

- (void) createWeatherTests{
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Weather";
    [self addCategory:testCategory];
    [testCategory addTestClass:[WorldSamples class]];
    [testCategory addTestClass:[ColorMosaicTest class]];
    [testCategory addTestClass:[ColorMosaicNativeTest class]];
    
}

- (void) createTerrainTests {
    METestCategory* testCategory = [[METestCategory alloc]init];
    testCategory.name = @"Terrain";
    [self addCategory:testCategory];
	[testCategory addTestClass:[EarthLocal class]];
    [testCategory addTestClass:[DynamicColorBar class]];
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
