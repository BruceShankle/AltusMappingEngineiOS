//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import "MEInternetTileProvider.h"
#import "MEFileDownloader.h"

@implementation MEInternetTileProvider
{
	dispatch_queue_t* _serialBackgroundQueues;
}

/////////////////////////////////////////////////////////////////////////
//Base class for internet tile providers
-(MEInternetTileProvider*) init
{
	self = [super init];
    if ( self )
	{
		self.mapDomain = @"";
		self.shortName = @"shortname";
		self.tileCacheRoot = @"tilecache";
        self.returnUIImages = YES;
		self.copyrightNotice = @"No copyright notice";
		self.tilesNotNeededCount = 0;
		self.serialQueueCount = 4;
		self.currentSerialQueue = 0;
		_serialBackgroundQueues = NULL;
    }
    return self;
}


- (void) createSerialQueues
{
	if(_serialBackgroundQueues)
		return;
	
	_serialBackgroundQueues = (dispatch_queue_t*)malloc(self.serialQueueCount * sizeof(dispatch_queue_t));
	
	for(int i=0; i<self.serialQueueCount; i++)
	{
		NSString* qname = [NSString stringWithFormat:@"%@_%d",
						   self.shortName, i];
		_serialBackgroundQueues[i] = dispatch_queue_create(qname.UTF8String, DISPATCH_QUEUE_SERIAL);
		
	}
}

- (void) deleteSerialQueues
{
	if(!_serialBackgroundQueues)
		return;
	
	for(int i=0; i<self.serialQueueCount; i++)
	{
		dispatch_release(_serialBackgroundQueues[i]);
	}
	
	free(_serialBackgroundQueues);
	_serialBackgroundQueues = NULL;
}

- (void) setIsAsynchronous:(BOOL)isAsynchronous
{
	if(!self.isAsynchronous)
	{
		if(isAsynchronous)
		{
			[self createSerialQueues];
		}
		[super setIsAsynchronous:isAsynchronous];
	}
}

- (void) dealloc
{
    self.mapDomain = nil;
	self.shortName = nil;
	self.tileCacheRoot = nil;
	self.copyrightNotice = nil;
	[self deleteSerialQueues];
    [super dealloc];
}

- (NSString*) tileURLForX:(int) X
						Y:(int) Y
					 Zoom:(int) Zoom
{
	NSLog(@"MEInternetTileProvider:tileURLForX:Y:Zoom:You should override this function.");
	exit(0);
}

- (NSString*) tileFileExtension
{
	return @"png";
}

- (NSString*) cacheFileNameForX:(int) X
							  Y:(int) Y
						   Zoom:(int) Zoom
{
	//Create target cache folder?
	NSError *error;
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* cachePath = [NSString stringWithFormat:@"%@/%@/%@",
						   [[DirectoryInfo sharedDirectoryInfo] GetCacheDirectory],
						   self.tileCacheRoot,
						   self.shortName];
    
	if([fileManager fileExistsAtPath:cachePath]==NO)
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:cachePath
								  withIntermediateDirectories:YES
												   attributes:nil
														error:&error];
	}
	
	NSString* fileName;
    fileName = [NSString stringWithFormat:@"%@/%d_%d_%d.%@",
				cachePath,
				Zoom,
				X,
				Y,
				[self tileFileExtension]];
	
	return fileName;
}

- (BOOL) downloadTileFromURL:(NSString*) url toFileName:(NSString*) fileName
{
	return [MEFileDownloader downloadSync:url toFile:fileName];
}

- (void) requestTile:(METileProviderRequest*) meTileRequest
{
	//Check to make sure we still need to supply the tile.
	if(![super isNeeded:meTileRequest])
	{
		if(self.isAsynchronous)
		{
			[super tileLoadComplete:meTileRequest];
			@synchronized(self)
			{
				self.tilesNotNeededCount++;
			}
		}
		else
		{
			self.tilesNotNeededCount++;
		}
		return;
	}
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* fileName;
	
	for(MESphericalMercatorTile* tile in meTileRequest.sphericalMercatorTiles)
	{
		//Tile is still needed so let's start downloading it.
		fileName=[self cacheFileNameForX:tile.slippyX
									   Y:tile.slippyY
									Zoom:tile.slippyZ];
		
		if([fileManager fileExistsAtPath:fileName]==NO)
		{
			if(![self downloadTileFromURL:[self tileURLForX:tile.slippyX
														  Y:tile.slippyY
													   Zoom:tile.slippyZ]
							   toFileName:fileName])
			{
				//For downloads that fail, show the gray grid
				meTileRequest.isProxy = YES;
				meTileRequest.isOpaque = YES;
				meTileRequest.isDirty = YES;
				meTileRequest.cachedImageName = @"grayGrid";
				meTileRequest.tileProviderResponse = kTileResponseRenderNamedCachedImage;
				if(self.isAsynchronous)
				{
					[super tileLoadComplete:meTileRequest];
				}
				return;
			}
		}
		tile.fileName = fileName;
		
		if(self.returnUIImages)
		{
			tile.uiImage = [UIImage imageWithContentsOfFile:fileName];
			tile.fileName = nil;
		}
	}
	
	meTileRequest.isOpaque = YES;
	meTileRequest.tileProviderResponse = kTileResponseRenderFilename;
	if(self.returnUIImages)
	{
		meTileRequest.tileProviderResponse = kTileResponseRenderUIImage;
	}
	
	if(self.isAsynchronous)
	{
		[super tileLoadComplete:meTileRequest];
	}
}

- (void) requestTileAsync:(METileProviderRequest *)meTileRequest
{
	int currentQueue=0;
	@synchronized(self)
	{
		currentQueue = self.currentSerialQueue;
		self.currentSerialQueue++;
		if(self.currentSerialQueue>self.serialQueueCount-1)
			self.currentSerialQueue=0;
	}
	
	dispatch_async(_serialBackgroundQueues[currentQueue], ^{
		[self requestTile:meTileRequest];
	});
}

@end

/////////////////////////////////////////////////////////////////////////////////
@implementation MEMapBoxTileProvider

-(MEMapBoxTileProvider*) init
{
	self = [super init];
    if ( self )
	{
		self.mapDomain = @"a.tiles.mapbox.com/v3/mapbox.mapbox-streets";
		self.shortName = @"mapbox";
		self.copyrightNotice = @"Source: MapBox, LLC";
    }
    return self;
}

- (NSString*) tileFileExtension
{
	return @"png";
}

- (NSString*) tileURLForX:(int) X Y:(int) Y Zoom:(int) Zoom
{
	return [NSString stringWithFormat:@"http://%@/%d/%d/%d.%@",
			self.mapDomain,
			Zoom,
			X,
			Y,
			[self tileFileExtension]];
}

@end

/////////////////////////////////////////////////////////////////////////////////
@implementation MEMapBoxMarsTileProvider

-(MEMapBoxTileProvider*) init
{
	self = [super init];
    if ( self )
	{
		self.mapDomain = @"a.tiles.mapbox.com/v3/herwig.map-siz5m7we";
		self.shortName = @"mapboxmars";
		self.copyrightNotice = @"Source: MapBox, LLC";
    }
    return self;
}

@end

/////////////////////////////////////////////////////////////////////////////////
@implementation MEMapBoxLandCoverTileProvider
-(MEMapBoxLandCoverTileProvider*) init
{
	self = [super init];
    if ( self )
	{
		self.mapDomain = @"a.tiles.mapbox.com/v3/examples.map-4l7djmvo";
		self.shortName = @"mapboxlandcover";
		self.returnUIImages = YES;
		self.copyrightNotice = @"Source: MapBox, LLC http://www.mapbox.com";
    }
    return self;
}

- (NSString*) tileFileExtension
{
	return @"png";
}

- (NSString*) tileURLForX:(int) X Y:(int) Y Zoom:(int) Zoom
{
	
	return [NSString stringWithFormat:@"http://%@/%d/%d/%d.%@",
			self.mapDomain,
			Zoom,
			X,
			Y,
			[self tileFileExtension]];
	
}

@end

/////////////////////////////////////////////////////////////////////////////////
@implementation MEMapQuestTileProvider

-(MEMapQuestTileProvider*) init
{
	self = [super init];
    if ( self )
	{
		self.mapDomain = @"otile1.mqcdn.com/tiles/1.0.0/osm";
		self.shortName = @"mapquest";
		self.copyrightNotice = @"Tiles courtesy of MapQuest: http://www.mapquest.com. © OpenStreetMap contributors";
		self.returnUIImages = YES;
    }
    return self;
}
@end

/////////////////////////////////////////////////////////////////////////////////
@implementation MEMapQuestAerialTileProvider

-(MEMapQuestAerialTileProvider*) init
{
	self = [super init];
    if ( self )
	{
		self.mapDomain = @"otile1.mqcdn.com/tiles/1.0.0/sat";
		self.shortName = @"mapquestaerial";
		self.returnUIImages = NO;
		self.copyrightNotice = @"Tiles courtesy of MapQuest: http://www.mapquest.com. Portions Courtesy NASA/JPL-Caltech and U.S. Depart. of Agriculture, Farm Service Agency.";
    }
    return self;
}

- (NSString*) tileFileExtension
{
	return @"jpg";
}

@end


/////////////////////////////////////////////////////////////////////////////////
@implementation MEStamenTerrainTileProvider

-(MEStamenTerrainTileProvider*) init
{
	self = [super init];
    if ( self )
	{
		self.mapDomain = @"tile.stamen.com/terrain";
		self.shortName = @"stamenterrain";
		self.returnUIImages = YES;
		self.copyrightNotice = @"Map tiles by Stamen Design, under CC BY 3.0. Data by OpenStreetMap, under CC BY SA.";
    }
    return self;
}

@end


/////////////////////////////////////////////////////////////////////////////////
@implementation MEOpenStreetMapsTileProvider
-(MEOpenStreetMapsTileProvider*) init
{
	self = [super init];
    if ( self )
	{
		self.mapDomain = @"tile.openstreetmap.org";
		self.shortName = @"openstreetmaps";
		self.copyrightNotice = @"© OpenStreetMap contributors";
    }
    return self;
}
@end
