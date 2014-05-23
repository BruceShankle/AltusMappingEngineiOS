//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import "../../METest.h"
#import "../../METestCategory.h"

/** Provides markers on-demand for a given area as the mapping engine requests
 them allowing for implementation of cusom clustering algorithms but with
 the mapping engine doing efficient rendering.*/
@interface CustomMarkerProvider : METileProvider
@end

@interface CustomClustering : METest <MEDynamicMarkerMapDelegate>
@end
