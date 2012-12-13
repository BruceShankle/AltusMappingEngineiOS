//
//  MEInternetMaps.h
//  Mapp
//
//  Created by Bruce Shankle III on 9/27/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ME/ME.h>

@class MEInternetTileProvider;

@interface MEInternetMap : NSObject
-(MEInternetTileProvider*) createTileProvider;
+(NSString*) tileCacheRoot;
@property (retain) NSString* name;
@property (retain) MEMapViewController* meMapViewController;
@property (assign) int maxLevel;
@property (assign) BOOL zoomIndependent;
@property (assign) BOOL compressTextures;
@property (assign) int zOrder;
@property (assign) BOOL loadInvisible;
-(void) show;
-(void) hide;
@end

@interface MEMapBoxMap : MEInternetMap
@end

@interface MEMapBoxLandCoverStreetMap : MEInternetMap
@end

@interface MEMapBoxLandSatMap : MEInternetMap
@end




