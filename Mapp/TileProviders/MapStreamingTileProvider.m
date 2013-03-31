//
//  MapStreamingTileProvider.m
//  Mapp
//
//  Created by Edwin B Shankle III on 7/4/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MapStreamingTileProvider.h"
#include <inttypes.h>

@implementation MapStreamingTileProvider
@synthesize mapDomain;

-(MapStreamingTileProvider*) init
{
	self = [super init];
    if ( self )
	{
    }
    return self;
}

- (void) dealloc
{
    NSArray* allActiveRequests = [self getAllActiveRequests];
    
    // Cancel all outstanding requests
    for( ASIHTTPRequest* request in allActiveRequests )
    {
        // Only async requests can be cancelled
        if( !request.isSynchronous )
        {
            // Remove ourselves from delegate so that ASIHTTPRequest
            // does not try to call the requestFailed on ourselves
            // after we are dealloced. Instead, call requestFailed
            // manually right now.
            
            request.delegate = nil;
            [request cancel];
            
            [self requestFailed:request];
        }
    }
    
    self.mapDomain = nil;
    [super dealloc];
}

- (NSString*) cacheFileNameFor:(uint64_t)tileid
{
    return [NSString stringWithFormat:@"%"PRId64"", tileid];
}

- (NSString*) cacheFilePathFor:(uint64_t)tileid extension:(NSString*)extension
{
	//Create target cache folder?
	NSError *error;
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* cachePath = [NSString stringWithFormat:@"%@/%@/%@",[[DirectoryInfo sharedDirectoryInfo] GetCacheDirectory], @"tilecache", self.mapDomain];
	
	if([fileManager fileExistsAtPath:cachePath]==NO)
	{
		if (![[NSFileManager defaultManager] createDirectoryAtPath:cachePath
									   withIntermediateDirectories:YES
														attributes:nil
															 error:&error])
		{
			NSLog(@"Create directory error: %@", error);
			assert(false);
		}
	}
	

	NSString* fileName = [NSString stringWithFormat:@"%@/%@.%@", cachePath, [self cacheFileNameFor:tileid], extension];
	
	return fileName;
}

- (NSString*) datFilePathFor:(uint64_t)tileid
{
	NSString* cachePath = [NSString stringWithFormat:@"%@/%@/%@",[[DirectoryInfo sharedDirectoryInfo] GetCacheDirectory], @"tilecache", self.mapDomain];
	NSString* fileName=[NSString stringWithFormat:@"%@/%@.dat", cachePath, [self cacheFileNameFor:tileid]];
	return fileName;
}

- (void) getTileFromServer:(METileProviderRequest*)meTileRequest
{	
	NSString* urlString = [NSString stringWithFormat:@"http://%@?tileId=%@", self.mapDomain, [self cacheFileNameFor:meTileRequest.uid]];
	
	NSURL* url = [NSURL URLWithString:urlString];

	ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
    NSString* requestId = [self cacheFileNameFor:meTileRequest.uid];
	
    [request setTimeOutSeconds:5];
    [request setNumberOfTimesToRetryOnTimeout:3];
    [request setShouldAttemptPersistentConnection:YES];
    [request setUserInfo:[NSDictionary dictionaryWithObject:meTileRequest forKey:@"meTileRequest"]];
    [request setDelegate:self];
    
#ifdef DEBUG_TILE_PROVIDERS
    NSLog(@"Start: %@", url);
#endif
    
    [self addActiveRequest:request withId:requestId];
    [request startAsynchronous];
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    // A request may still finish even after being cancelled,
    // so we check here just to be sure
    
    METileProviderRequest* meTileRequest = [request.userInfo objectForKey:@"meTileRequest"];
    NSString* requestId = [self cacheFileNameFor:meTileRequest.uid];
    
    [self removeActiveRequestWithId:requestId];
    
#ifdef DEBUG_TILE_PROVIDERS
    NSLog(@"Finished: %@", requestId);
#endif
    
    if( request.isCancelled )
    {
        meTileRequest.fileName = @"";
        meTileRequest.isOpaque = NO;
        [super tileLoadComplete:meTileRequest];
        return;
    }
    
    if( request.responseStatusCode != 200 )
    {
        if(request.responseStatusCode == 404)
        {
			meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
        }
        
        meTileRequest.fileName = @"";
        meTileRequest.isOpaque = NO;
        [super tileLoadComplete:meTileRequest];
        return;
    }
    
    NSData* responseData = nil;
    responseData = [[NSData alloc]initWithData:[request responseData]];
    NSDictionary* responseHeaders = [request responseHeaders];
    
    //Write the image to .jpg or .png depending on the content type
    NSString* imageType = [responseHeaders objectForKey:@"Content-Type"];
    if([imageType isEqualToString:@"image/jpeg"])
    {
        meTileRequest.imageDataType = kImageDataTypeJPG;
        meTileRequest.fileName = [self cacheFilePathFor:meTileRequest.uid extension:@"jpg"];
        meTileRequest.isOpaque = YES;
    }
    if([imageType isEqualToString:@"image/png"])
    {
        meTileRequest.imageDataType = kImageDataTypeJPG;
        meTileRequest.fileName = [self cacheFilePathFor:meTileRequest.uid extension:@"png"];
        meTileRequest.isOpaque = NO;
    }
    
    [responseData writeToFile:meTileRequest.fileName atomically:YES];
    [responseData release];
    
    //Get the borders from the response headers
    NSString* sminX = [responseHeaders objectForKey:@"X-Tile-MinX"];
    NSString* sminY = [responseHeaders objectForKey:@"X-Tile-MinY"];
    NSString* smaxX = [responseHeaders objectForKey:@"X-Tile-MaxX"];
    NSString* smaxY = [responseHeaders objectForKey:@"X-Tile-MaxY"];
    meTileRequest.minX = [sminX doubleValue];
    meTileRequest.minY = [sminY doubleValue];
    meTileRequest.maxX = [smaxX doubleValue];
    meTileRequest.maxY = [smaxY doubleValue];
    
    [self writeMetaData:meTileRequest];
    
    [super tileLoadComplete:meTileRequest];
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    // A request may fail either due to a network error or
    // due to being cancelled before it finished loading
    
    METileProviderRequest* meTileRequest = [request.userInfo objectForKey:@"meTileRequest"];
    NSString* requestId = [self cacheFileNameFor:meTileRequest.uid];
    
#ifdef DEBUG_TILE_PROVIDERS
    NSLog(@"Failed: %@", requestId);
#endif
    
    [self removeActiveRequestWithId:requestId];
    
    meTileRequest.fileName = @"";
    meTileRequest.isOpaque = NO;
    [super tileLoadComplete:meTileRequest];
}

- (void) writeMetaData:(METileProviderRequest*) meTileRequest
{
	//Write out the meta-data
	NSString* datFileName = [self datFilePathFor:meTileRequest.uid];
	FILE* outfile = fopen([datFileName UTF8String], "wb");
	double d;
	d = meTileRequest.minX; fwrite(&d, sizeof(double), 1, outfile);
	d = meTileRequest.minY; fwrite(&d, sizeof(double), 1, outfile);
	d = meTileRequest.maxX; fwrite(&d, sizeof(double), 1, outfile);
	d = meTileRequest.maxY; fwrite(&d, sizeof(double), 1, outfile);
	fclose(outfile);
}

- (BOOL) readMetaData:(METileProviderRequest*) meTileRequest
{
	NSString* datFileName = [self datFilePathFor:meTileRequest.uid];
	FILE* infile = fopen([datFileName UTF8String], "rb");
	if(infile==NULL)
		return NO;
	double d;
	fread(&d, sizeof(double), 1, infile); meTileRequest.minX = d;
	fread(&d, sizeof(double), 1, infile); meTileRequest.minY = d;
	fread(&d, sizeof(double), 1, infile); meTileRequest.maxX = d;
	fread(&d, sizeof(double), 1, infile); meTileRequest.maxY = d;
	fclose(infile);
	return YES;
}

- (BOOL) getTileFromLocalCache:(METileProviderRequest*)meTileRequest
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* fileName = [self cacheFilePathFor:meTileRequest.uid extension:@"png"];
    
	if([fileManager fileExistsAtPath:fileName])
	{
		meTileRequest.isOpaque = NO;
		meTileRequest.fileName = fileName;
	}
	else
	{
		fileName = [self cacheFilePathFor:meTileRequest.uid extension:@"jpg"];
		if([fileManager fileExistsAtPath:fileName])
		{
			meTileRequest.isOpaque = YES;
			meTileRequest.fileName = fileName;
		}
	}
	
	if( meTileRequest.fileName.length != 0 )
	{
		// We have a tile file, so load meta data for it and return
		if([self readMetaData:meTileRequest])
			return YES;
	}
	
	return NO;
}

- (void) requestTileAsync:(METileProviderRequest*)meTileRequest
{
	if([self getTileFromLocalCache:meTileRequest])
	{
		[super tileLoadComplete:meTileRequest];
		return;
	}
	
	// Otherwise queue up a download request
	[self getTileFromServer:meTileRequest];
}

- (void) cancelTileRequest:(METileProviderRequest*)meTileRequest
{
    NSString* requestId = [self cacheFileNameFor:meTileRequest.uid];
    
#ifdef DEBUG_TILE_PROVIDERS
    NSLog(@"Cancel Requested: %@", requestId);
#endif
    
    ASIHTTPRequest* request = [self getActiveRequestWithId:requestId];
    
    // Make sure that the engine has actually initiated this request already
    // (it's possible that the cancelTileRequest:meTileRequest gets called before
    // requestTile:meTileRequest or requestTileAsync:meTileRequest)
    
    if( !request )
    {
        return;
    }
    
    // Synchronous ASIHTTPRequests don't support cancellation :(
    
    if( request.isSynchronous )
    {
        return;
    }
    
    // It is possible that the engine will ask us to cancel the same request
    // multiple times until that request calls tileLoadComplete:meTileRequest, so
    // we make sure to issue the cancellation only once
    
    if( !request.isCancelled )
    {
        [request cancel];
#ifdef DEBUG_TILE_PROVIDERS
        NSLog(@"Cancel Performed: %@", requestId);
#endif
    }
}

@end
