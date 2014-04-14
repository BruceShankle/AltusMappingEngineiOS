//
//  RouteMarkerViewController.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/31/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "RouteMarkerViewController.h"

@interface RouteMarkerViewController ()

@end

@implementation RouteMarkerViewController

@synthesize routeLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) updateRouteLabelText:(NSString*) newLabelText
{
    self.routeLabel.text = newLabelText;
}

@end
