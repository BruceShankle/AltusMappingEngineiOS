//
//  MapSelectorViewController_iPhone.m
//  Mapp
//
//  Created by Edwin B Shankle III on 11/2/11.
//  Copyright (c) 2011 BA3, LLC. All rights reserved.
//

#import "MapSelectorViewController_iPhone.h"

@implementation MapSelectorViewController_iPhone

@synthesize meViewController;
@synthesize meTestManager;
@synthesize presenter;
@synthesize btnDone;
@synthesize tblMapList;
@synthesize mapSelectorTableViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	self.mapSelectorTableViewController.meViewController=self.meViewController;
    self.mapSelectorTableViewController.meTestManager = self.meTestManager;
	self.mapSelectorTableViewController.mapManager = self.mapManager;
	[self.tblMapList reloadData];
}

- (void) dealloc
{
	[self.mapSelectorTableViewController release];
	[self.meViewController release];
	[super dealloc];
}

- (IBAction) didClickDone:(id)sender
{
	[presenter dismissModalViewController:@"MapSelectorViewController_iPhone"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
