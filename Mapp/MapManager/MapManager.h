//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#pragma once
#include "MEMapCategory.h"
#include "MEMap.h"

@interface MapManager : NSObject

@property (retain) NSArray* mapCategories;

- (void) createDirectory:(NSString*) path;
- (NSArray*) scanCategories;
- (void) refresh;
- (MEMapCategory*) categoryWithName:(NSString*) name;


@end