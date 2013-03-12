//
//  METest.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/16/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ME/ME.h>

@class METestManager;
@class METestCategory;

@interface METest : NSObject <MEMapViewDelegate>

@property (nonatomic, retain) METestManager* meTestManager;
@property (nonatomic, retain) METestCategory* meTestCategory;
@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* label;
@property (nonatomic, readonly) NSString* uiLabel;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) double interval;
@property (nonatomic, assign) BOOL repeats;
@property (nonatomic, assign) MEMapViewController* meMapViewController;
@property (nonatomic, readonly) BOOL isEnabled;
@property (nonatomic, assign) CGFloat bestFontSize;
@property (retain) IBOutlet UILabel* lblStatus;

- (void) startTimer;
- (void) stopTimer;
- (void) timerTick;
- (void) userTapped;
- (void) start;
- (void) stop;
- (void) wasUpdated;
- (void) lookAtSanFrancisco;
- (void) lookAtUnitedStates;
- (void) lookAtAtlantic;
- (void) lookAtGuam;
+ (NSString*) getDocumentsPath;
+ (NSString*) getCachePath;
- (BOOL) isOtherTestRunning:(NSString*) testName;
- (void) addStatusLabel;
- (void) removeStatusLabel;
- (void) setStatusLabelText:(NSString*) newText;
@end
