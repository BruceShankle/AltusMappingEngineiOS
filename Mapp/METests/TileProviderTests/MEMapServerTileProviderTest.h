//
//  MEMapServerTileProviderTest.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/21/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../METest.h"
#import "MEMapServerTileProvider.h"
#import <ME/ME.h>

@interface MEMapServerTileProviderTest : METest
@property (retain) MEMapServerTileProvider* meMapServerTileProvider;
@property (copy) NSString* mapName;
-(void) createTileProvider;
@end

@interface MEUIImageMapServerTileProviderTest : MEMapServerTileProviderTest
@end

@interface MENSDataMapServerTileProviderTest : MEMapServerTileProviderTest
@end
