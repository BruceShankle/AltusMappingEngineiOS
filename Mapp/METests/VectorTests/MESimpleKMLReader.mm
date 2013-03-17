//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MESimpleKMLReader.h"

#include <fstream>
#include <sstream>
#include <iostream>

using namespace std;

@implementation MESimpleKMLReader

+ (NSMutableArray*) readPointsFromFile:(NSString*) fileName
{
	NSMutableArray* points = [[[NSMutableArray alloc]init]autorelease];
	ifstream file(fileName.UTF8String);
	string line;
	line.resize(1000);
	
	while (file.good())
	{
		file.getline(&line[0], line.size(), ' ');
		istringstream ss(line);
		if (ss.good())
		{
			double lon, lat;
			char comma;
			ss >> lon >> comma >> lat;
			cout << line << ": " << lon << ", " << lat << endl;
			[points addObject:[NSValue valueWithCGPoint:CGPointMake(lon, lat)]];
		}
	}
	
	return points;
}
@end
