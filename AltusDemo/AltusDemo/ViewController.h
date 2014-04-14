//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import <UIKit/UIKit.h>
#import <AltusMappingEngine/AltusMappingEngine.h>
#import "Tests/METestManager.h"

@interface ViewController : UIViewController
@property (retain) MEMapViewController* meMapViewController;
@property (retain) MEMapView* meMapView;
@property (retain) METestManager* meTestManager;
@property (retain) UIPopoverController *testsPopover;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnTests;

- (IBAction)btnTestsTappediPad:(id)sender;
- (IBAction)btnTestsTappediPhone:(id)sender;
@end
