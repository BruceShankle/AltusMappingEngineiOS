//
//  METest.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/16/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "METest.h"
#import "METestManager.h"
#import "METestCategory.h"

@implementation METest
@synthesize meTestManager;
@synthesize meTestCategory;
@synthesize timer;
@synthesize name;
@synthesize isRunning;
@synthesize isEnabled;
@synthesize interval;
@synthesize repeats;
@synthesize meMapViewController;
@synthesize uiLabel;
@synthesize label;
@synthesize bestFontSize;

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Some Test";
        self.label = @"";
        self.interval = 1;
        self.isRunning = NO;
        self.repeats = YES;
		self.bestFontSize = 18.0f;
    }
    return self;
}

- (void) dealloc
{
    self.meTestManager = nil;
	self.meTestCategory = nil;
    self.name = nil;
    self.label = nil;
    if(self.timer!=nil)
    {
        [self.timer invalidate];
    }
    self.timer=nil;
    self.meMapViewController = nil;
    [super dealloc];
}

- (void) startTimer
{
	self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
	NSRunLoop *runloop = [NSRunLoop currentRunLoop];
	[runloop addTimer:self.timer forMode:NSRunLoopCommonModes];
	[runloop addTimer:self.timer forMode:UITrackingRunLoopMode];
}

- (void) start
{
	if(self.isRunning)
		return;
	
	[self startTimer];
    self.isRunning = YES;
	self.meTestCategory.lastTestStarted = self;
	[self.meTestManager testUpdated:self];
}

- (void) userTapped
{
    if(!self.isRunning)
        [self start];
    else
        [self stop];
	
	[self.meTestManager testUpdated:self];
}

- (void) stopTimer
{
	if(self.timer!=nil)
    {
        [self.timer invalidate];
		self.timer = nil;
    }
}

- (void) stop
{
	if(!self.isRunning)
		return;
    [self stopTimer];
    self.isRunning = NO;
	[self removeStatusLabel];
	[self.meTestManager testUpdated:self];
}

- (void) timerTick
{
    NSLog(@"METest timer ticked.");
}

- (NSString*) uiLabel
{
    if(self.label.length==0)
        return self.name;
    else
    {
        return [NSString stringWithFormat:@"%@ (%@)", self.name, self.label];
    }
}

- (void) wasUpdated
{
    [self.meTestManager testUpdated:self];
}

+ (NSString*) getDocumentsPath
{
    NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                 NSUserDomainMask,
                                                                 YES);
    NSString* documentPath = [documentPaths objectAtIndex:0];
    return documentPath;
}

+ (NSString*) getCachePath
{
    NSArray*  cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                               NSUserDomainMask,
                                                               YES);
    NSString* cachePath = [cachePaths objectAtIndex:0];
    return cachePath;
}

- (BOOL) isEnabled
{
    return YES;
}

- (BOOL) isOtherTestRunning:(NSString*) testName
{
	METest* otherTest = [self.meTestCategory testWithName:testName];
	if(otherTest==nil)
	{
		NSLog(@"%@ is not a valid test name.", testName);
		exit(1);
	}
	return otherTest.isRunning;
}

-(void) lookAtSanFrancisco
{
    [self.meMapViewController.meMapView lookAtCoordinate:CLLocationCoordinate2DMake(37.75, -122.6)
                                           andCoordinate:CLLocationCoordinate2DMake(37.75, -122.3)
                                    withHorizontalBuffer:0
                                      withVerticalBuffer:0
                                       animationDuration:1.0];
}

- (void) addStatusLabel
{
	self.lblStatus = [[[UILabel alloc]init]autorelease];
	CGRect frame;
	frame.origin.x=self.meMapViewController.meMapView.frame.size.width-300;
	frame.origin.y=0;
	frame.size.width = 300;
	frame.size.height = 50;
	self.lblStatus.frame = frame;
	[self.meMapViewController.meMapView addSubview:self.lblStatus];
}

- (void) setStatusLabelText:(NSString *)newText
{
	if(self.lblStatus)
		[self.lblStatus setText:newText];
}

- (void) removeStatusLabel
{
	if(self.lblStatus!=nil)
	{
		[self.lblStatus removeFromSuperview];
		self.lblStatus=nil;
	}
}

-(void) lookAtUnitedStates
{
    [self.meMapViewController.meMapView lookAtCoordinate:CLLocationCoordinate2DMake(37.246798, -126.554263)
                                           andCoordinate:CLLocationCoordinate2DMake(34.648367, -72.814862)
                                    withHorizontalBuffer:0
                                      withVerticalBuffer:0
                                                animationDuration:1.0];
}

-(void) lookAtGuam
{
    [self.meMapViewController.meMapView lookAtCoordinate:CLLocationCoordinate2DMake(12, 144)
                                           andCoordinate:CLLocationCoordinate2DMake(14, 145)
                                    withHorizontalBuffer:0
                                      withVerticalBuffer:0
									   animationDuration:1.0];
}

//-96.584681

-(void) lookAtAtlantic
{
    [self.meMapViewController.meMapView lookAtCoordinate:CLLocationCoordinate2DMake(28.393784, -96.584681)
                                           andCoordinate:CLLocationCoordinate2DMake(17.045695, 5.319083)
                                    withHorizontalBuffer:0
                                      withVerticalBuffer:0
                                                animationDuration:1.0];
}

@end
