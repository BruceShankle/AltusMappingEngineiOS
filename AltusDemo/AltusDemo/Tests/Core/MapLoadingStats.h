//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import "../METest.h"

@interface MapInfoLabel : NSObject
@property (retain) NSString* mapName;
@property (retain) UILabel* label;
@property (retain) METimer* timer;
@property (assign) long cumulativeTime;
@property (assign) BOOL showCumulativeTime;
-(void) updateLabelText;
-(void) willStartLoading;
-(void) didFinishLoading;
-(void) remove;
-(void) disable;
-(void) enable;
@end

@interface MapLoadingStats : METest <MEMapViewDelegate>
@property (retain) NSMutableDictionary* mapInfoLabelDictionary;
@property (retain) id<MEMapViewDelegate> oldMapViewDelegate;
@end
