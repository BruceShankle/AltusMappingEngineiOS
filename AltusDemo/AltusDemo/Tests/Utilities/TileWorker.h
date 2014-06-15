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
@property (retain) dispatch_queue_t serialQueue;
@property (assign) BOOL isBusy;
@property (retain) TileFactory* tileFactory;
-(void) startTile:(METileProviderRequest *) meTileRequest;
-(void) doWork:(METileProviderRequest *) meTileRequest;
@end
