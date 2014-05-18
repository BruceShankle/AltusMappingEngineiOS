//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <AltusMappingEngine/AltusMappingEngine.h>
#import "TileFactory.h"

/** A conveniience class to assist with the creation of map info objects.*/
@interface MapFactory : NSObject
/**Creates an virtual map info object for an internet map.*/
+(MEVirtualMapInfo*) createInternetMapInfo:(MEMapViewController*) meMapViewController
                                   mapName:(NSString*) mapName
                               urlTemplate:(NSString*) urlTemplate
                                subDomains:(NSString*) subDomains
                                  maxLevel:(unsigned int) maxLevel
                                    zOrder:(unsigned int) zOrder
                                numWorkers:(int) numWorkers
                               enableAlpha:(BOOL) enableAlpha;
@end
