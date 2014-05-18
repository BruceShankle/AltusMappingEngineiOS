//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "../METest.h"
#import "../METestCategory.h"
#import "../METestManager.h"
#import <Foundation/Foundation.h>

@interface MultiView : METest <MEDynamicMarkerMapDelegate>
@property (retain) MEMapViewController* meMapViewController1;
@property (retain) MEMapViewController* meMapViewController2;
@property (retain) MEMapView* meMapView1;
@property (retain) MEMapView* meMapView2;
@property (retain) METestManager* testManager1;
@property (retain) METestManager* testManager2;
@property (retain) UIButton* testButton1;
@property (retain) UIButton* testButton2;
@property (retain) UIPopoverController* testPopover1;
@property (retain) UIPopoverController* testPopover2;

@end
