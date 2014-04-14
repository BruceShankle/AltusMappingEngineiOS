//  Copyright (c) 2014 BA3, LLC. All rights reserved.

#import <UIKit/UIKit.h>
#import "METestManager.h"

@interface METestCategoriesController : UITableViewController <UITableViewDataSource>
@property (nonatomic, retain) METestManager* meTestManager;

- (id) initWithStyle:(UITableViewStyle)style
      andTestManager:(METestManager*) testManager;
@end

@interface METestCategoryController : METestCategoriesController
@property (nonatomic, retain) METestCategory* meTestCategory;
- (id) initWithStyle:(UITableViewStyle)style
      andTestManager:(METestManager*) testManager
         andCategory:(METestCategory*) testCategory;

@end
