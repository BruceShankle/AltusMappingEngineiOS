//
//  MEFileDownloader.m
//  Mapp
//
//  Created by Bruce Shankle III on 10/16/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MEFileDownloader.h"

@implementation MEFileDownloader
@synthesize fileConnection;
@synthesize activeDownload;
@synthesize destFileName;


static unsigned int _activeDownloadCount=0;

+ (unsigned int) activeDownloadCount
{
	return _activeDownloadCount;
}

+ (void) incrementDownloadCount
{
	@synchronized([MEFileDownloader class])
	{
		if(_activeDownloadCount==0)
		{
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		}
		_activeDownloadCount++;
	}
}

+ (void) decrementDownloadCount
{
	@synchronized([MEFileDownloader class])
	{
		_activeDownloadCount--;
		if(_activeDownloadCount<0)
			_activeDownloadCount = 0;
		
		//If there are no other files, turn off the network indicator
		if(_activeDownloadCount==0)
		{
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		}
	}
}

+ (NSData*) downloadSync:(NSString*) urlString
{
	//Increment number of downloads being processed
	[MEFileDownloader incrementDownloadCount];
	
	//Create a URL request
	NSURLRequest* request=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]
											   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
										   timeoutInterval:5];
	
	BOOL success = NO;
	NSHTTPURLResponse* response;
	NSError* error;
	NSData* data;
	
	//Try downloading the file at least 5 times.
	for(int i=0; i<5; i++)
	{
		data = [NSURLConnection sendSynchronousRequest:request
									 returningResponse:&response
												 error:&error];
		
		if(response.statusCode==200 || response.statusCode==404)
			break;
	}
	
	if(response.statusCode==200)
		success = YES;
	else
		success = NO;
	
	//Release the request
	[request release];
	
	//Decrement the number of files being downloaded
	[MEFileDownloader decrementDownloadCount];
	
	//Return
	if(success)
	{
		return data;
	}
	
	return nil;

}

+ (BOOL) downloadSync:(NSString*) urlString toFile:(NSString*) fileName
{
	NSData* data = [MEFileDownloader downloadSync:urlString];
	if(data)
	{
		[data writeToFile:fileName atomically:YES];
		return YES;
	}
	return NO;
}

- (void)downloadAsync:(NSString*) urlString toFile:(NSString*) fileName;
{
    self.activeDownload = [NSMutableData data];
	self.destFileName = fileName;
	
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:urlString]] delegate:self];
    self.fileConnection = conn;
    [conn release];
}

- (void)cancelDownload
{
    [self.fileConnection cancel];
    self.fileConnection = nil;
    self.activeDownload = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.fileConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}


@end
