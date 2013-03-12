//
//  MBTilesTileProvider.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/22/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MBTilesTileProvider.h"


@implementation MBTilesTileProvider
{
	dispatch_queue_t _workQueue;
}
@synthesize databaseName = _databaseName;
@synthesize database = _database;

- (id) initWithDatabaseName:(NSString *)databaseName
{
	if(self=[super init])
	{
		self.databaseName = databaseName;
		NSString* dbPath = [[NSBundle mainBundle] pathForResource:self.databaseName
														   ofType:@"mbtiles"];
		self.database = [FMDatabase databaseWithPath:dbPath];
		[self.database open];
		_workQueue = dispatch_queue_create(self.databaseName.UTF8String, DISPATCH_QUEUE_SERIAL);
		self.isAsynchronous = YES;
	}
	return self;
}


- (void) dealloc
{
	dispatch_release(_workQueue);
    self.databaseName = nil;
	[_database release];
    [super dealloc];
}

//This is an example of an asyncrhonous tile provider, note how
//access to the database is serialized via a queue
- (void) requestTileAsync:(METileInfo*) tileinfo
{
	if(self.database == nil)
	{
		tileinfo.tileProviderResponse = kTileResponseNotAvailable;
		[self.meMapViewController tileLoadComplete:tileinfo];
	}
	else
	{
		__block MBTilesTileProvider* blockSelf = self;
		[blockSelf retain];
		
		
		dispatch_async(_workQueue, ^{
			
			tileinfo.isOpaque = NO;
			uint flippedY = pow(2, tileinfo.slippyZ) - tileinfo.slippyY - 1;
			
			NSString* sql = [NSString stringWithFormat:@"SELECT tile_data FROM tiles WHERE zoom_level=%d AND tile_column=%d and tile_row=%d",
							 tileinfo.slippyZ,
							 tileinfo.slippyX,
							 flippedY];
			
			FMResultSet *s = [blockSelf.database executeQuery:sql];
			if([s next])
			{
				tileinfo.nsImageData = [s dataForColumn:@"tile_data"];
				tileinfo.imageDataType= kImageDataTypePNG;
				tileinfo.tileProviderResponse = kTileResponseRenderImageData;
			}
			else
			{
				tileinfo.tileProviderResponse = kTileResponseNotAvailable;
			}
			
			//Get reference to main queue
			__block dispatch_queue_t mainQueue;
			mainQueue=dispatch_get_main_queue();
			dispatch_retain(mainQueue);
			
			dispatch_async(mainQueue, ^{
				[blockSelf.meMapViewController tileLoadComplete:tileinfo];
				[blockSelf release];
				dispatch_release(mainQueue);
			});
		});
		
	}
	
}

//This is an example of a syncrhonous tile provider, note how
//access to the database is synchronized
-(void) requestTile:(METileInfo *)tileInfo
{
	if(self.database == nil)
	{
		tileInfo.tileProviderResponse = kTileResponseNotAvailable;
	}
	else
	{
		@synchronized(self.database)
		{
			tileInfo.isOpaque = NO;
			uint flippedY = pow(2, tileInfo.slippyZ) - tileInfo.slippyY - 1;
			
			NSString* sql = [NSString stringWithFormat:@"SELECT tile_data FROM tiles WHERE zoom_level=%d AND tile_column=%d and tile_row=%d",
							 tileInfo.slippyZ,
							 tileInfo.slippyX,
							 flippedY];
			
			FMResultSet *s = [self.database executeQuery:sql];
			if([s next])
			{
				tileInfo.nsImageData = [s dataForColumn:@"tile_data"];
				tileInfo.imageDataType= kImageDataTypePNG;
				tileInfo.tileProviderResponse = kTileResponseRenderNSData;
			}
			else
			{
				tileInfo.tileProviderResponse = kTileResponseNotAvailable;
			}
		}
	}
}

@end
