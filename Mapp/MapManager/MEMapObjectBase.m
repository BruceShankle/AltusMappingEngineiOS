//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <ME/ME.h>
#import "MEMapObjectBase.h"
#include "MapManagerConsts.h"

@implementation MEMapObjectBase

@synthesize Name;
@synthesize Path;
@synthesize Category;
@synthesize MapFileName;
@synthesize MapIndexFileName;
@synthesize Enabled;
@synthesize NoDisable;

-(id) initWithName:(NSString*) name andPath:(NSString*) path
{
	self = [super init];
    if (self) {
		self.Name=name;
		self.Path=path;
	}
    return self;
}

-(id) initWithName:(NSString*) name andCategory:(NSString*) category andPath:(NSString*) path
{
	self = [super init];
    if (self) {
		self.Name=name;
		self.Path=path;
		self.Category=category;
		self.MapFileName=[MEMapObjectBase mapFileNameForCategory:category map:name];
		self.MapIndexFileName=[MEMapObjectBase mapIndexFileNameForCategory:category map:name];
	}
    return self;
}

-(void) dealloc
{
	self.Name = nil;
	self.Path = nil;
	self.Category = nil;
	self.MapFileName = nil;
	self.MapIndexFileName = nil;
	[super dealloc];
}


+(NSString*) GetMapsPath
{
	return [NSString stringWithFormat:@"%@/%@",
			[[DirectoryInfo sharedDirectoryInfo] GetDocumentsDirectory],
			MAPCACHEFOLDER]; //See MEConsts.h
}

+(NSString*) GetCategoryPath:(NSString*) category
{
	return [NSString stringWithFormat:@"%@/%@", [MEMapObjectBase GetMapsPath], category];
}

+(NSString*) GetMapPath:(NSString*) category map:(NSString*) map
{
	return [NSString stringWithFormat:@"%@/%@", [self GetCategoryPath:category], map];
}

+(NSString*) mapPathForCategory:(NSString*) category mapName:(NSString*) map
{
	return [NSString stringWithFormat:@"%@/%@", [MEMapObjectBase GetCategoryPath:category], map];
}

+(NSString*)  mapFileNameForCategory:(NSString*) category map:(NSString*) map
{
	return [NSString stringWithFormat:@"%@.%@", [self GetMapPath:category map:map], MAPFILEEXTENSION];
}

+(NSString*) mapIndexFileNameForCategory:(NSString*) category map:(NSString*) map
{
	return [NSString stringWithFormat:@"%@.%@", [self GetMapPath:category map:map], MAPINDEXFILEEXTENSION];
}

+(void) createMapCategory:(NSString*) category
{
	NSString* categoryPath=[MEMapObjectBase GetCategoryPath:category];
	[MEMapObjectBase createDirectory:categoryPath];
}

+(void) createDirectory:(NSString*) path
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath:path]==NO)
	{
		[fileManager createDirectoryAtPath:path
			   withIntermediateDirectories:YES
								attributes:nil
									 error:nil];
	}
}
@end
