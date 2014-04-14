//
//  ClippingPlaneTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 10/12/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "ClippingPlaneTest.h"

@implementation ClippingPlaneTest
@synthesize slider;

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Adjust Clipping Plane";
	}
	return self;
}

- (void) dealloc
{
	self.slider = nil;
	[super dealloc];
}

- (void) start
{
	if(self.isRunning)
		return;
	
	CGRect frame = self.meMapViewController.meMapView.bounds;
	frame.size.height = 60;
	self.slider = [[[UISlider alloc]initWithFrame:frame]autorelease];
	self.slider.minimumValue = 0;
	self.slider.maximumValue = 1;
	
	[self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.meMapViewController.meMapView addSubview:self.slider];
	self.isRunning = YES;
}

- (IBAction) sliderValueChanged:(UISlider *)sender
{
	[self.meMapViewController setClippingPlaneValue:sender.value];
}

- (void) stop
{
	[self.slider removeFromSuperview];
	self.slider=nil;
	self.isRunning = NO;
}

@end



