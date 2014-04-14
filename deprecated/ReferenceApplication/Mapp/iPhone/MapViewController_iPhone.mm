//
//  MapViewController_iPhone.m
//  Mapp
//
//  Created by Edwin B Shankle III on 10/5/11.
//  Copyright 2011 BA3, LLC. All rights reserved.
//

#import "MapViewController_iPhone.h"
#import "MapSelectorViewController_iPhone.h"
#import "MapSelectorTableViewController.h"
#import "../METests/METestViewControllers.h"

@implementation MapViewController_iPhone
@synthesize navController;

- (void) dealloc
{
    self.navController = nil;
    [super dealloc];
}
- (void) didClickMaps:(id)sender
{
	//Create a map selector table view controller and configure it
	MapSelectorViewController_iPhone* mapSelector=[[MapSelectorViewController_iPhone alloc]initWithNibName:@"MapSelectorViewController_iPhone" bundle:nil];
	mapSelector.meViewController = self.meMapViewController;
    mapSelector.meTestManager = self.meTestManager;
	mapSelector.mapManager = self.mapManager;
    
	mapSelector.presenter=self;
	self.meMapViewController.paused = YES;
    [self presentModalViewController:mapSelector animated:YES];
}

- (void) didClickTests:(id)sender
{
    
    //Create a set up category controller
    METestCategoriesController* categoriesController =
    [[[METestCategoriesController alloc]initWithStyle:UITableViewStylePlain
                                       andTestManager:self.meTestManager]autorelease];
    
    //Create a navigation controller
    navController =
    [[[UINavigationController alloc]initWithRootViewController:categoriesController] autorelease];
    
    UIBarButtonItem *doneButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                     style:UIBarButtonItemStyleDone
                                     target:self
                                    action:@selector(handleDoneButton)];
    
    categoriesController.navigationItem.leftBarButtonItem = doneButton;
    [doneButton release];
    
    self.meMapViewController.paused = YES;
    [self presentModalViewController:navController animated:YES];
}

- (void) handleDoneButton
{
    [self dismissModalViewControllerAnimated:YES];
    self.meMapViewController.paused = NO;
}


//Modal views send a message here when they want to be destroyed
- (void)dismissModalViewController:(NSString *)viewControllerName {
	
	if([viewControllerName isEqualToString:@"MapSelectorViewController_iPhone"])
		self.meMapViewController.paused = NO;
	
	if([viewControllerName isEqualToString:@"OptionsViewController_iPhone"])
		self.meMapViewController.paused = NO;
    
	[super dismissModalViewController:viewControllerName];
}


@end
