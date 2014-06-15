//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import <AltusMappingEngine/AltusMappingEngine.h>
#import <Foundation/Foundation.h>
#import "TileWorker.h"

/** Serves as a tile provider that manages TileWorker objects. This demonstrates a farming out work on a per-tile basis and only doing the work that is necessary to serve up data that is in view.*/
@interface TileFactory : METileProvider
@property (retain) NSMutableArray* activeTileRequests;
@property (retain) NSMutableArray* tileWorkers;
-(void) addWorker:(TileWorker*) tileWorker;
-(void) finishTile:(METileProviderRequest *) meTileRequest;

/**Creates a factory that manages TileDownloader objects for serving up internet map tiles.*/
+(TileFactory*) createInternetTileFactory:(MEMapViewController*) meMapViewController
                              urlTemplate:(NSString*) urlTemplate
                               subDomains:(NSString*) subDomains
                               numWorkers:(int) numWorkers
                              enableAlpha:(BOOL) enableAlpha;

/**Creates a factory that manages TilePackageReader objects for serving up a package map.*/
+(TileFactory*) createPackageTileFactory:(MEMapViewController*) meMapViewController
                             packageFileName:(NSString*) packageFileName
                              numWorkers:(int) numWorkers;

@end