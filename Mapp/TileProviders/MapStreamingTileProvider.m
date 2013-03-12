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

- (void) getTileFromServer:(METileInfo*)tileinfo
{	
	NSString* urlString = [NSString stringWithFormat:@"http://%@?tileId=%@", self.mapDomain, [self cacheFileNameFor:tileinfo.uid]];
	
	NSURL* url = [NSURL URLWithString:urlString];

	ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
    NSString* requestId = [self cacheFileNameFor:tileinfo.uid];
	
    [request setTimeOutSeconds:5];
    [request setNumberOfTimesToRetryOnTimeout:3];
    [request setShouldAttemptPersistentConnection:YES];
    [request setUserInfo:[NSDictionary dictionaryWithObject:tileinfo forKey:@"tileinfo"]];
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
    
    METileInfo* tileinfo = [request.userInfo objectForKey:@"tileinfo"];
    NSString* requestId = [self cacheFileNameFor:tileinfo.uid];
    
    [self removeActiveRequestWithId:requestId];
    
#ifdef DEBUG_TILE_PROVIDERS
    NSLog(@"Finished: %@", requestId);
#endif
    
    if( request.isCancelled )
    {
        tileinfo.fileName = @"";
        tileinfo.isOpaque = NO;
        [super tileLoadComplete:tileinfo];
        return;
    }
    
    if( request.responseStatusCode != 200 )
    {
        if(request.responseStatusCode == 404)
        {
			tileinfo.tileProviderResponse = kTileResponseNotAvailable;
        }
        
        tileinfo.fileName = @"";
        tileinfo.isOpaque = NO;
        [super tileLoadComplete:tileinfo];
        return;
    }
    
    NSData* responseData = nil;
    responseData = [[NSData alloc]initWithData:[request responseData]];
    NSDictionary* responseHeaders = [request responseHeaders];
    
    //Write the image to .jpg or .png depending on the content type
    NSString* imageType = [responseHeaders objectForKey:@"Content-Type"];
    if([imageType isEqualToString:@"image/jpeg"])
    {
        tileinfo.imageDataType = kImageDataTypeJPG;
        tileinfo.fileName = [self cacheFilePathFor:tileinfo.uid extension:@"jpg"];
        tileinfo.isOpaque = YES;
    }
    if([imageType isEqualToString:@"image/png"])
    {
        tileinfo.imageDataType = kImageDataTypeJPG;
        tileinfo.fileName = [self cacheFilePathFor:tileinfo.uid extension:@"png"];
        tileinfo.isOpaque = NO;
    }
    
    [responseData writeToFile:tileinfo.fileName atomically:YES];
    [responseData release];
    
    //Get the borders from the response headers
    NSString* sminX = [responseHeaders objectForKey:@"X-Tile-MinX"];
    NSString* sminY = [responseHeaders objectForKey:@"X-Tile-MinY"];
    NSString* smaxX = [responseHeaders objectForKey:@"X-Tile-MaxX"];
    NSString* smaxY = [responseHeaders objectForKey:@"X-Tile-MaxY"];
    tileinfo.minX = [sminX doubleValue];
    tileinfo.minY = [sminY doubleValue];
    tileinfo.maxX = [smaxX doubleValue];
    tileinfo.maxY = [smaxY doubleValue];
    
    [self writeMetaData:tileinfo];
    
    [super tileLoadComplete:tileinfo];
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    // A request may fail either due to a network error or
    // due to being cancelled before it finished loading
    
    METileInfo* tileinfo = [request.userInfo objectForKey:@"tileinfo"];
    NSString* requestId = [self cacheFileNameFor:tileinfo.uid];
    
#ifdef DEBUG_TILE_PROVIDERS
    NSLog(@"Failed: %@", requestId);
#endif
    
    [self removeActiveRequestWithId:requestId];
    
    tileinfo.fileName = @"";
    tileinfo.isOpaque = NO;
    [super tileLoadComplete:tileinfo];
}

- (void) writeMetaData:(METileInfo*) tileinfo
{
	//Write out the meta-data
	NSString* datFileName = [self datFilePathFor:tileinfo.uid];
	FILE* outfile = fopen([datFileName UTF8String], "wb");
	double d;
	d = tileinfo.minX; fwrite(&d, sizeof(double), 1, outfile);
	d = tileinfo.minY; fwrite(&d, sizeof(double), 1, outfile);
	d = tileinfo.maxX; fwrite(&d, sizeof(double), 1, outfile);
	d = tileinfo.maxY; fwrite(&d, sizeof(double), 1, outfile);
	fclose(outfile);
}

- (BOOL) readMetaData:(METileInfo*) tileinfo
{
	NSString* datFileName = [self datFilePathFor:tileinfo.uid];
	FILE* infile = fopen([datFileName UTF8String], "rb");
	if(infile==NULL)
		return NO;
	double d;
	fread(&d, sizeof(double), 1, infile); tileinfo.minX = d;
	fread(&d, sizeof(double), 1, infile); tileinfo.minY = d;
	fread(&d, sizeof(double), 1, infile); tileinfo.maxX = d;
	fread(&d, sizeof(double), 1, infile); tileinfo.maxY = d;
	fclose(infile);
	return YES;
}

- (BOOL) getTileFromLocalCache:(METileInfo*)tileinfo
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* fileName = [self cacheFilePathFor:tileinfo.uid extension:@"png"];
    
	if([fileManager fileExistsAtPath:fileName])
	{
		tileinfo.isOpaque = NO;
		tileinfo.fileName = fileName;
	}
	else
	{
		fileName = [self cacheFilePathFor:tileinfo.uid extension:@"jpg"];
		if([fileManager fileExistsAtPath:fileName])
		{
			tileinfo.isOpaque = YES;
			tileinfo.fileName = fileName;
		}
	}
	
	if( tileinfo.fileName.length != 0 )
	{
		// We have a tile file, so load meta data for it and return
		if([self readMetaData:tileinfo])
			return YES;
	}
	
	return NO;
}

- (void) requestTileAsync:(METileInfo*)tileinfo
{
	if([self getTileFromLocalCache:tileinfo])
	{
		[super tileLoadComplete:tileinfo];
		return;
	}
	
	// Otherwise queue up a download request
	[self getTileFromServer:tileinfo];
}

- (void) cancelTileRequest:(METileInfo*)tileInfo
{
    NSString* requestId = [self cacheFileNameFor:tileInfo.uid];
    
#ifdef DEBUG_TILE_PROVIDERS
    NSLog(@"Cancel Requested: %@", requestId);
#endif
    
    ASIHTTPRequest* request = [self getActiveRequestWithId:requestId];
    
    // Make sure that the engine has actually initiated this request already
    // (it's possible that the cancelTileRequest:tileinfo gets called before
    // requestTile:tileinfo or requestTileAsync:tileinfo)
    
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
    // multiple times until that request calls tileLoadComplete:tileinfo, so
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
