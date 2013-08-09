//
//  MECoreTests.m
//  Mapp
//
//  Created by Bruce Shankle III on 9/21/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MECoreTests.h"
#import "../METestManager.h"


///////////////////////////////////////////////////////
@implementation METileLevelBiasSmoothingTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Level Bias Smoothing";
	}
    return self;
}

- (BOOL) isRunning
{
	return self.meMapViewController.meMapView.tileBiasSmoothingEnabled;
}

- (void) userTapped
{
	self.meMapViewController.meMapView.tileBiasSmoothingEnabled = !self.meMapViewController.meMapView.tileBiasSmoothingEnabled;
}

- (void) start {}
- (void) stop {}

@end

///////////////////////////////////////////////////////
@implementation METileLevelBiasTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Level Bias";
	}
    return self;
}

- (NSString*) label
{
	return [NSString stringWithFormat:@"%f", self.meMapViewController.meMapView.tileLevelBias];
}

- (void) userTapped
{
	double bias = self.meMapViewController.meMapView.tileLevelBias;
	bias += 0.25;
	if (bias > 1.0)
		bias = 0;
	
	self.meMapViewController.meMapView.tileLevelBias = bias;
	
}

- (void) start {}
- (void) stop {}

@end

///////////////////////////////////////////////////////
@implementation MEChangeCacheSizeTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Cache Size";
	}
    return self;
}

- (NSString*) label
{
	return [NSString stringWithFormat:@"%lu MB",
			self.meMapViewController.coreCacheSize / 1000000];
}

- (void) userTapped
{
	unsigned long newCacheSize = self.meMapViewController.coreCacheSize;
	
	switch(self.meMapViewController.coreCacheSize)
	{
		case 90000000:
		case 50000000:
			newCacheSize -= 40000000;
			break;
		default:
			newCacheSize = 90000000;
			break;
	}
	
	[self.meMapViewController shutdown];
	self.meMapViewController.coreCacheSize = newCacheSize;
	[self.meMapViewController initialize];
	
}

- (void) start {}
- (void) stop {}

@end

///////////////////////////////////////////////////////
@implementation MEInitializationTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Initialization";
	}
    return self;
}

- (NSString*) label
{
	if(self.meMapViewController.isRunning)
		return @"Stop";
	return @"Start";
}

- (void) userTapped
{
	if(self.meMapViewController.isRunning)
	{
		[self.meMapViewController shutdown];
	}
	else
	{
		[self.meMapViewController initialize];
		
		//Allow zooming in very close
		self.meMapViewController.meMapView.minimumZoom=0.00003;
		
		//Add default tiles
		[self.meMapViewController addCachedImage:[UIImage imageNamed:@"grayGrid"]
										withName:@"grayGrid"
								 compressTexture:YES];
		
		[self.meMapViewController addCachedImage:[UIImage imageNamed:@"noData"]
										withName:@"noData"
								 compressTexture:YES];
		
		//Set maximum virtual tile parent search depth
		self.meMapViewController.maxVirtualMapParentSearchDepth = 5;
		
		//Set tile bias level
		self.meMapViewController.meMapView.tileLevelBias = 1.0;
		
		self.meMapViewController.meMapView.tileBiasSmoothingEnabled = YES;
		
	}
	[super userTapped];
}

- (void) start {}
- (void) stop {}

@end

///////////////////////////////////////////////////////
@implementation MERemoveAllMapsClearCacheTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Remove All Maps (Clear Cache)";
	}
    return self;
}

- (void) userTapped
{
	[self.meMapViewController removeAllMaps:YES];
}

- (void) start {}
- (void) stop {}

@end

///////////////////////////////////////////////////////
@implementation METoggleMultiThreadingTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Multithreaded";
	}
    return self;
}

- (void) userTapped
{	
	self.meMapViewController.multiThreaded = !self.meMapViewController.multiThreaded;
}

- (BOOL) isRunning
{
	return self.meMapViewController.multiThreaded;
}

- (void) start {}
- (void) stop {}

@end

///////////////////////////////////////////////////////
@implementation METoggleAntialiasingTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Antialiasing";
	}
    return self;
}

- (void) userTapped
{
	if(self.isRunning)
		[self.meMapViewController unsetRenderMode:MERenderAntialiasing];
	else
		[self.meMapViewController setRenderMode:MERenderAntialiasing];
}

- (BOOL) isRunning
{
	return [self.meMapViewController isRenderModeSet:MERenderAntialiasing];
}

- (void) start {}
- (void) stop {}

@end

///////////////////////////////////////////////////////
@implementation METoggleDisableDisplayListTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Disable Display List";
	}
    return self;
}

- (void) userTapped
{
	if(self.isRunning)
		[self.meMapViewController unsetRenderMode:MEDisableDisplayList];
	else
		[self.meMapViewController setRenderMode:MEDisableDisplayList];
}

- (BOOL) isRunning
{
	return [self.meMapViewController isRenderModeSet:MEDisableDisplayList];
}

- (void) start {}
- (void) stop {}

@end

///////////////////////////////////////////////////////
@implementation METogglePanDecelerationTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Pan Deceleration";
	}
    return self;
}

- (void) userTapped
{
	//Toogle the setting
	self.meMapViewController.meMapView.isPanDecelerationEnabled =
	!self.meMapViewController.meMapView.isPanDecelerationEnabled;
}

- (BOOL) isRunning
{
	return self.meMapViewController.meMapView.isPanDecelerationEnabled;
}

- (void) start {}
- (void) stop {}

@end

///////////////////////////////////////////////////////
@implementation MESetPanDecelerationTest
{
	int _currentTest;
}

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Set Pan Deceleration";
		_currentTest = -1;
	}
    return self;
}

- (NSString*) label
{
	return [NSString stringWithFormat:@"%.02f",
			self.meMapViewController.meMapView.panAcceleration];
}

- (void) userTapped
{
	_currentTest++;
	double newDecelValue = -10.0;
	switch(_currentTest)
	{
		case 0:
			newDecelValue = -5.0;
			break;
		case 1:
			newDecelValue = -2.5;
			break;
		case 2:
			newDecelValue = -1.25;
			break;
		case 3:
			newDecelValue = -0.6;
			break;
		case 4:
			newDecelValue = -0.3;
			break;
		case 5:
			newDecelValue = -0.1;
			break;

		default:
			_currentTest = -1;
			break;
	}
	self.meMapViewController.meMapView.panAcceleration = newDecelValue;
}

- (void) start {}
- (void) stop {}

@end

///////////////////////////////////////////////////////
@implementation MEPanVelocityScaleTest
{
	int _currentTest;
}

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Pan Velocity Scale";
		_currentTest = -1;
	}
    return self;
}

- (NSString*) label
{
	return [NSString stringWithFormat:@"%.02f",
			self.meMapViewController.meMapView.panVelocityScale];
}

- (void) userTapped
{
	_currentTest++;
	double newVelocityScale = 1.0;
	switch(_currentTest)
	{
		case 0:
			newVelocityScale = 0.75;
			break;
		case 1:
			newVelocityScale = 0.50;
			break;
		case 2:
			newVelocityScale = 0.25;
			break;
		case 3:
			newVelocityScale = 0.1;
			break;
			
		default:
			_currentTest = -1;
			break;
	}
	self.meMapViewController.meMapView.panVelocityScale = newVelocityScale;
}

- (void) start {}
- (void) stop {}

@end

