//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "../../METest.h"
#import "../../METestCategory.h"
#import "../../METestManager.h"

#import <AltusMappingEngine/AltusMappingEngine.h>

@interface DownloadResult : NSObject
@property (assign) int statusCode;
@property (retain) NSData* data;
@end

@interface InternetVectorTileProvider : METileProvider
@end

@interface WorldSimple : METest
@end
