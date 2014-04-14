//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import "MEMapObjectBase.h"
#import "MEMap.h"

@interface MEMapCategory : MEMapObjectBase

@property (nonatomic, retain) NSMutableArray* Maps;
@property bool IsTerrainCategory;
-(void) scanMaps;
-(MEMap*) mapWithName:(NSString*) name;
@end
