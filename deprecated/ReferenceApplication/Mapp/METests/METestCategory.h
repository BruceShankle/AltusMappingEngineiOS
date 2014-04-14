//
//  METestCategory.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/16/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "METest.h"
#import <ME/ME.h>

@class METestManager;

@interface METestCategory : NSObject <MEMapViewDelegate>

@property (nonatomic, retain) METestManager* meTestManager;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, retain) NSMutableArray* meTests;
@property (nonatomic, retain) MEMapViewController* meMapViewController;
@property (nonatomic, retain) METest* lastTestStarted;
@property (assign) BOOL containsDynamicTestArray;
- (void) addTest:(METest*) newTest;
- (void) addTestClass:(Class) testClass;
- (void) stopAllTests;
- (METest*) testFromIndex:(int) testIndex;
- (METest*) testWithName:(NSString*) testName;
- (void) startTestWithName:(NSString*) testName;
- (void) updateTestArray;
@end
