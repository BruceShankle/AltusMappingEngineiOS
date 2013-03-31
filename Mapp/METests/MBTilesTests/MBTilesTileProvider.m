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
- (void) requestTileAsync:(METileProviderRequest*) meTileRequest
{
	if(self.database == nil)
	{
		meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
		[self.meMapViewController tileLoadComplete:meTileRequest];
	}
	else
	{

		//Assume isOpaque and we'll have NSData
		meTileRequest.isOpaque = NO;
		meTileRequest.tileProviderResponse = kTileResponseRenderNSData;
		
		dispatch_async(_workQueue, ^{
			
			for(MESphericalMercatorTile* tile in meTileRequest.sphericalMercatorTiles)
			{
				uint flippedY = pow(2, tile.slippyZ) - tile.slippyY - 1;
				
				NSString* sql = [NSString stringWithFormat:@"SELECT tile_data FROM tiles WHERE zoom_level=%d AND tile_column=%d and tile_row=%d",
								 tile.slippyZ,
								 tile.slippyX,
								 flippedY];
				
				FMResultSet *s = [self.database executeQuery:sql];
				if([s next])
				{
					tile.nsImageData = [s dataForColumn:@"tile_data"];
					tile.imageDataType= kImageDataTypePNG;
				}
				else
				{
					NSLog(@"Tile not found: X:%d, Y:%d (flippedY:%d) Z:%d",
						  tile.slippyX, tile.slippyY, flippedY, tile.slippyZ);
					//meTileRequest.tileProviderResponse = kTileResponseTransparentWithChildren;
					meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
					break;
				}
			}
			
			//Load complete
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.meMapViewController tileLoadComplete:meTileRequest];
			});
		});
		
	}
	
}

//This is an example of a syncrhonous tile provider, note how
//access to the database is synchronized
-(void) requestTile:(METileProviderRequest *)meTileRequest
{
	if(self.database == nil)
	{
		meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
	}
	else
	{
		@synchronized(self.database)
		{
			meTileRequest.isOpaque = NO;
			meTileRequest.tileProviderResponse = kTileResponseRenderNSData;
			for(MESphericalMercatorTile* tile in meTileRequest.sphericalMercatorTiles)
			{
				uint flippedY = pow(2, tile.slippyZ) - tile.slippyY - 1;
				
				NSString* sql = [NSString stringWithFormat:@"SELECT tile_data FROM tiles WHERE zoom_level=%d AND tile_column=%d and tile_row=%d",
								 tile.slippyZ,
								 tile.slippyX,
								 flippedY];
				
				FMResultSet *s = [self.database executeQuery:sql];
				if([s next])
				{
					tile.nsImageData = [s dataForColumn:@"tile_data"];
					tile.imageDataType= kImageDataTypePNG;
				}
				else
				{
					meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
					return;
				}
			}
			
		}
	}
}

@end
