//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <ME/ME.h>
#import "../METest.h"

@interface MEWMSTest : METest
-(METileProvider*) createTileProvider;
-(MEVirtualMapInfo*) createMapInfo;
@end

@interface MEWMSBlueMarbleTest : MEWMSTest
@end

@interface MEWMSDCTest : MEWMSTest
@end

@interface MEWMSSeattleTest : MEWMSTest
@end

@interface MEWMSOregonTest : MEWMSTest
@end

@interface MEWMSNationalAtlasStates : MEWMSTest
@end

@interface MEWMSNationalAtlasTreeCanopy : MEWMSTest
@end

@interface MEWMSNationalAtlasPorts : MEWMSTest
@end

