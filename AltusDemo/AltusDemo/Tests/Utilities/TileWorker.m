//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "TileWorker.h"
#import "TileFactory.h"

@interface TileWorker () {
	dispatch_queue_priority_t _queuePriority;
}
@end

@implementation TileWorker

-(id) init{
    if(self=[super init]){
        
        //Create serial queue
        self.serialQueue = dispatch_queue_create("TileWorker", DISPATCH_QUEUE_SERIAL);
        
        //And set it's priority to default
        [self setTargetQueuePriority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
        self.isBusy = NO;
    }
    return self;
}

-(void) setTargetQueuePriority:(dispatch_queue_priority_t)targetQueuePriority{
    _queuePriority = targetQueuePriority;
    dispatch_set_target_queue(self.serialQueue,
                              dispatch_get_global_queue(_queuePriority, 0));
}

-(dispatch_queue_priority_t) targetQueuePriority{
    return _queuePriority;
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
        
        //On main thread:
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //1. Indicate available for more work so Factory will load us with work again.
            self.isBusy = NO;
            
            //2. Tell factory current work is complete.
            if(self.tileFactory!=nil){
                [self.tileFactory finishTile:meTileRequest];
            }
        });
    });
}

@end
