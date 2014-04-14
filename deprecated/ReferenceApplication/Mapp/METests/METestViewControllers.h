//
//  TestCategoryTableViewController.h
//  Mapp
//
//  Created by Bruce Shankle III on 9/3/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "METestManager.h"

@interface METestCategoriesController : UITableViewController <UITableViewDataSource>
@property (nonatomic, retain) METestManager* meTestManager;

- (id) initWithStyle:(UITableViewStyle)style
      andTestManager:(METestManager*) testManager;

@end

@interface METestCategoryController : METestCategoriesController <METestManagerDelegate>
@property (nonatomic, retain) METestCategory* meTestCategory;
- (id) initWithStyle:(UITableViewStyle)style
      andTestManager:(METestManager*) testManager
         andCategory:(METestCategory*) testCategory;

@end
