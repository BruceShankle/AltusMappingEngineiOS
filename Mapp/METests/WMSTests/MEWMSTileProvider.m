//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MEWMSTileProvider.h"
#import "../TileProviderTests/MEFileDownloader.h"

@implementation MEWMSTileProvider


- (id) init {
	if(self=[super init]){
		self.wmsURL = @"";
		self.wmsVersion = @"1.3.0";
		self.wmsLayers =  @"";
		self.wmsSRS = @"EPSG:4326";
		self.wmsFormat = @"image/png";
		self.tileFileExtension = @"png";
		self.isAsynchronous = NO;
		self.tileCacheRoot = @"tilecache";
	}
	return self;
}

- (void) dealloc {
	self.wmsURL = nil;
	self.wmsVersion = nil;
	self.wmsLayers = nil;
	self.wmsSRS = nil;
	self.wmsFormat = nil;
	self.tileCacheRoot = nil;
	self.tileFileExtension = nil;
	self.shortName = nil;
	[super dealloc];
}

- (NSString*) cacheFileNameForRequest:(METileProviderRequest*) meTileProviderRequest {
	
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
    fileName = [NSString stringWithFormat:@"%@/%lld.%@",
				cachePath,
				meTileProviderRequest.uid,
				self.tileFileExtension];
	
	return fileName;
	
}

- (NSString*) tileURLForRequest:(METileProviderRequest*) meTileProviderRequest {
	NSMutableArray* requestParams = [[[NSMutableArray alloc]init]autorelease];
	
	[requestParams addObject:[NSString stringWithFormat:@"VERSION=%@",
							  self.wmsVersion]];
	[requestParams addObject:[NSString stringWithFormat:@"LAYERS=%@",
							  self.wmsLayers]];
	[requestParams addObject:[NSString stringWithFormat:@"SRS=%@",
							  self.wmsSRS]];
	[requestParams addObject:[NSString stringWithFormat:@"FORMAT=%@",
							  self.wmsFormat]];
	[requestParams addObject:@"SERVICE=WMS"];
	[requestParams addObject:@"REQUEST=GetMap"];
	[requestParams addObject:@"STYLES=0"];
	[requestParams addObject:@"WIDTH=256"];
	[requestParams addObject:@"HEIGHT=256"];
	[requestParams addObject:@"FORMAT=image/png"];
	[requestParams addObject:@"TRANSPARENT=True"];
	//[requestParams addObject:@"BGCOLOR=0xFFFFFF"];
	
	NSMutableString* urlString = [[[NSMutableString alloc]init]autorelease];
	[urlString appendString:self.wmsURL];
	[urlString appendString:@"?"];
	for(NSString* param in requestParams) {
		[urlString appendString:param];
		[urlString appendString:@"&"];
	}
	
	[urlString appendString:@"BBOX="];
	[urlString appendFormat:@"%f,%f,%f,%f",
	 meTileProviderRequest.minX,
	 meTileProviderRequest.minY,
	 meTileProviderRequest.maxX,
	 meTileProviderRequest.maxY];

	return urlString;
}

- (void) requestTile:(METileProviderRequest*) meTileRequest
{
	NSLog([self tileURLForRequest:meTileRequest]);
	//Check to make sure we still need to supply the tile.
	BOOL isNeeded = [super isNeeded:meTileRequest];
	
	if(!isNeeded) {
		if(self.isAsynchronous) {
			[super tileLoadComplete:meTileRequest];
		}
		return;
	}
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* fileName = [self cacheFileNameForRequest:meTileRequest];
	
	if([fileManager fileExistsAtPath:fileName]==NO) {
		if(![self downloadTileFromURL:[self tileURLForRequest:meTileRequest]
							   toFileName:fileName]){
			//For downloads that fail, show the gray grid
			meTileRequest.isProxy = YES;
			meTileRequest.isOpaque = YES;
			meTileRequest.isDirty = YES;
			meTileRequest.cachedImageName = @"grayGrid";
			meTileRequest.tileProviderResponse = kTileResponseRenderNamedCachedImage;
			if(self.isAsynchronous){
				[super tileLoadComplete:meTileRequest];
			}
			return;
		}
	}
	meTileRequest.fileName = fileName;
	if([meTileRequest.fileName.pathExtension caseInsensitiveCompare:@"png"]==NSOrderedSame) {
		meTileRequest.isOpaque = NO;
	}
	else {
		meTileRequest.isOpaque = YES;
	}
	meTileRequest.tileProviderResponse = kTileResponseRenderFilename;
	
	if(self.isAsynchronous){
		[super tileLoadComplete:meTileRequest];
	}
}


- (BOOL) downloadTileFromURL:(NSString*) url toFileName:(NSString*) fileName {
	return [MEFileDownloader downloadSync:url toFile:fileName];
}

@end
