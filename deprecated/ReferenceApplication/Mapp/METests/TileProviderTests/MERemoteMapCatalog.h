//
//  MERemoteMapCatalog.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/21/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct tagMERemoteMapInfo
{
	int borderSize;
	int zorder;
	int maxLevel;
	double minX;
	double minY;
	double maxX;
	double maxY;
}MERemoteMapInfo;

@interface MERemoteMapCatalog : NSObject

@property (retain) NSArray* streamableMapArray;
@property (readonly) int mapCount;

- (NSString*) mapName:(int) index;
- (NSString*) mapDomain:(int) index;
- (MERemoteMapInfo) mapInfo:(int) index;

@end
