//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import "MEMapCategory.h"
#import "MEMap.h"
#import "MapManagerConsts.h"


@implementation MEMapCategory
@synthesize Maps;
@synthesize IsTerrainCategory;

-(id) initWithName:(NSString*) name andPath:(NSString*) path
{
	self = [super initWithName:name andPath:path];
    if (self) {
		self.Maps=[[[NSMutableArray alloc]init]autorelease];
		self.Enabled=YES;
		
		if([self.Name isEqualToString:TERRAINMAPSCATEGORY])
		{
			self.IsTerrainCategory=YES;
		}
		else
		{
			self.IsTerrainCategory=NO;
		}
	}
    return self;
}

-(void) dealloc
{
	if(self.Maps!=nil)
	{
		[self.Maps removeAllObjects];
		[self.Maps release];
	}
	[super dealloc];
}

-(void) scanMaps
{
	self.Maps=[[[NSMutableArray alloc]init]autorelease];
	NSError *error;
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.Path error:&error];
	if(dirContents)
	{
		for(NSString *str in dirContents)
		{
			NSString* ext=[str pathExtension];
			NSString* mapName;
			if([ext isEqualToString:MAPINDEXFILEEXTENSION])
			{
				mapName = [str stringByDeletingPathExtension];
				NSString* mapPath=[MEMapObjectBase GetMapPath:self.Name map:mapName];
				
				//Ensure map file exists
				if([[NSFileManager defaultManager] fileExistsAtPath:[MEMapObjectBase mapFileNameForCategory:self.Name map:mapName]])
				{
					MEMap* newMap=[[[MEMap alloc] initWithName:mapName andCategory:self.Name andPath:mapPath]autorelease];
					if([self.Name isEqualToString:BASEMAPSCATEGORY])
						newMap.IsBaseMap=YES;
					else
						newMap.IsBaseMap=NO;
					if([self.Name isEqualToString:TERRAINMAPSCATEGORY])
						newMap.IsTerrainMap=YES;
					else
						newMap.IsTerrainMap=NO;
					
					if([self.Name isEqualToString:VIRTUALMAPSCATEGORY])
					{
						NSLog(@"Virtual map %@",newMap.Name);
						newMap.IsVirtualMap=YES;
					}
					else
						newMap.IsVirtualMap=NO;
					
					//Check persistence to see if map is enabled
					/*int isEnabled=[[NSUserDefaults standardUserDefaults] integerForKey:mapPath];
					if(isEnabled)
					{
						[newMap setEnabled:YES];
					}*/
					
					//[newMap setEnabled:YES];
					[self.Maps addObject:newMap];
				}
				else
				{
					//Remove the invalid index file since there is no cooresponding map file
					[[NSFileManager defaultManager]removeItemAtPath:[MEMapObjectBase mapIndexFileNameForCategory:self.Name map:mapName] error:nil];
				}
			}
		}
	}
	else
	{
		NSLog(@"Error scanning category folder: %@", error);
	}
	
	//If I am the base map category, and I only have 1 base map, then enable it, and me it so that it may not be disabled.
	if([self.Name isEqualToString:BASEMAPSCATEGORY])
	{
		if([self.Maps count]==1)
		{
			MEMap* map=[self.Maps objectAtIndex:0];
			map.Enabled=YES;
			map.NoDisable=YES;
		}
	}
}

-(MEMap*) mapWithName:(NSString*) name
{
	for(MEMap* map in self.Maps)
	{
		if([map.Name isEqualToString:name])
			return map;
	}
	return nil;
}
@end
