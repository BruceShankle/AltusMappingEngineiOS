//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "TileFactory.h"
#import "TileDownloader.h"
#import "RasterPackageReader.h"

/////////////////////////////////////////////////////////////////////////////////
//A tile provider that farms out work to TileWorkers and provides
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

-(void) dealloc{
    if(self.tileWorkers){
        self.tileWorkers = nil;
    }
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
            //We must call tileLoadComplete, even for tiles that are no longer
            //needed so the engine can clean up internal data structures
            request.tileProviderResponse = kTileResponseWasCancelled;
            [self.meMapViewController tileLoadComplete:request];
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
    [self.meMapViewController tileLoadComplete:meTileRequest loadImmediate:YES];
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

+(TileFactory*) createPackageTileFactory:(MEMapViewController*) meMapViewController
                         packageFileName:(NSString*) packageFileName
                              numWorkers:(int) numWorkers{
    TileFactory* newFactory = [[TileFactory alloc]init];
    newFactory.meMapViewController = meMapViewController;
    for(int i=0; i<numWorkers; i++){
        [newFactory addWorker:[[RasterPackageReader alloc]initWithFileName:packageFileName]];
    }
    return newFactory;
}

@end
