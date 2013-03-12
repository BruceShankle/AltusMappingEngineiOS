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

- (void) getTileFromServer:(METileInfo*) tileinfo
{
	NSString* tileIdString = [NSString stringWithFormat:@"%"PRId64"", tileinfo.uid];
	
	NSString* urlString = [NSString stringWithFormat:@"http://%@?tileId=%@", self.mapDomain, tileIdString];
	
	NSURL* url = [NSURL URLWithString:urlString];
	
    __block METileInfo* meTileInfo = tileinfo;
    [meTileInfo retain];
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
                meTileInfo.fileName = [self cacheFileNameFor:meTileInfo.uid extension:@"jpg"];
                meTileInfo.isOpaque = YES;
                meTileInfo.imageDataType = kImageDataTypeJPG;
            }
            
            if([imageType isEqualToString:@"image/png"])
            {
                meTileInfo.fileName = [self cacheFileNameFor:meTileInfo.uid extension:@"png"];
                meTileInfo.isOpaque = NO;
                meTileInfo.imageDataType = kImageDataTypePNG;
            }
            
            [responseData writeToFile:meTileInfo.fileName atomically:YES];
            [responseData release];
            
            if(self.returnUIImages)
            {
                if(meTileInfo.fileName)
                {
                    meTileInfo.uiImage = [UIImage imageWithContentsOfFile:meTileInfo.fileName];
                    meTileInfo.fileName = nil;
                }
            }
            
            if(self.returnNSData)
            {
                if(meTileInfo.fileName)
                {
                    meTileInfo.nsImageData = [NSData dataWithContentsOfFile:meTileInfo.fileName];
                    meTileInfo.fileName = nil;
                }
            }
            
            //Get the borders from the response headers
            NSString* sminX = [responseHeaders objectForKey:@"X-Tile-MinX"];
            NSString* sminY = [responseHeaders objectForKey:@"X-Tile-MinY"];
            NSString* smaxX = [responseHeaders objectForKey:@"X-Tile-MaxX"];
            NSString* smaxY = [responseHeaders objectForKey:@"X-Tile-MaxY"];
          
            
            meTileInfo.minX = [sminX doubleValue];
            meTileInfo.minY = [sminY doubleValue];
            meTileInfo.maxX = [smaxX doubleValue];
            meTileInfo.maxY = [smaxY doubleValue];
            
            //Write out the meta-data
            [self writeMetaData:meTileInfo];
        }
		
		//Notify the load is complete.
		[self tileLoadComplete:meTileInfo];
        [meTileInfo release];
		
	}];
	
	[request setFailedBlock:^{
		[self tileLoadComplete:meTileInfo];
        [meTileInfo release];
	}];
	
	[request startAsynchronous];
	
}

- (void) writeMetaData:(METileInfo*) tileinfo
{
	//Write out the meta-data
	NSString* datFileName = [self datFileNameFor:tileinfo.uid];
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
	NSString* datFileName = [self datFileNameFor:tileinfo.uid];
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


- (BOOL) getTileFromLocalCache:(METileInfo*) tileinfo
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
    
    //Is PNG in cache?
	NSString* fileName = [self cacheFileNameFor:tileinfo.uid extension:@"png"];
	if([fileManager fileExistsAtPath:fileName]==YES)
	{
		tileinfo.isOpaque = NO;
		tileinfo.fileName = fileName;
		tileinfo.tileProviderResponse = kTileResponseRenderFilename;
        tileinfo.imageDataType = kImageDataTypePNG;
        if(self.returnUIImages)
		{
			tileinfo.tileProviderResponse = kTileResponseRenderUIImage;
            tileinfo.uiImage = [UIImage imageWithContentsOfFile:fileName];
		}
        if(self.returnNSData)
		{
			tileinfo.tileProviderResponse = kTileResponseRenderNSData;
            tileinfo.nsImageData = [NSData dataWithContentsOfFile:fileName];
		}
	}
	else
	{
		fileName = [self cacheFileNameFor:tileinfo.uid extension:@"jpg"];
		if([fileManager fileExistsAtPath:fileName]==YES)
		{
			tileinfo.isOpaque = YES;
			tileinfo.fileName = fileName;
            tileinfo.imageDataType = kImageDataTypeJPG;
            if(self.returnUIImages)
			{
				tileinfo.tileProviderResponse = kTileResponseRenderUIImage;
                tileinfo.uiImage = [UIImage imageWithContentsOfFile:fileName];
			}
            if(self.returnNSData)
			{
				tileinfo.tileProviderResponse = kTileResponseRenderNSData;
                tileinfo.nsImageData = [NSData dataWithContentsOfFile:fileName];
			}
		}
	}
	
	if(tileinfo.fileName.length!=0)
	{
		//We have a tile file, so load meta data for it.
		if([self readMetaData:tileinfo])
        {
            if(self.returnNSData || self.returnUIImages)
                tileinfo.fileName = nil;
			return YES;
        }
	}
	
	return NO;
}

- (void) requestTileAsync:(METileInfo*) tileinfo
{
	if([self getTileFromLocalCache:tileinfo])
	{
		[super tileLoadComplete:tileinfo];
		return;
	}
	
	//Otherwise queue up a download request
	[self getTileFromServer:tileinfo];
}



@end
