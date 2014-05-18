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
                               enableAlpha:(BOOL) enableAlpha;{
    
    MEVirtualMapInfo* virtualMapInfo = [[MEVirtualMapInfo alloc]init];
    virtualMapInfo.name = mapName;
    virtualMapInfo.maxLevel = maxLevel;
    virtualMapInfo.isSphericalMercator = YES;
    virtualMapInfo.meTileProvider = [TileFactory createInternetTileFactory:meMapViewController
                                                               urlTemplate:urlTemplate
                                                                subDomains:subDomains
                                                                numWorkers:numWorkers
                                                               enableAlpha:enableAlpha];
    virtualMapInfo.meMapViewController = meMapViewController;
    virtualMapInfo.zOrder = zOrder;
    virtualMapInfo.loadingStrategy = kHighestDetailOnly;
    virtualMapInfo.contentType = kZoomDependent;
    
    return virtualMapInfo;
}
@end
