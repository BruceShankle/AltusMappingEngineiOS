//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "RasterTileProvider.h"

@implementation RasterTileProvider


-(id) initWithURLTemplate:(NSString*) urlTemplate
               queueCount:(int) queueCount{
    if(self=[super init]){
        self.isAsynchronous = YES;
        self.urlTemplate = urlTemplate;
        
        //Create a set of serial queues
        self.serialQueues = [[NSMutableArray alloc]init];
        for(int i=0; i<queueCount; i++){
            dispatch_queue_t q = dispatch_queue_create("RasterQueue", DISPATCH_QUEUE_SERIAL);
            [self.serialQueues addObject:q];
        }
        self.subDomains = [[NSMutableArray alloc]init];
        self.currentSubdomain = 0;
        self.currentQueue = 0;
        self.tilesContainTransparency = NO;
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
        NSLog(@"Got %d for %@", response.statusCode, urlString);
    }
    
	//Return
	if(success){
		return data;
	}
	
	return nil;
}

-(dispatch_queue_t) getNextQueue{
    dispatch_queue_t targetQueue = [self.serialQueues objectAtIndex:self.currentQueue];
    self.currentQueue++;
    if(self.currentQueue > self.serialQueues.count-1){
        self.currentQueue = 0;
    }
    return targetQueue;
}

- (void) requestTileAsync:(METileProviderRequest *)meTileRequest{
    
    dispatch_async([self getNextQueue], ^{
        if([self.meMapViewController tileIsNeeded:meTileRequest]){
            for(MESphericalMercatorTile* smTile in meTileRequest.sphericalMercatorTiles){
                NSString* url = [self urlForTile:smTile];
                NSData* tileData = [self download:url];
                if(tileData!=nil){
                    smTile.uiImage = [UIImage imageWithData:tileData];
                    meTileRequest.tileProviderResponse = kTileResponseRenderUIImage;
                    if(self.tilesContainTransparency){
                        meTileRequest.isOpaque = NO;
                    }
                }
                else{
                    NSLog(@"Got not data for %@", url);
                    meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
                    break;
                }
            }
        }
        [self.meMapViewController tileLoadComplete:meTileRequest];
    });
}

@end
