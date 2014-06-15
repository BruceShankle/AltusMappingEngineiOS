//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "TileDownloader.h"

@implementation TileDownloader

-(id) initWithURLTemplate:(NSString*) urlTemplate
               subDomains:(NSString*) subDomains
              enableAlpha:(BOOL) enableAlpha{
    if(self=[super init]){
        self.urlTemplate = urlTemplate;
        self.enableAlpha = enableAlpha;
        self.subDomains = [subDomains componentsSeparatedByString:@","];
        self.currentSubdomain = 0;
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

- (NSString*) urlForTile:(MESphericalMercatorTile*) smTile{
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

- (NSData*) download:(NSString*) urlString{
	
	//Create a URL request
	NSURLRequest* request=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]
											   cachePolicy:NSURLRequestReturnCacheDataElseLoad
										   timeoutInterval:3];
	
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
        NSLog(@"Got %ld for %@", (long)response.statusCode, urlString);
    }
    
	//Return
	if(success){
		return data;
	}
	
	return nil;
}

- (void) doWork:(METileProviderRequest *)meTileRequest{
    
    //Download all tiles
    for(MESphericalMercatorTile* smTile in meTileRequest.sphericalMercatorTiles){
        NSString* url = [self urlForTile:smTile];
        NSData* tileData = [self download:url];
        if(tileData!=nil){
            smTile.uiImage = [UIImage imageWithData:tileData];
            meTileRequest.tileProviderResponse = kTileResponseRenderUIImage;
            meTileRequest.isOpaque = !self.enableAlpha;
        }
        else{
            meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
            break;
        }
    }
}

@end

