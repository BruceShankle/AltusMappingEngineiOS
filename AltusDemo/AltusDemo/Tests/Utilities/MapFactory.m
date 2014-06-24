//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "MapFactory.h"

@implementation MapFactory

+(MEVirtualMapInfo*) createInternetMapInfo:(MEMapViewController*) meMapViewController
                                   mapName:(NSString*) mapName
                               urlTemplate:(NSString*) urlTemplate
                                subDomains:(NSString*) subDomains
                                  maxLevel:(unsigned int) maxLevel
                                    zOrder:(unsigned int) zOrder
                                numWorkers:(int) numWorkers
                                  useCache:(BOOL) useCache
                               enableAlpha:(BOOL) enableAlpha;{
    
    MEVirtualMapInfo* virtualMapInfo = [[MEVirtualMapInfo alloc]init];
    virtualMapInfo.name = mapName;
    virtualMapInfo.maxLevel = maxLevel;
    virtualMapInfo.isSphericalMercator = YES;
    virtualMapInfo.meTileProvider = [TileFactory createInternetTileFactory:meMapViewController
                                                               urlTemplate:urlTemplate
                                                                subDomains:subDomains
                                                                numWorkers:numWorkers
                                                                  useCache:useCache
                                                               enableAlpha:enableAlpha];
    virtualMapInfo.zOrder = zOrder;
    virtualMapInfo.loadingStrategy = kHighestDetailOnly;
    virtualMapInfo.contentType = kZoomDependent;
    
    return virtualMapInfo;
}

/**Creates an virtual map info object for a packaged raster map.*/
+(MEVirtualMapInfo*) createRasterPackageMapInfo:(MEMapViewController*) meMapViewController
                                        mapName:(NSString*) mapName
                                packageFileName:(NSString*) packageFileName
                            isSphericalMercator:(BOOL) isSphericalMercator
                                         zOrder:(unsigned int) zOrder
                                     numWorkers:(int) numWorkers{
    
    MEPackage* package = [[MEPackage alloc]initWithFileName:packageFileName];
    
    MEVirtualMapInfo* virtualMapInfo = [[MEVirtualMapInfo alloc]init];
    virtualMapInfo.name = mapName;
    virtualMapInfo.maxLevel = package.maxLevel;
    virtualMapInfo.isSphericalMercator = isSphericalMercator;
    virtualMapInfo.meTileProvider = [TileFactory createPackageTileFactory:meMapViewController
                                                          packageFileName:packageFileName
                                                               numWorkers:numWorkers];
    virtualMapInfo.zOrder = zOrder;
    virtualMapInfo.loadingStrategy = kHighestDetailOnly;
    virtualMapInfo.contentType = kZoomDependent;
    
    return virtualMapInfo;
}
@end
