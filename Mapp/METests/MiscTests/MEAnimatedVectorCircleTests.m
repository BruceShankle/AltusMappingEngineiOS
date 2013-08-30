//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import "MEAnimatedVectorCircleTests.h"
#import "../METestCategory.h"
#import "../METestConsts.h"

@implementation MEAnimatedVectorCircleTests

- (id) init
{
	if(self = [super init])
	{
		self.name = @"Animated Vector Circles";
	}
	return self;
}


- (void) start
{
	if(self.isRunning)
		return;
	
	
	MELineStyle* lineStyle = [[[MELineStyle alloc]init]autorelease];
	lineStyle.strokeColor = [UIColor redColor];
	lineStyle.strokeWidth = 4;
	lineStyle.outlineColor = [UIColor whiteColor];
	lineStyle.outlineWidth = 4;
	
	MEAnimatedVectorCircle* circle = [[[MEAnimatedVectorCircle alloc]init]autorelease];
	circle.name = @"RDUCircle";
	circle.location = RDU_COORD;
	circle.lineStyle = lineStyle;
	circle.zOrder = 999;
	circle.minRadius = 5;
	circle.maxRadius = 100;
	circle.fade = NO;
	circle.animationDuration = 5;
	circle.repeatDelay = 0.5;
	circle.segmentCount = 36;
	[self.meMapViewController addAnimatedVectorCircle:circle];
	
	self.isRunning = YES;
}

- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeAnimatedVectorCircle:@"RDUCircle"];
	self.isRunning = NO;
}
@end

/////////////////////////////////////////////////////////////////
@implementation MEAnimatedVectorCircleWorldSpace

- (id) init
{
	if(self = [super init])
	{
		self.name = @"Vector Circle World Space";
	}
	return self;
}


- (void) start
{
	if(self.isRunning)
		return;
	
	
	MELineStyle* lineStyle = [[[MELineStyle alloc]init]autorelease];
	lineStyle.strokeColor = [UIColor redColor];
	lineStyle.strokeWidth = 4;
	lineStyle.outlineColor = [UIColor whiteColor];
	lineStyle.outlineWidth = 4;
	
	MEAnimatedVectorCircle* circle = [[[MEAnimatedVectorCircle alloc]init]autorelease];
	circle.name = @"RDUCircle100";
	circle.location = RDU_COORD;
	circle.lineStyle = lineStyle;
	circle.zOrder = 999;
	circle.useWorldSpace = YES;
	circle.minRadius = 100;
	circle.maxRadius = 100;
	circle.fade = NO;
	circle.animationDuration = 1;
	circle.repeatDelay = 0;
	circle.segmentCount = 36;
	[self.meMapViewController addAnimatedVectorCircle:circle];
	
	self.isRunning = YES;
}

- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeAnimatedVectorCircle:@"RDUCircle100"];
	self.isRunning = NO;
}


@end
