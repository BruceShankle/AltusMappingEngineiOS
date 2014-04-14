//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import <AltusMappingEngine/AltusMappingEngine.h>

@class METestManager;
@class METestCategory;

@interface METest : NSObject <MEMapViewDelegate>

@property (retain) METestManager* meTestManager;
@property (retain) METestCategory* meTestCategory;
@property (retain) NSTimer* timer;
@property (copy) NSString* name;
@property (copy) NSString* label;
@property (readonly) NSString* uiLabel;
@property (assign) BOOL isRunning;
@property (assign) double interval;
@property (assign) BOOL repeats;
@property (assign) MEMapViewController* meMapViewController;
@property (assign) BOOL isEnabled;
@property (assign) CGFloat bestFontSize;
@property (retain) IBOutlet UILabel* lblStatus;

- (void) startTimer;
- (void) stopTimer;
- (void) timerTick;
- (void) start;
- (void) stop;
- (void) lookAtSanFrancisco;
- (void) lookAtUnitedStates;
- (void) userTapped;
+ (NSString*) getDocumentsPath;
+ (NSString*) getCachePath;
+ (double) randomDouble:(double)min max:(double)max;

@end
