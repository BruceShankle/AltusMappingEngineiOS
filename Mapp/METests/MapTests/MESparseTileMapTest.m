//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MESparseTileMapTest.h"

//This test demonstrates a virtual map with a sparse tile set
//where some leaf nodes are at higher levels than other leaf nodes.
//When a leaf node is not available, the mapping engine will
//appropriately sample from parent node in the tile tree

@implementation MESparseMapTileProvider

- (void) requestTile:(METileInfo *)tileInfo
{
	//Select a tile based on level
	int tileNumber = tileInfo.slippyZ % 5;
	NSString* imageFileName = [NSString stringWithFormat:@"lettertile%d", tileNumber];
	NSString* imagePath = [[NSBundle mainBundle] pathForResource:imageFileName ofType:@"png"];
	
	int i = arc4random_uniform(5);
	if(i==0)
	{
		tileInfo.nsImageData = [NSData dataWithContentsOfFile:imagePath];
		tileInfo.tileProviderResponse = kTileResponseRenderNSData;
		tileInfo.imageDataType = kImageDataTypePNG;
		tileInfo.isDirty = NO;
	}
	else
	{
		tileInfo.tileProviderResponse = kTileResponseRenderNamedCachedImage;
		tileInfo.isProxy = YES;
		tileInfo.cachedImageName = @"noData";
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
