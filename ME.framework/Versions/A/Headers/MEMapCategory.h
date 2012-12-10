//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import "MEMapObjectBase.h"

@interface MEMapCategory : MEMapObjectBase

@property (nonatomic, retain) NSMutableArray* Maps;
@property bool IsTerrainCategory;
@property bool IsAnnotationCategory;
-(void) scanMaps;

@end
