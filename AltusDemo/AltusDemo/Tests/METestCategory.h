//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import "METest.h"

@class METestManager;

@interface METestCategory : NSObject <MEMapViewDelegate>

@property (retain) METestManager* meTestManager;
@property (retain) NSString* name;
@property (retain) NSMutableArray* meTests;
@property (retain) MEMapViewController* meMapViewController;

- (void) addTest:(METest*) newTest;
- (void) addTestClass:(Class) testClass;
- (void) stopAllTests;
- (METest*) testWithName:(NSString*) testName;
- (void) startTestWithName:(NSString*) testName;

@end
