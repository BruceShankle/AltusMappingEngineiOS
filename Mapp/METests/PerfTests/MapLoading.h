//
//  MapLoading.h
//  Mapp
//
//  Created by Bruce Shankle III on 10/18/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <ME/ME.h>
#import <Foundation/Foundation.h>
#import "../METest.h"
#import "../../MapManager/MEMapCategory.h"

@interface LoadSingleMap_Sectional : METest <MEMapViewDelegate>
@property (retain) id<MEMapViewDelegate> oldDelegate;
@property (retain) MEMapCategory* mapCategory;
@property (retain) NSString* categoryName;
@property (assign) unsigned int currentMapIndex;
@property (assign) BOOL loadingComplete;
@end

@interface LoadAllMaps_Sectional : LoadSingleMap_Sectional
@property (assign) unsigned int didFinishLoadingCount;
@property (assign) unsigned int willStartLoadingCount;
@end

@interface LoadAllMaps_IFRLow : LoadAllMaps_Sectional
@end

@interface LoadAllMaps_IFRLowPVR : LoadAllMaps_IFRLow
@end