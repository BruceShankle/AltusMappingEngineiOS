//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MEKMLShapes.h"
#import "MESimpleKMLReader.h"

@implementation MECaliforniaPolygon

- (id) init
{
	if(self=[super init])
	{
		self.name = @"California Polygon";
	}
	return self;
}

- (void) start
{
	if(self.isRunning)
		return;
	
	//Read points for polygon
	NSString* fileName = [[NSBundle mainBundle] pathForResource:@"california"
										   ofType:@"txt"];
	NSMutableArray* polygonPoints = [MESimpleKMLReader readPointsFromFile:fileName];
	
	//Create polygon style
	MEPolygonStyle* polygonStyle=[[[MEPolygonStyle alloc]init]autorelease];
    polygonStyle.strokeColor = [UIColor greenColor];
    polygonStyle.fillColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
    polygonStyle.strokeWidth = 3;
	
	//Add vector map
	MEVectorMapInfo* vectorMapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
	vectorMapInfo.name = self.name;
	vectorMapInfo.zOrder = 50;
	[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
	
	//Add polygon to vector map
	[self.meMapViewController addPolygonToVectorMap:self.name
											 points:polygonPoints
											  style:polygonStyle];
	
	self.isRunning = YES;
}

- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeMap:self.name clearCache:YES];
	self.isRunning = NO;
}
@end
