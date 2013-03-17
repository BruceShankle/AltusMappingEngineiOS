//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import "MapManager.h"
#import "MapManagerConsts.h"
#import <ME/ME.h>

@implementation MapManager
@synthesize mapCategories;

- (id) init
{
	if(self=[super init])
	{
		[self createDirectory:[MEMapObjectBase GetMapsPath]];
		[self refresh];
	}
	return self;
}

- (void) dealloc
{
	self.mapCategories = nil;
	[super dealloc];
}

- (void) refresh
{
	self.mapCategories = [self scanCategories];
}

- (void) createDirectory:(NSString *)path
{
	[MEMapObjectBase createDirectory:path];
}

- (NSArray*) scanCategories
{
	NSMutableArray* categories = [[[NSMutableArray alloc]init]autorelease];
	
	NSString* mapPath = [MEMapObjectBase GetMapsPath];
	
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mapPath error:nil];
	
	for(NSString *str in dirContents)
	{
		BOOL isDirectory;
		NSString* categoryPath = [MEMapObjectBase GetCategoryPath:str];
		
		[[NSFileManager defaultManager] fileExistsAtPath:categoryPath isDirectory:&isDirectory];
		if (isDirectory)
		{
			MEMapCategory* newCategory=[[[MEMapCategory alloc]initWithName:str andPath:categoryPath]autorelease];
			[categories addObject:newCategory];
			[newCategory scanMaps];
		}
	}
	return categories;
}

- (MEMapCategory*) categoryWithName:(NSString*) name
{
	for(MEMapCategory* cat in self.mapCategories)
	{
		if([cat.Name isEqualToString:name])
			return cat;
	}
	return nil;
}


@end
