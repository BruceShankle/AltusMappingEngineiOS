//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import <AltusMappingEngine/AltusMappingEngine.h>
#import <Foundation/Foundation.h>

@interface RasterTileProvider : METileProvider
@property (retain) NSString* urlTemplate;
@property (retain) NSMutableArray* subDomains;
@property (retain) NSMutableArray* serialQueues;
@property (assign) int currentQueue;
@property (assign) int currentSubdomain;
-(id) initWithURLTemplate:(NSString*) urlTemplate
               queueCount:(int) queueCount;
@property (assign) BOOL tilesContainTransparency;

@end
