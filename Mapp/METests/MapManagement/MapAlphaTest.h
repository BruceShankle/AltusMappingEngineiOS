//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>

#import "../METest.h"
#import "MapManagementCategory.h"

@interface MapAlphaTest : METest
@property (retain) MEMapInfo* meMapInfo;
@property (assign) double alphaDelta;
- (id) initWithMapInfo:(MEMapInfo*) mapInfo;
@end

//Category and test for increasing map zorder
@interface MapAlphaUpCategory : MapManagementCategory
-(MapAlphaTest*) createTest:(MEMapInfo*) mapInfo;
@end

@interface MapAlphaDownCategory : MapAlphaUpCategory
@end

