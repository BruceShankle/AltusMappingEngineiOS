//  Copyright (c) 2013 BA3, LLC. All rights reserved.

#import "BoundingBoxReader.h"
#include <fstream>
#include <sstream>
using namespace std;

@implementation GeoBoundingBox
@end

@implementation BoundingBoxReader


+(NSMutableArray*) loadDataFromFile:(NSString*) filePath
{
	NSMutableArray* boundingBoxes = [[[NSMutableArray alloc]init]autorelease];
	MEPolygonStyle* polygonStyle=[[[MEPolygonStyle alloc]init]autorelease];
    polygonStyle.strokeColor = [UIColor redColor];
	polygonStyle.outlineWidth = 1;
	polygonStyle.outlineColor = [UIColor redColor];
    polygonStyle.strokeWidth = 1;
	
	ifstream file(filePath.UTF8String);
	
	string line;
	
	
	while (file.good())
	{
		getline(file,line);
		if (!file.good()) break;
		istringstream ss(line);
		
			double lon1, lat1, lon2, lat2;
			char singlechar;
			ss >> singlechar >> lat1 >> singlechar >> lon1 >> singlechar >> singlechar >> singlechar >> lat2 >> singlechar >> lon2;
			GeoBoundingBox* box = [[GeoBoundingBox alloc]init];
			box.lowerLeft = CLLocationCoordinate2DMake(lat1, lon1);
			box.upperRight = CLLocationCoordinate2DMake(lat2, lon2);
			[boundingBoxes addObject:box];
			[box release];
			if (!ss.good()) break;
			

	}
	
	return boundingBoxes;
}


@end
