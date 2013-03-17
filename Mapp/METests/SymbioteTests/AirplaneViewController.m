//
//  AirplaneViewController.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/22/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "AirplaneViewController.h"
#import "AirplaneView.h"

@interface AirplaneViewController ()

@end

@implementation AirplaneViewController
@synthesize lblMessage;
@synthesize centerCoordinate = _centerCoordinate;

- (MELocationCoordinate2D) centerCoordinate
{
    return _centerCoordinate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark MESymbiote impl.
- (void) setCenterCoordinate:(MELocationCoordinate2D)newCenterCoordinate
{
    _centerCoordinate = newCenterCoordinate;
}

- (void) updateScreenPosition:(CGPoint) newPosition
{
    CLLocationCoordinate2D c2d;
    c2d.longitude = 2.0;
    
    AirplaneView* av=(AirplaneView*)self.view;
    av.center = newPosition;
    self.lblMessage.text = [NSString stringWithFormat:@"x=%f\ny=%f",
                            newPosition.x,
                            newPosition.y];
}

@end
