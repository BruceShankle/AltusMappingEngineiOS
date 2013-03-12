//
//  MEInMemoryVectorTest.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/16/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "METest.h"

@interface MEInMemoryVectorPolygonsTest : METest
@end

@interface MEInMemoryVectorPolygonsStressTest : MEInMemoryVectorPolygonsTest <MEMapViewDelegate>
@property (retain) id<MEMapViewDelegate> oldDelegate;
@end

@interface MEInMemoryVectorPolygonEdgeCases : METest
@end


@interface MEInMemoryVectorPolygonsAlphaTest : MEInMemoryVectorPolygonsTest
@property (assign) float currentAlpha;
@end
