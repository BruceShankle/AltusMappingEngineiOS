//
//  MEClearColorTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 10/2/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MEClearColorTest.h"

@implementation MEClearColorTest
{
	int _testIndex;
}
- (id) init
{
    if(self = [super init])
	{
        self.name=@"Clear Color";
		_testIndex = 0;
	}
    return self;
}

- (NSString*) label
{
	switch(_testIndex)
	{
		case 0:
			return @"Black";
			break;
		case 1:
			return @"Dark Gray";
			break;
		case 2:
			return @"Blue";
			break;
		case 3:
			return @"Red";
			break;
		case 4:
			return @"White";
			break;
		default:
			return @"";
			break;
	}
}

- (void) userTapped
{
	_testIndex++;
	if(_testIndex>4)
		_testIndex=0;
	
	UIColor* color;
	switch(_testIndex)
	{
		case 0:
			color = [UIColor blackColor];
			break;
		case 1:
			color = [UIColor darkGrayColor];
			break;
		case 2:
			color = [UIColor blueColor];
			break;
		case 3:
			color = [UIColor redColor];
			break;
		case 4:
			color = [UIColor whiteColor];
			break;
		default:
			color = [UIColor blackColor];
			break;
	}
	
	self.meMapViewController.meMapView.clearColor = color;
}

- (void) start {}
- (void) stop {}

@end
