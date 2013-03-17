//
//  AnnotationPopoverViewController_iPad.m
//  Mapp
//
//  Created by Bruce Shankle on 7/27/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "AnnotationPopoverViewController_iPad.h"

@interface AnnotationPopoverViewController_iPad ()

@end

@implementation AnnotationPopoverViewController_iPad
@synthesize infoLabel;
@synthesize infoText = _infoText;

- (void)refreshView
{
    if( infoLabel )
    {
        infoLabel.text = _infoText;
    }
}

- (void)setInfoText:(NSString *)text
{
    if(_infoText)
    {
        [_infoText release];
    }
    
    _infoText = text;
    [_infoText retain];
    
    [self refreshView];
}

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
    [self refreshView];
}

- (void)viewDidUnload
{
    [self setInfoLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc {
    [infoLabel release];
    [_infoText release];
    [super dealloc];
}
@end
