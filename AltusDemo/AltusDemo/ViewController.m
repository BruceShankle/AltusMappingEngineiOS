//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "ViewController.h"
#import "Tests/METestViewControllers.h"

@interface ViewController ()

@end

@implementation ViewController

- (void) initializeMappingEngine {
    
	//Create view controller
    self.meMapViewController = [[MEMapViewController alloc]init];
    
	//Create view
	self.meMapView=[[MEMapView alloc]init];
    self.meMapView.name = @"Main view";
	
    //Assign view to view controller
	self.meMapViewController.view = self.meMapView;
	
	//Add the map view as a sub view to our main view and size it.
	[self.view addSubview:self.meMapView];
    [self.view sendSubviewToBack:self.meMapView];
    
	self.meMapView.frame = self.view.bounds;
    self.meMapView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
    
    self.meMapViewController.verboseMessagesEnabled = YES;
    
	//Initialize the map view controller
	[self.meMapViewController initialize];
    
    //If you have an actual license from BA3, set your license key just after engine initialization
    //[self.meMapViewController setLicenseKey:@"YOURLICE-NSEK-EYGO-ESIN-THISFUNCTION"];
    
    
    
    //Enable level biasing which makes the mapping engine
    //display a consistent level at all times (at the cost of additional memory)
    self.meMapViewController.meMapView.tileBiasSmoothingEnabled = YES;
    self.meMapViewController.meMapView.tileLevelBias = 1.0;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //Initialize mapping engine
    [self initializeMappingEngine];
    
    //Initialize test system
    self.meTestManager = [[METestManager alloc]initWithMEMapViewController:self.meMapViewController];
    
    //Turn on terrain base map
    [self.meTestManager startInitialTest];
    
}

- (UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnTestsTappediPad:(id)sender {
    
    
    //Create a set up category controller
    METestCategoriesController* categoriesController =
    [[METestCategoriesController alloc]initWithStyle:UITableViewStylePlain
                                       andTestManager:self.meTestManager];
    
    //Create a navigation controller
    UINavigationController* navController =
    [[UINavigationController alloc]initWithRootViewController:categoriesController];
    
    //Create popover
    if(self.testsPopover==nil){
        self.testsPopover =
        [[UIPopoverController alloc] initWithContentViewController:navController];
    }
	else{
		[self.testsPopover setContentViewController:navController];
	}
	
    //Show popover
    [self.testsPopover presentPopoverFromBarButtonItem:self.btnTests
                              permittedArrowDirections:UIPopoverArrowDirectionAny
                                              animated:YES];
	
}

- (void) handleDoneButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnTestsTappediPhone:(id)sender {
	//Create a set up category controller
    METestCategoriesController* categoriesController =
    [[METestCategoriesController alloc]initWithStyle:UITableViewStylePlain
                                       andTestManager:self.meTestManager];
    
    //Create a navigation controller
    UINavigationController* navController =
    [[UINavigationController alloc]initWithRootViewController:categoriesController];
    
    UIBarButtonItem *doneButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(handleDoneButton)];
    
    categoriesController.navigationItem.leftBarButtonItem = doneButton;
    
    self.meMapViewController.paused = YES;
    [self presentViewController:navController animated:YES completion:nil];
}

@end
