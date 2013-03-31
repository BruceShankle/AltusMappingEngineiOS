//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "METilesNotAvailableTest.h"


//////////////////////////////////////////////////////////////////////
@implementation MEXYZTileProvider

- (void) requestTile:(METileProviderRequest *)meTileRequest
{
	meTileRequest.tileProviderResponse = self.response;
	if(self.response == kTileResponseNotAvailable)
	{
		self.response = kTileResponseRenderUIImage;
		return;
	}
	
	for(MESphericalMercatorTile* tile in meTileRequest.sphericalMercatorTiles)
	{
		NSString* labelText = [NSString stringWithFormat:@" %d,%d,%d ",
							   tile.slippyX,
							   tile.slippyY,
							   tile.slippyZ];
		UIImage* uiImage;
		uiImage = [[MEFontUtil createImageWithFontOutlined:@"Arial"
												  fontSize:20
												 fillColor:[UIColor whiteColor]
											   strokeColor:[UIColor blackColor]
											   strokeWidth:0
													  text:labelText]autorelease];
		
		switch(self.response)
		{
			case kTileResponseRenderUIImage:
				tile.uiImage = uiImage;
				meTileRequest.isOpaque = NO;
				break;
				
			case kTileResponseRenderNamedCachedImage:
				tile.cachedImageName = @"noData";
				meTileRequest.isDirty = YES;
				break;
				
			default:
				break;
		}
		
		
	}
	
	
	
}

@end


//////////////////////////////////////////////////////////////////////
@implementation MEOnOffTileProvider

-(id) init
{
	if(self=[super init])
	{
		self.isAsynchronous = NO;
		self.response = kTileResponseRenderUIImage;
		self.currentTile = 0;
	}
	return self;
}

- (void) requestTile:(METileProviderRequest *)meTileRequest
{
	meTileRequest.tileProviderResponse = self.response;
	
	if(self.response == kTileResponseNotAvailable)
		return;
	
	
	NSString* imageName = [NSString stringWithFormat:@"tile_%d", self.currentTile];
	
	switch(self.response)
	{
		case kTileResponseRenderUIImage:
			meTileRequest.isOpaque = NO;
			meTileRequest.uiImage = [UIImage imageNamed:imageName];
			break;
			
		case kTileResponseRenderNamedCachedImage:
			meTileRequest.cachedImageName = @"noData";
			meTileRequest.isDirty = YES;
			break;
			
		default:
			break;
	}
	
	
	self.currentTile = 0;
}

@end

//////////////////////////////////////////////////////////////////////
@implementation METilesNotAvailableTest

-(id) init
{
	if(self=[super init])
	{
		self.name=@"Tiles Not Available";
	}
	return self;
}


- (NSString*) buttonLabel
{
	switch(self.tileProvider.response)
	{
		case kTileResponseNotAvailable:
			return @"kTileResponseNotAvailable";
			break;
			
		case kTileResponseRenderUIImage:
			return @"kTileResponseRenderUIImage";
			break;
			
		case kTileResponseRenderNamedCachedImage:
			return @"kTileResponseRenderNamedCachedImage";
			break;
			
		default:
			return @"";
			break;
	}
}

- (void) toggleOnOff
{
	switch(self.tileProvider.response)
	{
		case kTileResponseRenderUIImage:
			self.tileProvider.response = kTileResponseRenderNamedCachedImage;
			break;
			
		case kTileResponseRenderNamedCachedImage:
			self.tileProvider.response = kTileResponseNotAvailable;
			break;
			
		case kTileResponseNotAvailable:
			self.tileProvider.response = kTileResponseRenderUIImage;
			break;
			
		default:
			break;
	}
	
	[self.btnOnOff setTitle:[self buttonLabel] forState:UIControlStateNormal];
}

- (void) politelyRefresh
{
	[self.meMapViewController refreshDirtyTiles:self.name];
}

-(void) createTileProvider
{
	self.tileProvider = [[[MEOnOffTileProvider alloc]init]autorelease];
	self.tileProvider.meMapViewController = self.meMapViewController;
}

- (void) start
{
	if(self.isRunning)
		return;
	
	//Cache a noData tile
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"noData"]
									withName:@"noData"
							 compressTexture:NO];
	
	[self createTileProvider];
	
	MEVirtualMapInfo* vmapInfo=[[[MEVirtualMapInfo alloc]init]autorelease];
	vmapInfo.name = self.name;
	vmapInfo.zOrder = 20;
	vmapInfo.meTileProvider = self.tileProvider;
	vmapInfo.maxLevel = 20;
	vmapInfo.defaultTileName = @"grayGrid";
	[self.meMapViewController addMapUsingMapInfo:vmapInfo];
	
	
	self.btnOnOff = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.btnOnOff addTarget:self
					  action:@selector(toggleOnOff)
			forControlEvents:UIControlEventTouchDown];
	[self.btnOnOff setTitle:[self buttonLabel] forState:UIControlStateNormal];
	self.btnOnOff.frame = CGRectMake(10.0, 250.0, 350.0, 40.0);
	[self.meMapViewController.meMapView addSubview:self.btnOnOff];
	[self.meMapViewController.meMapView bringSubviewToFront:self.btnOnOff];
	
	self.btnRefreshDirtyTiles = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.btnRefreshDirtyTiles addTarget:self
								  action:@selector(politelyRefresh)
						forControlEvents:UIControlEventTouchDown];
	[self.btnRefreshDirtyTiles setTitle:@"refreshDirtyTiles" forState:UIControlStateNormal];
	self.btnRefreshDirtyTiles.frame = CGRectMake(10.0, 300.0, 160.0, 40.0);
	[self.meMapViewController.meMapView addSubview:self.btnRefreshDirtyTiles];
	[self.meMapViewController.meMapView bringSubviewToFront:self.btnRefreshDirtyTiles];
	
	self.isRunning = YES;
}

- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self.btnOnOff removeFromSuperview];
	[self.btnRefreshDirtyTiles removeFromSuperview];
	
	[self.meMapViewController removeMap:self.name clearCache:YES];
	self.isRunning = NO;
}

@end

//////////////////////////////////////////////////////////////////////
@implementation METilesNotAvailableXYZTest

-(id) init
{
	if(self=[super init])
	{
		self.name=@"Tiles Not Available XYZ";
	}
	return self;
}

-(void) createTileProvider
{
	self.tileProvider = [[[MEXYZTileProvider alloc]init]autorelease];
	self.tileProvider.meMapViewController = self.meMapViewController;
}

@end
