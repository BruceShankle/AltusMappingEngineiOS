//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import <AltusMappingEngine/AltusMappingEngine.h>
#import "METest.h"
#import "METestCategory.h"

@interface METestManager : NSObject

//Properites
@property (retain) MEMapViewController* meMapViewController;
@property (retain) NSMutableArray* meTestCategories;

- (METestCategory*) categoryWithName:(NSString*) categoryName;

- (id) initWithMEMapViewController:(MEMapViewController*) meMapViewController;

- (void) startTestInCategory:(NSString*) categoryName
                    withName:(NSString*) testName;

- (METest*) testInCategory:(NSString*) categoryName
                  withName:(NSString*) testName;

- (void) stopCategory:(NSString*) categoryName;

- (void) stopBaseMapTests;

- (void) stopAllTests;

- (void) startInitialTest;

@end


