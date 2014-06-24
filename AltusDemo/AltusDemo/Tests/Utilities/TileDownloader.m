//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "TileDownloader.h"

@implementation TileDownloader

-(id) init {
    if(self=[super init]){
        [self commonInit];
    }
    return self;
}

-(void) commonInit{
    self.timeOutInterval = 3;
    self.useCache = YES;
}

-(id) initWithURLTemplate:(NSString*) urlTemplate
               subDomains:(NSString*) subDomains
              enableAlpha:(BOOL) enableAlpha
                 useCache:(BOOL) useCache{
    if(self=[super init]){
        [self commonInit];
        self.urlTemplate = urlTemplate;
        self.enableAlpha = enableAlpha;
        self.subDomains = [subDomains componentsSeparatedByString:@","];
        self.currentSubdomain = 0;
        self.useCache = useCache;
    }
    return self;
}

- (NSString*) nextSubdomain{
    
    if(self.subDomains.count==0){
        return @"";
    }
    
    int next;
    @synchronized(self){
        next = self.currentSubdomain;
        self.currentSubdomain++;
        if(self.currentSubdomain>self.subDomains.count-1){
            self.currentSubdomain = 0;
        }
    }
    
    return (NSString*)[self.subDomains objectAtIndex:next];
}

- (NSString*) urlForSMTile:(MESphericalMercatorTile*) smTile{
    NSString* url = self.urlTemplate;
    
    url = [url stringByReplacingOccurrencesOfString:@"{s}" withString:
           [self nextSubdomain]];
    
    url = [url stringByReplacingOccurrencesOfString:@"{z}" withString:
           [NSString stringWithFormat:@"%d", smTile.slippyZ]];
    
    url = [url stringByReplacingOccurrencesOfString:@"{x}" withString:
           [NSString stringWithFormat:@"%d", smTile.slippyX]];
    
    url = [url stringByReplacingOccurrencesOfString:@"{y}" withString:
           [NSString stringWithFormat:@"%d", smTile.slippyY]];
    
	return url;
}

- (NSString*) urlForTile:(METileProviderRequest*) meTileProviderRequest {
    NSLog(@"TileDownloader:urlForTile: Sub-classes should override this method. Exiting.");
    exit(0);
}

- (NSData*) download:(NSString*) urlString{
	
    //Determine cache policy
    NSURLRequestCachePolicy cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    if(!self.useCache){
        cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }
    
	NSURLRequest* request=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]
											   cachePolicy:cachePolicy
										   timeoutInterval:self.timeOutInterval];
    
	BOOL success = NO;
	NSHTTPURLResponse* response;
	NSError* error;
	NSData* data;
	
	
	data = [NSURLConnection sendSynchronousRequest:request
								 returningResponse:&response
											 error:&error];
    
	if(response.statusCode==200){
		success = YES;
    }
    else{
        NSLog(@"TileDownloader Error %ld for %@", (long)response.statusCode, urlString);
    }
    
	//Return
	if(success){
		return data;
	}
	
	return nil;
}

- (void) doWork:(METileProviderRequest *)meTileRequest{
    
    //Get spherical mercator tiless?
    if(meTileRequest.sphericalMercatorTiles.count>0){
        for(MESphericalMercatorTile* smTile in meTileRequest.sphericalMercatorTiles){
            NSString* url = [self urlForSMTile:smTile];
            NSData* tileData = [self download:url];
            if(tileData!=nil){
                smTile.uiImage = [UIImage imageWithData:tileData];
                meTileRequest.tileProviderResponse = kTileResponseRenderUIImage;
                meTileRequest.isOpaque = !self.enableAlpha;
            }
            else{
                meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
                return;
            }
        }
    }
    else{
        NSString* url = [self urlForTile:meTileRequest];
        NSData* tileData = [self download:url];
        if(tileData!=nil){
            meTileRequest.uiImage = [UIImage imageWithData:tileData];
            meTileRequest.tileProviderResponse = kTileResponseRenderUIImage;
            meTileRequest.isOpaque = !self.enableAlpha;
        }
        else{
            meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
        }
    }
}

@end

