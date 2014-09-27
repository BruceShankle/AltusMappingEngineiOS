//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import <AltusMappingEngine/AltusMappingEngine.h>
#import "METestView.h"

@class METestManager;
@class METestCategory;

@interface METest : NSObject <MEMapViewDelegate>

@property (retain) METestManager* meTestManager;
@property (retain) METestCategory* meTestCategory;
@property (retain) NSTimer* timer;
@property (retain) UILabel* lblMessage;
@property (retain) METimer* benchMarkTimer;
@property (copy) NSString* name;
@property (copy) NSString* label;
@property (readonly) NSString* uiLabel;
@property (assign) BOOL isRunning;
@property (assign) double interval;
@property (assign) BOOL repeats;
@property (retain) MEMapViewController* meMapViewController;
@property (assign) BOOL isEnabled;
@property (assign) CGFloat bestFontSize;
@property (retain) IBOutlet UILabel* lblStatus;
@property (retain) NSDate* lastTickTime;
@property (assign) NSTimeInterval elapsedTime;
@property (retain) UIAlertView* alertView;
@property (retain) METestView* view;

- (void) startTimer;
- (void) stopTimer;
- (void) timerTick;
- (void) startBenchmarkTimer;
- (long) stopBenchMarkTimer;
- (void) setMessageText:(NSString*) msgText;
- (void) createView;
- (void) start;
- (void) stop;
- (void) beginTest;
- (void) endTest;
- (void) lookAtSanFrancisco;
- (void) lookAtUnitedStates;
- (void) userTapped;
- (void) stopAllOtherTests;
- (void) stopTestsInThisCategory;
/**Show an alert to the user.
 @param message Text to display.
 @param timeout If non-zero, the number of seconds to display the alert before removing it. If zero, the alert will not time out.*/
- (void) showAlert:(NSString *)message
           timeout:(double)timeout;

+ (NSString*) getDocumentsPath;
+ (NSString*) getCachePath;
+ (double) randomDouble:(double)min max:(double)max;
+ (float) randomFloat:(float)min max:(float)max;
+ (float) randomHeading;
+ (CLLocationCoordinate2D) randomLocation;

@end
