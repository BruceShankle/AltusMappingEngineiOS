//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import "MEMap.h"
#import "MapManagerConsts.h"
#import <ME/ME.h>
@implementation MEMap
@synthesize IsBaseMap;
@synthesize IsTerrainMap;
@synthesize IsVirtualMap;

-(id) initWithName:(NSString*) name andCategory:(NSString*) category andPath:(NSString*) path
{
	self =[super initWithName:name andCategory:category andPath:path];
    if (self) {
		[[DirectoryInfo sharedDirectoryInfo] addSkipBackupAttributeToItemAtPath:self.MapFileName];
		[[DirectoryInfo sharedDirectoryInfo] addSkipBackupAttributeToItemAtPath:self.MapIndexFileName];
	}
    return self;
}

@end
