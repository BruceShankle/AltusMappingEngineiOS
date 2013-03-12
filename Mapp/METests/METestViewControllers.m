//
//  TestCategoryTableViewController.m
//  Mapp
//
//  Created by Bruce Shankle III on 9/3/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "METestViewControllers.h"

@implementation METestCategoriesController

@synthesize meTestManager;

- (id) initWithStyle:(UITableViewStyle)style
      andTestManager:(METestManager*) testManager
{
    if(self = [super initWithStyle:style])
    {
        self.meTestManager = testManager;
        self.navigationItem.title=@"Tests";
		//self.view.alpha = 0.8;
		//self.view.superview.alpha = 0.0;
		//self.view.superview.superview.alpha = 0.0;
		//[self setContentSizeForViewInPopover:CGSizeMake(320, 500)];
    }
    return self;
}

- (void) dealloc
{
    self.meTestManager = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.meTestManager.meTestCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Create a cell.
    UITableViewCell* cell;
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"]autorelease];
    
    METestCategory* testCategory = [self.meTestManager categoryFromIndex:indexPath.row];
    
    [[cell textLabel] setText:testCategory.name];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    METestCategory* testCategory = [self.meTestManager categoryFromIndex:indexPath.row];

    METestCategoryController* categoryController=
    [[METestCategoryController alloc]initWithStyle:UITableViewStylePlain
                                    andTestManager:self.meTestManager
                                       andCategory:testCategory];
    [self.navigationController pushViewController:categoryController animated:YES];
    [categoryController release];
}

@end

///////////////////////////////////////////////////
//Test category controller
@implementation METestCategoryController
@synthesize meTestCategory;

- (id) initWithStyle:(UITableViewStyle)style
      andTestManager:(METestManager*) testManager
         andCategory:(METestCategory *)testCategory

{
    if(self = [super initWithStyle:style andTestManager:testManager])
    {
        self.meTestManager = testManager;
        self.meTestManager.meTestManagerDelegate = self;
        self.meTestCategory = testCategory;
        
    }
    return self;
}

- (void) dealloc
{
    self.meTestCategory = nil;
    
    [super dealloc];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title=self.meTestCategory.name;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(self.meTestCategory.containsDynamicTestArray)
	{
		[self.meTestCategory updateTestArray];
	}
	
    return self.meTestCategory.meTests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Create a cell.
    UITableViewCell* cell;
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
								   reuseIdentifier:@"cell"]autorelease];
    
    METest* meTest = [self.meTestCategory testFromIndex:indexPath.row];
    
    [[cell textLabel] setText:meTest.uiLabel];
	[[cell textLabel] setFont:[UIFont systemFontOfSize:meTest.bestFontSize]];
    
   	if(meTest.isRunning)
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
	else
		[cell setAccessoryType:UITableViewCellAccessoryNone];
    
    cell.userInteractionEnabled = meTest.isEnabled;
    
    if(!meTest.isEnabled)
    {
        
        cell.textLabel.alpha = 0.439216f;
    }
    else
    {
        cell.textLabel.alpha = 1.0f;
    }
	
    return cell;
}


- (void) testUpdated:(METest *)metest
{
    [self.tableView reloadData];
}

- (void) setCheck:(UITableView *)tableView indexPath:(NSIndexPath*) indexPath checked:(BOOL) checked
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(checked)
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else
        [cell setAccessoryType:UITableViewCellAccessoryNone];
}

- (void) setLabelText:(UITableView *)tableView indexPath:(NSIndexPath*) indexPath labelText:(NSString*) labelText
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [[cell textLabel] setText:labelText];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Get the test
    METest* meTest = [self.meTestCategory testFromIndex:indexPath.row];
	if(meTest == nil)
		return;
    
    //Tell test user tapped on it
    [meTest userTapped];
	
    //Update cell check mark
	[self setCheck:tableView indexPath:indexPath checked:meTest.isRunning];
    
    //Update cell text
	[self setLabelText:tableView indexPath:indexPath labelText:meTest.uiLabel];
}


@end

