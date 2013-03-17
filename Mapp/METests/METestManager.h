//
//  METestManager.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/16/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ME/ME.h>
#import "METest.h"
#import "METestCategory.h"

@protocol METestManagerDelegate <NSObject>

@required
- (void) testUpdated:(METest*) metest;
@end

@interface METestManager : NSObject <MEMapViewDelegate>

@property (nonatomic, retain) NSMutableArray* meTestCategories;
@property (nonatomic, retain) MEMapViewController* meMapViewController;
@property (nonatomic, retain) id<METestManagerDelegate> meTestManagerDelegate;
@property (nonatomic, retain) IBOutlet UILabel* lblCopyrightNotice;

- (void) addCategory:(METestCategory*) newCategory;
- (METestCategory*) categoryFromIndex:(int) categoryIndex;
- (METestCategory*) categoryFromName:(NSString*) categoryName;
- (METest*) testFromCategory:(int) categoryIndex testIndex:(int)testIndex;
- (METest*) testFromCategoryName:(NSString*) categoryName withTestName:(NSString*) testName;
- (void) setCopyrightNotice:(NSString*) copyrightNotice;
- (void) testUpdated:(METest*) meTest;
- (void) stopEntireCategoryWithName:(NSString*) categoryName;
- (void) stopEntireCategory:(METestCategory*) category;
- (void) createAllTests;
- (void) backgroundCreateAllTests;
- (void) createVectorTests;
- (void) createMiscTests;
- (void) createMapZOrderUpTests;
- (void) createMapZOrderDownTests;

@end


