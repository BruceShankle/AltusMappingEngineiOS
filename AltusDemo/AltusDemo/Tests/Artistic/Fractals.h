//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"
#import "../Utilities/TileWorker.h"

@interface SierpinskiTriangleWorker : TileWorker
@property (assign) float sleepTimePerTile;
@end

@interface SierpinskiTriangle : METest
@property (assign) float sleepTimePerTile;
@property (assign) int workerCount;
/**The queue on which the worker works. Default is DISPATCH_QUEUE_PRIORITY_DEFAULT.
 You can set this to:
 DISPATCH_QUEUE_PRIORITY_HIGH
 DISPATCH_QUEUE_PRIORITY_DEFAULT
 DISPATCH_QUEUE_PRIORITY_LOW
 DISPATCH_QUEUE_PRIORITY_BACKGROUND*/
@property (assign) dispatch_queue_priority_t targetQueuePriority;
@end

@interface SierpinskiTriangleWorkers4 : SierpinskiTriangle
@end

@interface SierpinskiTriangleWorkers3Sleep3 : SierpinskiTriangle
@end

@interface SierpinskiTriangleLow : SierpinskiTriangle
@end

@interface SierpinskiTriangleLowSleep1 : SierpinskiTriangle
@end

@interface SierpinskiTriangleBackground : SierpinskiTriangle
@end

@interface SierpinskiTriangleBackgroundSleep1 : SierpinskiTriangle
@end

