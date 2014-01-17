//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import "MEVectorTileProvider.h"
#import "../METest.h"

@interface MEVectorTPSimpleLines : METest
@property (retain) MEVectorTileProvider* meVectorTileProvider;
@end

@interface MEWorldVectorVirtual : METest
@property (retain) NSString *styleName;
@property (retain) NSString* mapName;
@end

@interface MEWorldVectorVirtualStyle2 : MEWorldVectorVirtual
@end

@interface MEWorldVectorVirtualStyle3 : MEWorldVectorVirtual
@end

@interface MEWorldVectorVirtualRemoveMap : MEWorldVectorVirtual
@end
