//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "TileFactory.h"

/////////////////////////////////////////////////////////////////////
//Base class for objects that create or retrieve tiles
//in the context of a TileFactor
@implementation TileWorker

-(id) init{
    if(self=[super init]){
        self.serialQueue = dispatch_queue_create("TileWorker", DISPATCH_QUEUE_SERIAL);
        self.isBusy = NO;
    }
    return self;
}

-(void) doWork:(METileProviderRequest *) meTileRequest{
    NSLog(@"TileFactoryWorker:doWork You should be overriding this method. Exiting.");
    exit(0);
}

-(void) startTile:(METileProviderRequest *) meTileRequest{
    self.isBusy = YES;
    dispatch_async(self.serialQueue, ^{
        //Do work on background thread
        [self doWork:meTileRequest];
        self.isBusy = NO;
        //On main thred tell manager I'm done
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isBusy = NO;
            if(self.tileFactory!=nil){
                [self.tileFactory finishTile:meTileRequest];
            }
            else{
                NSLog(@"The worker has no factory object. Exiting.");
                exit(0);
            }
        });
    });
}

@end

/////////////////////////////////////////////////////////////////////
//Tile worker that can download raster tiles
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


/////////////////////////////////////////////////////////////////////////////////
//A tile provider that farms out work to TileWorks and provides
//resources on demand.
@implementation TileFactory

-(id) init{
    if(self=[super init]){
        self.isAsynchronous = YES;
        self.activeTileRequests = [[NSMutableArray alloc]init];
        self.tileWorkers = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void) addWorker:(TileWorker*) tileWorker{
    tileWorker.tileFactory = self;
    [self.tileWorkers addObject:tileWorker];
}

-(METileProviderRequest*) getNextRequest{
    METileProviderRequest* tileRequest = [self.activeTileRequests objectAtIndex:0];
    [self.activeTileRequests removeObjectAtIndex:0];
    return tileRequest;
}

- (void) deleteStaleRequests{
    NSMutableArray* staleRequests = [NSMutableArray array];
    for (METileProviderRequest* request in self.activeTileRequests){
        if(![self.meMapViewController tileIsNeeded:request]){
            [staleRequests addObject:request];
        }
    }
    
    if(staleRequests.count>0){
        [self.activeTileRequests removeObjectsInArray:staleRequests];
    }
}

- (void) queueWork{
    
    //First, delete all stale requests
    [self deleteStaleRequests];
    
    //Early exit, no workers
    if(self.tileWorkers==nil || self.tileWorkers.count==0){
        NSLog(@"The factory has no workers. Exiting.");
        exit(0);
    }
    
    //Early exit, no work
    if(self.activeTileRequests.count==0){
        return;
    }
   
    //If any worker is not busy, assign it work
    for(TileWorker* worker in self.tileWorkers){
        if(!worker.isBusy){
            [worker startTile:[self getNextRequest]];
            //If no more work, exit
            if(self.activeTileRequests.count==0){
                return;
            }
        }
    }
}

-(void) finishTile:(METileProviderRequest *) meTileRequest{
    [self.meMapViewController tileLoadComplete:meTileRequest];
    [self queueWork];
}

- (void) requestTileAsync:(METileProviderRequest *)meTileRequest{
    
    if(self.meMapViewController==nil){
        NSLog(@"TileFactory: meMapViewController is nil. Exiting.");
        exit(0);
    }
    //Add the current one to our list
    [self.activeTileRequests addObject:meTileRequest];
    
    //Que work
    [self queueWork];
}


+(TileFactory*) createInternetTileFactory:(MEMapViewController*) meMapViewController
                              urlTemplate:(NSString*) urlTemplate
                               subDomains:(NSString*) subDomains
                               numWorkers:(int) numWorkers
                              enableAlpha:(BOOL) enableAlpha;{
    TileFactory* newFactory = [[TileFactory alloc]init];
    newFactory.meMapViewController = meMapViewController;
    for(int i=0; i<numWorkers; i++){
        [newFactory addWorker:[[TileDownloader alloc]initWithURLTemplate:urlTemplate
                                                              subDomains:subDomains
                                                             enableAlpha:enableAlpha]];
    }
    return newFactory;
}

@end
