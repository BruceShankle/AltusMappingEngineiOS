//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import "../METest.h"
#import "../METestMovingObject.h"
@interface DynamicLines : METest
@property (retain) MELineStyle* blueLineStyle;
@property (retain) MELineStyle* redLineStyle;
@property (retain) MELineStyle* yellowLineStyle;
@property (retain) NSMutableArray* redPath;
@property (retain) NSMutableArray* bluePath;
@property (retain) NSMutableArray* yellowPath;
@end
