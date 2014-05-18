//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import <AltusMappingEngine/AltusMappingEngine.h>
#import <Foundation/Foundation.h>

//Forward declarations
@class TileFactory;

/////////////////////////////////////////////////////////////////////
//Serves as base class for an object that does the work
//of downloading, retrieving, or creating a tile
//TileWorkers do their work in the context of a TileFactory
//You should create a class that extends this class
//and overrides the doWork function.
@interface TileWorker : NSObject
@property (retain) dispatch_queue_t serialQueue;
@property (assign) BOOL isBusy;
@property (retain) TileFactory* tileFactory;
-(void) startTile:(METileProviderRequest *) meTileRequest;
-(void) doWork:(METileProviderRequest *) meTileRequest;
@end

/////////////////////////////////////////////////////////////////////
/**A tile worker that downloads tiles from the internet.*/
@interface TileDownloader : TileWorker
/** Initialize instance.
 @param urlTemplate Template for downloads. For example:
 If you have multiple subdomains you would use a url string like this:
 http://{s}.tiles.mapbox.com/v3/mymap/{z}/{x}/{y}.jpg
 {s} is not required, but if you do use it, make sure the subDomains parameter
 contains a comma delimited list of subdomains, i.e.: a,b,c,d
 @param subDomains Comma separate list of subdomains

 @param enableAlpha Set to NO for base maps tha cover the planet. Set to yes for maps that have sparse coverage, i.e. wather.*/
-(id) initWithURLTemplate:(NSString*) urlTemplate
               subDomains:(NSString*) subDomains
              enableAlpha:(BOOL) enableAlpha;
@property (retain) NSString* urlTemplate;
@property (retain) NSArray* subDomains;
@property (assign) int currentSubdomain;
@property (assign) bool enableAlpha;
@end

/////////////////////////////////////////////////////////////////////
//Serves as a tile provider that manages TileWorker
//objects. This demonstrates a farming out work
//on a per-tile basis and only doing the work
//that is necessary to serve up data that is in view.
@interface TileFactory : METileProvider
@property (retain) NSMutableArray* activeTileRequests;
@property (retain) NSMutableArray* tileWorkers;
-(void) addWorker:(TileWorker*) tileWorker;
-(void) finishTile:(METileProviderRequest *) meTileRequest;
+(TileFactory*) createInternetTileFactory:(MEMapViewController*) meMapViewController
                              urlTemplate:(NSString*) urlTemplate
                               subDomains:(NSString*) subDomains
                               numWorkers:(int) numWorkers
                              enableAlpha:(BOOL) enableAlpha;

@end