//
//  WorldSimple.m
//  AltusDemo
//
//  Created by Jacob Beaudoin on 3/8/14.
//  Copyright (c) 2014 BA3, LLC. All rights reserved.
//

#import "WorldSimple.h"
#import "../../METestCategory.h"

@implementation DownloadResult


@end

@implementation InternetVectorTileProvider

- (DownloadResult*) download:(NSString*) urlString {
	
	//Create a URL request
	NSURLRequest* request=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]
											   cachePolicy:NSURLRequestReturnCacheDataElseLoad
										   timeoutInterval:3];
	
	NSHTTPURLResponse* response;
	NSError* error;
    
    DownloadResult *result = [[DownloadResult alloc]init];
	result.data = [NSURLConnection sendSynchronousRequest:request
								 returningResponse:&response
											 error:&error];
    result.statusCode = response.statusCode;
    
    // clear out data on failure
    if (result.statusCode != 200)
        result.data = nil;
    
	return result;
}

- (void) requestTileAsync:(METileProviderRequest *)meTileRequest{
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *url = [NSString stringWithFormat:@"http://dev.ba3.us/downloads/Vector/White/%lld.bin", (long long)meTileRequest.uid];
        DownloadResult *result = [self download:url];
        
        if (result.statusCode == 404) {
            NSLog(@"not available");
            meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
        } else if (result.statusCode == 200) {
            NSLog(@"data size: %d, uid: %lld", result.data.length, (long long)meTileRequest.uid);
        } else {
            NSLog(@"download error");
        }
        
        //Give geometry to mapping engine.
		dispatch_async(dispatch_get_main_queue(), ^{
            [self.meMapViewController vectorTileLoadComplete:meTileRequest tileData:result.data];
		});
        
    });
}

@end

@implementation WorldSimple

-(id) init{
    if(self=[super init]){
        self.name = @"World - Vector";
    }
    
    return self;
}

- (void) start{
    if(self.isRunning){
        return;
    }
    
    //Stop tests that obscure or affect this one
    [self.meTestManager stopBaseMapTests];
    
    InternetVectorTileProvider *tileProvider = [[InternetVectorTileProvider alloc]init];
    tileProvider.meMapViewController = self.meMapViewController;
	
	//Create virtual map info
	MEVirtualMapInfo* mapInfo = [[MEVirtualMapInfo alloc]init];
	mapInfo.meMapViewController = self.meMapViewController;
	mapInfo.meTileProvider = tileProvider;
	mapInfo.mapType = kMapTypeVirtualVector;
	mapInfo.zOrder = 10;
	mapInfo.name = self.name;
	
	//Add map
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
    
    //Stop other tests in this category
	[self.meTestCategory stopAllTests];
    
    self.isRunning = YES;
}

- (void) stop {
    if(!self.isRunning){
        return;
    }
    self.isRunning = NO;
    [self.meMapViewController removeMap:self.name clearCache:NO];
}

@end
