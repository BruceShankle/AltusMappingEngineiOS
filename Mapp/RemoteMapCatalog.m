//
//  RemoteMapCatalog.m
//  Mapp
//
//  Created by Edwin B Shankle III on 7/13/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "RemoteMapCatalog.h"

@implementation RemoteMapCatalog
@synthesize streamableMapArray;
@synthesize mapCount;

-(id) init
{
	self=[super init];
	if(self)
	{
		NSError* error;
		//Load streamable maps from JSON file
		NSString* jsonFileName = [[NSBundle mainBundle] pathForResource:@"MapCatalog" ofType:@"json"];
		NSString* fileString=[NSString stringWithContentsOfFile:jsonFileName encoding:NSUTF8StringEncoding error:&error];
		
		if ( nil == fileString )
		{
			NSLog(@"No maps in catalog.");
			exit(1);
		}
		
		self.streamableMapArray = [fileString objectFromJSONString];
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(int) mapCount
{
	return self.streamableMapArray.count;
}

- (NSString*) mapName:(int) index
{
	NSDictionary* dict = [self.streamableMapArray objectAtIndex:index];
	return [dict objectForKey:@"mapname"];
}

- (NSString*) mapDomain:(int) index
{
	NSDictionary* dict = [self.streamableMapArray objectAtIndex:index];
	NSString* url = [dict objectForKey:@"url"];
	NSString* mapDomain = [url substringFromIndex:7]; //Get name without http://
	return mapDomain;
}

- (RemoteMapInfo) mapInfo:(int)index
{
	NSDictionary* dict = [self.streamableMapArray objectAtIndex:index];
	NSNumber* borderSize = [dict objectForKey:@"bordersize"];
	NSNumber* zorder = [dict objectForKey:@"zorder"];
	NSNumber* maxLevel = [dict objectForKey:@"maxLevel"];
	NSNumber* minX = [dict objectForKey:@"minX"];
	NSNumber* minY = [dict objectForKey:@"minY"];
	NSNumber* maxX = [dict objectForKey:@"maxX"];
	NSNumber* maxY = [dict objectForKey:@"maxY"];
	RemoteMapInfo mapInfo;
	mapInfo.borderSize = borderSize.intValue;
	mapInfo.zorder = zorder.intValue;
	mapInfo.maxLevel = maxLevel.intValue;
	mapInfo.minX = minX.doubleValue;
	mapInfo.minY = minY.doubleValue;
	mapInfo.maxX = maxX.doubleValue;
	mapInfo.maxY = maxY.doubleValue;
	return mapInfo;
}



@end
