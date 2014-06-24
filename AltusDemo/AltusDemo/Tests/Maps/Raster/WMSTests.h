//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../../METest.h"
#import "../../Utilities/TileWorker.h"

@interface WMSTest : METest
-(TileWorker*) createTileWorker;
-(MEVirtualMapInfo*) createMapInfo;
@end

@interface NOAARadar : WMSTest
@end

@interface MEWMSBlueMarbleTest : WMSTest
@end

@interface MEWMSDCTest : WMSTest
@end

@interface MEWMSSeattleTest : WMSTest
@end

@interface MEWMSOregonTest : WMSTest
@end

@interface MEWMSNationalAtlasStates : WMSTest
@end

@interface MEWMSNationalAtlasTreeCanopy : WMSTest
@end

@interface MEWMSNationalAtlasPorts : WMSTest
@end

@interface MEWMSNationalAtlasCitiesTowns : WMSTest
@end

@interface MEWMSNationalAtlasUrbanAreas : WMSTest
@end

@interface MEWMSNationalAtlas2008Election : WMSTest
@end

@interface MEWMSNationalAtlasPrecipitation : WMSTest
@end

