//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../../METest.h"
#import "../../METestCategory.h"

/**Demonstrates:
 1. on-device marker clustering
 2. into memory
 3. with pre-cached images
 4. where all marker are set prior to adding map.*/
@interface BusStopsMemoryCached : METest<MEMarkerMapDelegate>
@end

/**Demonstrates:
 1. on-device clustering
 2. into memory
 3. with non-cached images
 4. where marker data is requested piecemeal on a background thread as needed*/
@interface BusStopsMemoryAsync : METest<MEMarkerMapDelegate>
@end

/**Demonstrates:
 1. on-device clustering
 2. into memory
 3. with non-cached images
 4. where marker data is requested piecemeal on a foreground thread as needed*/
@interface BusStopsMemorySync : METest<MEMarkerMapDelegate>
@end