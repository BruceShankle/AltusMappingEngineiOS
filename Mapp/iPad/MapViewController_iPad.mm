//
//  MapViewController_iPad.mm
//  Mapp
//
//  Created by Edwin B Shankle III on 10/4/11.
//  Copyright 2011 BA3, LLC. All rights reserved.
//

#import "MapViewController_iPad.h"
#import "AnnotationPopoverViewController_iPad.h"
#import "../Database/AviationDatabase.h"
#import "../METests/METestViewControllers.h"

using namespace AviationData;

@interface MapViewController_iPad ()
@property (nonatomic, retain) UIPopoverController *mapsPopover;
@property (nonatomic, retain) UIPopoverController *optionsPopover;
@property (nonatomic, retain) UIPopoverController *annotationPopover;
@property (nonatomic, retain) UIPopoverController *testsPopover;
@end

@implementation MapViewController_iPad

@synthesize testsPopover;
@synthesize optionsPopover;
@synthesize annotationPopover = _annotationPopover;
@synthesize mapsPopover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //__popover = [[UIPopoverController alloc] initWithContentViewController:[super mapSelectorTableViewController]];
    }
    return self;
}

-(void)dealloc {
    self.optionsPopover = nil;
    self.testsPopover = nil;
    self.mapsPopover = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void) didClickTests:(id)sender
{
    [super didClickTests:(id)sender];
    
    //Create a set up category controller
    METestCategoriesController* categoriesController =
    [[[METestCategoriesController alloc]initWithStyle:UITableViewStylePlain
                                       andTestManager:self.meTestManager]autorelease];
    
    //Create a navigation controller
    UINavigationController* navController =
    [[[UINavigationController alloc]initWithRootViewController:categoriesController] autorelease];
    
    //Create popover
    if(self.testsPopover==nil)
    {
        self.testsPopover =
        [[UIPopoverController alloc] initWithContentViewController:navController];
		
    }
	else
	{
		[self.testsPopover setContentViewController:navController];
	}
	
    //Show popover
    [self.testsPopover presentPopoverFromBarButtonItem:[self btnTests]
                              permittedArrowDirections:UIPopoverArrowDirectionUp
                                              animated:YES];
	
	//self.testsPopover.contentViewController.view.superview.superview.superview.alpha = 0.5;
     
}

- (void) didClickMaps:(id)sender
{
	[super didClickMaps:sender];
	
    if(self.mapsPopover==nil)
    {
        self.mapsPopover = [[UIPopoverController alloc] initWithContentViewController:[super mapSelectorTableViewController]];
    }
	else
	{
		[self.mapsPopover setContentViewController:[super mapSelectorTableViewController]];
	}
	
    [self.mapsPopover presentPopoverFromBarButtonItem:[self btnMaps] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end
