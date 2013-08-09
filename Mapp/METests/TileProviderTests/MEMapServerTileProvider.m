//
//  MEMapServerTileProvider.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/21/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MEMapServerTileProvider.h"
#include <inttypes.h>
#import "ASIHTTPRequest.h"

@implementation MEMapServerTileProvider
@synthesize  mapDomain;
@synthesize returnUIImages;
@synthesize returnNSData;

-(void) dealloc
{
	self.mapDomain = nil;
    self.returnNSData = NO;
    self.returnUIImages = NO;
	[super dealloc];
}

- (NSString*) cacheFileNameFor:(uint64_t) tileid extension:(NSString*)extension
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
			exit(1);
		}
	}
	
    
	NSString* fileName=[NSString stringWithFormat:@"%@/%"PRId64".%@", cachePath, tileid, extension];
	
	return fileName;
}

- (NSString*) datFileNameFor:(uint64_t) tileid
{
	NSString* cachePath = [NSString stringWithFormat:@"%@/%@/%@",[[DirectoryInfo sharedDirectoryInfo] GetCacheDirectory], @"tilecache", self.mapDomain];
	NSString* fileName=[NSString stringWithFormat:@"%@/%"PRId64".dat", cachePath, tileid];
	return fileName;
}

- (void) getTileFromServer:(METileProviderRequest*) meTileRequest
{
	NSString* tileIdString = [NSString stringWithFormat:@"%"PRId64"", meTileRequest.uid];
	
	NSString* urlString = [NSString stringWithFormat:@"http://%@?tileId=%@", self.mapDomain, tileIdString];
	
	NSURL* url = [NSURL URLWithString:urlString];
	
    __block METileProviderRequest* METileProviderRequest = meTileRequest;
    [METileProviderRequest retain];
	__block ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
    
    [request setTimeOutSeconds:5];
    [request setNumberOfTimesToRetryOnTimeout:3];
    [request setShouldAttemptPersistentConnection:YES];
	
	[request setCompletionBlock:^{
		
        if( [request responseStatusCode] == 200 )
        {
            NSData* responseData = nil;
            responseData = [[NSData alloc]initWithData:[request responseData]];
            NSDictionary* responseHeaders = [request responseHeaders];
            
            //Write the image to .jpg or .png depending on the content type
            NSString* imageType = [responseHeaders objectForKey:@"Content-Type"];
            if([imageType isEqualToString:@"image/jpeg"])
            {
                METileProviderRequest.fileName = [self cacheFileNameFor:METileProviderRequest.uid extension:@"jpg"];
                METileProviderRequest.isOpaque = YES;
                METileProviderRequest.imageDataType = kImageDataTypeJPG;
            }
            
            if([imageType isEqualToString:@"image/png"])
            {
                METileProviderRequest.fileName = [self cacheFileNameFor:METileProviderRequest.uid extension:@"png"];
                METileProviderRequest.isOpaque = NO;
                METileProviderRequest.imageDataType = kImageDataTypePNG;
            }
            
            [responseData writeToFile:METileProviderRequest.fileName atomically:YES];
            [responseData release];
            
            if(self.returnUIImages)
            {
                if(METileProviderRequest.fileName)
                {
                    METileProviderRequest.uiImage = [UIImage imageWithContentsOfFile:METileProviderRequest.fileName];
                    METileProviderRequest.fileName = nil;
                }
            }
            
            if(self.returnNSData)
            {
                if(METileProviderRequest.fileName)
                {
                    METileProviderRequest.nsImageData = [NSData dataWithContentsOfFile:METileProviderRequest.fileName];
                    METileProviderRequest.fileName = nil;
                }
            }
            
            //Get the borders from the response headers
            NSString* sminX = [responseHeaders objectForKey:@"X-Tile-MinX"];
            NSString* sminY = [responseHeaders objectForKey:@"X-Tile-MinY"];
            NSString* smaxX = [responseHeaders objectForKey:@"X-Tile-MaxX"];
            NSString* smaxY = [responseHeaders objectForKey:@"X-Tile-MaxY"];
          
            
            METileProviderRequest.minX = [sminX doubleValue];
            METileProviderRequest.minY = [sminY doubleValue];
            METileProviderRequest.maxX = [smaxX doubleValue];
            METileProviderRequest.maxY = [smaxY doubleValue];
            
            //Write out the meta-data
            [self writeMetaData:METileProviderRequest];
        }
		
		//Notify the load is complete.
		[self tileLoadComplete:METileProviderRequest];
        [METileProviderRequest release];
		
	}];
	
	[request setFailedBlock:^{
		[self tileLoadComplete:METileProviderRequest];
        [METileProviderRequest release];
	}];
	
	[request startAsynchronous];
	
}

- (void) writeMetaData:(METileProviderRequest*) meTileRequest
{
	//Write out the meta-data
	NSString* datFileName = [self datFileNameFor:meTileRequest.uid];
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
	NSString* datFileName = [self datFileNameFor:meTileRequest.uid];
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


- (BOOL) getTileFromLocalCache:(METileProviderRequest*) meTileRequest
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
    
    //Is PNG in cache?
	NSString* fileName = [self cacheFileNameFor:meTileRequest.uid extension:@"png"];
	if([fileManager fileExistsAtPath:fileName]==YES)
	{
		meTileRequest.isOpaque = NO;
		meTileRequest.fileName = fileName;
		meTileRequest.tileProviderResponse = kTileResponseRenderFilename;
        meTileRequest.imageDataType = kImageDataTypePNG;
        if(self.returnUIImages)
		{
			meTileRequest.tileProviderResponse = kTileResponseRenderUIImage;
            meTileRequest.uiImage = [UIImage imageWithContentsOfFile:fileName];
		}
        if(self.returnNSData)
		{
			meTileRequest.tileProviderResponse = kTileResponseRenderNSData;
            meTileRequest.nsImageData = [NSData dataWithContentsOfFile:fileName];
		}
	}
	else
	{
		fileName = [self cacheFileNameFor:meTileRequest.uid extension:@"jpg"];
		if([fileManager fileExistsAtPath:fileName]==YES)
		{
			meTileRequest.isOpaque = YES;
			meTileRequest.fileName = fileName;
            meTileRequest.imageDataType = kImageDataTypeJPG;
            if(self.returnUIImages)
			{
				meTileRequest.tileProviderResponse = kTileResponseRenderUIImage;
                meTileRequest.uiImage = [UIImage imageWithContentsOfFile:fileName];
			}
            if(self.returnNSData)
			{
				meTileRequest.tileProviderResponse = kTileResponseRenderNSData;
                meTileRequest.nsImageData = [NSData dataWithContentsOfFile:fileName];
			}
		}
	}
	
	if(meTileRequest.fileName.length!=0)
	{
		//We have a tile file, so load meta data for it.
		if([self readMetaData:meTileRequest])
        {
            if(self.returnNSData || self.returnUIImages)
                meTileRequest.fileName = nil;
			return YES;
        }
	}
	
	return NO;
}

- (void) requestTileAsync:(METileProviderRequest*) meTileRequest
{
	if([self getTileFromLocalCache:meTileRequest])
	{
		[super tileLoadComplete:meTileRequest];
		return;
	}
	
	//Otherwise queue up a download request
	[self getTileFromServer:meTileRequest];
}



@end
