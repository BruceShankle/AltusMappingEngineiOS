//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MESparseTileMapTest.h"

//This test demonstrates a virtual map with a sparse tile set
//where some leaf nodes are at higher levels than other leaf nodes.
//When a leaf node is not available, the mapping engine will
//appropriately sample from parent node in the tile tree

@implementation MESparseMapTileProvider

- (void) requestTile:(METileProviderRequest *)meTileRequest
{
	//Select a tile based on level
	MESphericalMercatorTile* firstTile = [meTileRequest.sphericalMercatorTiles objectAtIndex:0];
	
	int tileNumber = firstTile.slippyZ % 5;
	NSString* imageFileName = [NSString stringWithFormat:@"lettertile%d", tileNumber];
	NSString* imagePath = [[NSBundle mainBundle] pathForResource:imageFileName ofType:@"png"];
	
	int i = arc4random_uniform(5);
	if(i==0)
	{
		for(MESphericalMercatorTile* tile in meTileRequest.sphericalMercatorTiles)
		{
			tile.nsImageData = [NSData dataWithContentsOfFile:imagePath];
			tile.imageDataType = kImageDataTypePNG;
			meTileRequest.tileProviderResponse = kTileResponseRenderNSData;
			meTileRequest.isDirty = NO;
		}
	}
	else
	{
		for(MESphericalMercatorTile* tile in meTileRequest.sphericalMercatorTiles)
		{
			meTileRequest.tileProviderResponse = kTileResponseRenderNamedCachedImage;
			meTileRequest.isProxy = YES;
			meTileRequest.cachedImageName = @"noData";
		}
	}
}

@end

@implementation MESparseTileMapTest

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Sparse Tiles";
	}
	return self;
}

- (void) start
{
	if(self.isRunning)
		return;
	
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"grayGrid"] withName:@"grayGrid" compressTexture:NO];
	
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"noData"] withName:@"noData" compressTexture:NO];
	
	MESparseMapTileProvider* tileProvider = [[[MESparseMapTileProvider alloc]init]autorelease];
	tileProvider.meMapViewController = self.meMapViewController;
	
	MEVirtualMapInfo* mapInfo = [[[MEVirtualMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.meTileProvider = tileProvider;
	mapInfo.zOrder = 100;
	mapInfo.defaultTileName = @"grayGrid";
	mapInfo.maxLevel = 20;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	self.isRunning = YES;
}

- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeMap:self.name clearCache:YES];
	
	self.isRunning = NO;
}

@end
