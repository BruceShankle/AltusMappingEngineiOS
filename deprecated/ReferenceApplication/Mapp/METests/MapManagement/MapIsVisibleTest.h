//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>

#import "../METest.h"
#import "MapManagementCategory.h"

@interface MapIsVisibleTest : METest
@property (retain) MEMapInfo* meMapInfo;
- (id) initWithMapInfo:(MEMapInfo*) mapInfo;
@end

@interface MapIsVisibleCategory : MapManagementCategory
-(MapIsVisibleTest*) createTest:(MEMapInfo*) mapInfo;
@end


