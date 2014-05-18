//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "MultiView.h"
#import "../METestViewControllers.h"

@implementation MultiView


- (id) init {
	if(self=[super init]){
		self.name = @"Multi View";
	}
	return self;
}

- (UIPopoverController*)invokeTestManager:(METestManager*) testManager
                                   inView:(UIView*) view
                                   button:(UIButton*) button
                                  popOver:(UIPopoverController*) popover{
    
    
    //Create a set up category controller
    METestCategoriesController* categoriesController =
    [[METestCategoriesController alloc]initWithStyle:UITableViewStylePlain
                                      andTestManager:testManager];
    
    //Create a navigation controller
    UINavigationController* navController =
    [[UINavigationController alloc]initWithRootViewController:categoriesController];
    
    //Create popover
    if(popover==nil){
        popover =
        [[UIPopoverController alloc] initWithContentViewController:navController];
    }
	else{
		[popover setContentViewController:navController];
	}
	
    //Show popover
    [popover presentPopoverFromRect:button.frame
                             inView:view
           permittedArrowDirections:UIPopoverArrowDirectionAny
                           animated:YES];
    
    return popover;
	
}

- (void) testButton1Tapped{
    self.testPopover1 = [self invokeTestManager:self.testManager1
                                         inView:self.meMapViewController1.view
                                         button:self.testButton1
                                        popOver:self.testPopover1];
}

- (void) testButton2Tapped{
    self.testPopover2 = [self invokeTestManager:self.testManager2
                                         inView:self.meMapViewController2.view
                                         button:self.testButton2
                                        popOver:self.testPopover2];
}

- (UIButton*) addTestButton:(UIView*) parentView
                      title:(NSString*) title
                     action:(SEL)action {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:action
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    
    float width = 125;
    float height = 50;
    float x = 5;
    float y = parentView.bounds.size.height - height*2;
    button.frame = CGRectMake(x, y, width, height);
    button.backgroundColor = [UIColor whiteColor];
    [parentView addSubview:button];
    
    button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    
    button.layer.cornerRadius = 5;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = button.titleLabel.textColor.CGColor;
    //button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:35];
    
    return button;
    
}

- (void) addMultipleMapViews:(UIView*) parentView{
    
    //Early exit - already called
    if(self.meMapViewController1 != nil ||
       self.meMapViewController2 != nil){
        return;
    }

    float subViewHeight = parentView.bounds.size.height / 2;
    float subViewWidth = parentView.bounds.size.width;
    float yOffset = subViewHeight;
    float xOffset = 0;
    if(parentView.bounds.size.width > parentView.bounds.size.height){
        subViewHeight = parentView.bounds.size.height;
        subViewWidth = parentView.bounds.size.width / 2;
        yOffset = 0;
        xOffset = subViewWidth;
    }
    
    //Compute frames for new views
    CGRect frame1 = CGRectMake(parentView.bounds.origin.x,
                               parentView.bounds.origin.y,
                               subViewWidth,
                               subViewHeight);
    
    CGRect frame2 = CGRectMake(parentView.bounds.origin.x+xOffset,
                               parentView.bounds.origin.y+yOffset,
                               subViewWidth,
                               subViewHeight);
    
    
    //Create view controllers and views
    self.meMapViewController1 = [[MEMapViewController alloc]init];
    self.meMapViewController2 = [[MEMapViewController alloc]init];
    self.meMapViewController1.preferredFramesPerSecond = 30;
    self.meMapViewController2.preferredFramesPerSecond = 30;
    self.meMapView1 = [[MEMapView alloc]initWithFrame:frame1];
    self.meMapView2 = [[MEMapView alloc]initWithFrame:frame2];
	self.meMapViewController1.view = self.meMapView1;
	self.meMapViewController2.view = self.meMapView2;
    
	//Add the map view as sub-views to the parent.
	[parentView addSubview:self.meMapView1];
    [parentView addSubview:self.meMapView2];
    
    //Set resizing masks
    self.meMapView1.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    
    //Set resizing masks
    self.meMapView2.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
	
    //Set names
    self.meMapView1.name = @"View 1";
    self.meMapView2.name = @"View 2";
    
	//Initialize the map view controllers
	[self.meMapViewController1 initialize];
    [self.meMapViewController2 initialize];
    
    //Enable level biasing which makes the mapping engine
    //display a consistent level at all times (at the cost of additional memory)
    self.meMapViewController1.meMapView.tileBiasSmoothingEnabled = YES;
    self.meMapViewController1.meMapView.tileLevelBias = 1.0;
    self.meMapViewController2.meMapView.tileBiasSmoothingEnabled = YES;
    self.meMapViewController2.meMapView.tileLevelBias = 1.0;
    
    //Create some test managers to drive the views
    self.testManager1 = [[METestManager alloc]initWithMEMapViewController:self.meMapViewController1];
    self.testManager2 = [[METestManager alloc]initWithMEMapViewController:self.meMapViewController2];
    
    [self.testManager1 startInitialTest];
    [self.testManager2 startInitialTest];
    
    self.testButton1 = [self addTestButton:self.meMapViewController1.view
                                     title:@"Tests"
                                    action:@selector(testButton1Tapped)];
    
    self.testButton2 = [self addTestButton:self.meMapViewController2.view
                                     title:@"Tests"
                                    action:@selector(testButton2Tapped)];
    
    
}


- (void) removeUI{
    
}

- (void) removeMultipleMapViews{
    //Stop all tests
    [self.testManager1 stopAllTests];
    [self.testManager2 stopAllTests];
    //Shut down the view controllers
    [self.meMapViewController1 shutdown];
    [self.meMapViewController2 shutdown];
    //Remove the views
    [self.meMapViewController1.view removeFromSuperview];
    [self.meMapViewController2.view removeFromSuperview];
    self.meMapViewController1 = nil;
    self.meMapViewController2 = nil;
    //Remove UI
    [self removeUI];
}

- (void) start{
	if(self.isRunning){
		return;
	}
    //Stop all other tests
    [self.meTestManager stopAllTests];
    
    //Shut down the main view
    [self.meMapViewController shutdown];
    
    //Add 2 new map controller views
    [self addMultipleMapViews:self.meMapViewController.view];
    
	self.isRunning = YES;
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
    
    [self removeMultipleMapViews];
    
    //Reinitialize main view
    [self.meMapViewController initialize];
    
    //Turn on terrain base map
    [self.meTestManager startTestInCategory:@"Terrain" withName:@"Earth"];
    
	self.isRunning = NO;
}

@end
