//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"
#import "../METestCategory.h"
#import "../METestManager.h"
@interface PolygonPerfSlow : METest <MEVectorMapDelegate>
@property (assign) int longitude;
@end

@interface PolygonPerfFast : PolygonPerfSlow
@end