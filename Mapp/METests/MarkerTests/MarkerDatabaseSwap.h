//
//  MarkerDatabaseSwap.h
//  Mapp
//
//  Created by Bruce Shankle on 12/12/13.
//  Copyright (c) 2013 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../METest.h"

@interface MarkerDatabaseSwap : METest <MEMarkerMapDelegate, MEMapViewDelegate>
@property (retain) NSString* markerFile1;
@property (retain) NSString* markerFile2;
@property (retain) NSString* mapName1;
@property (retain) NSString* mapName2;
@property (retain) id oldDelegate;
@property (assign) BOOL isTimerRunning;
@property (assign) BOOL newMapReady;
@end
