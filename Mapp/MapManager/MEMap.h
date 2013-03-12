//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import "MEMapObjectBase.h"

@interface MEMap : MEMapObjectBase
@property bool IsBaseMap;
@property bool IsTerrainMap;
@property bool IsVirtualMap;

-(id) initWithName:(NSString*) name andCategory:(NSString*) category andPath:(NSString*) path;

@end
