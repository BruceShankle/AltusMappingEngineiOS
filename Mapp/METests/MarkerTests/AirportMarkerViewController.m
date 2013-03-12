//
//  AirportMarkerViewController.m
//  Mapp
//
//  Created by Nik Donets on 8/2/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "AirportMarkerViewController.h"

@interface AirportMarkerViewController ()

@end

@implementation AirportMarkerViewController

@synthesize markerLabel;
@synthesize markerText = _markerText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)refreshView
{
    if( markerLabel )
    {
        markerLabel.text = _markerText;
    }
}

- (void)setMarkerText:(NSString *)markerText
{
    if(_markerText)
    {
        [_markerText release];
    }
    
    _markerText = markerText;
    [_markerText retain];
    
    [self refreshView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshView];
}

- (void)viewDidUnload
{
    [self setMarkerLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc 
{
    [markerLabel release];
    [_markerText release];
    [super dealloc];
}
@end
