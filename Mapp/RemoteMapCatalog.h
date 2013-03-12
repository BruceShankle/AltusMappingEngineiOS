//
//  RemoteMapCatalog.h
//  Mapp
//
//  Created by Edwin B Shankle III on 7/13/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Libraries/JSONKit/JSONKit.h"

typedef struct tagRemoteMapInfo
{
	int borderSize;
	int zorder;
	int maxLevel;
	double minX;
	double minY;
	double maxX;
	double maxY;
}RemoteMapInfo;

@interface RemoteMapCatalog : NSObject

@property (retain) NSArray* streamableMapArray;
@property (readonly) int mapCount;

- (NSString*) mapName:(int) index;
- (NSString*) mapDomain:(int) index;
- (RemoteMapInfo) mapInfo:(int) index;

@end
