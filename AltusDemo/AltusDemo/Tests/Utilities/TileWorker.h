//  Created by Bruce Shankle on 5/30/14.
#pragma once
#import <Foundation/Foundation.h>
#import <AltusMappingEngine/AltusMappingEngine.h>

//Forward declarations
@class TileFactory;

/**
 Serves as base class for an object that does the work of downloading, retrieving, or creating a tile TileWorkers do their work in the context of a TileFactory.
 You should create a class that extends this class and overrides the doWork function.*/
@interface TileWorker : NSObject
/**The serial queue on which this worker does work.*/
@property (retain) dispatch_queue_t serialQueue;
/**True if the worker is busy.*/
@property (assign) BOOL isBusy;
/**Reference to the owning tile factory, this must be weak to prevent
 circular retain issues. The mapping engine will keep a reference to the tile
 factory as long as the map layer it is providing resources for is still loaded.*/
@property (weak) TileFactory* tileFactory;
-(void) startTile:(METileProviderRequest *) meTileRequest;

/**Over-ride this function in your class to do the work of getting a tile. This function
 will be called from a background thread and will only be called if the resource
 is actually needed by the mapping engine.*/
-(void) doWork:(METileProviderRequest *) meTileRequest;
@end
