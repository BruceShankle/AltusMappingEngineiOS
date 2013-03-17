//
//  MEShapeFileTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 10/26/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MEShapeFileTest.h"

@implementation MEShapeFileTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"ESRI Shape File";
	}
	return self;
}

- (void) start
{
    self.isRunning = YES;
	NSString* shapeFilePath;
	shapeFilePath = [[NSBundle mainBundle] pathForResource:@"tgr48171lkA"
									ofType:@"shp"];
	
	//Create a style
	MELineStyle* lineStyle=[[[MELineStyle alloc]init]autorelease];
    lineStyle.strokeColor = [UIColor blackColor];
    lineStyle.strokeWidth = 4;
	
	//Add an in-memory vector map
	MEVectorMapInfo* vectorMapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
	vectorMapInfo.name = self.name;
	vectorMapInfo.zOrder = 100;
	[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
	
	//Add shape file to vector map
	[self.meMapViewController addShapeFileToVectorMap:self.name
										shapeFilePath:shapeFilePath
												 style:lineStyle];
}

- (void) stop
{
	[self.meMapViewController removeMap:self.name
										   clearCache:YES];
	self.isRunning = NO;
}

@end
