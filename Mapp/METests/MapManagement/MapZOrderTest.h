//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import "../METest.h"
#import "MapManagementCategory.h"

@interface MapZOrderTest : METest
@property (retain) MEMapInfo* meMapInfo;
@property (assign) int zorderDelta;
- (id) initWithMapInfo:(MEMapInfo*) mapInfo;
@end

//Category and test for increasing map zorder
@interface MapZOrderUpCategory : MapManagementCategory
-(MapZOrderTest*) createTest:(MEMapInfo*) mapInfo;
@end

@interface MapZOrderDownCategory : MapZOrderUpCategory
@end




