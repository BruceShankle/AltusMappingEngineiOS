//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import "TileWorker.h"

/**A TileWorker that reads tiles from Altus Raster map packages.*/
@interface RasterPackageReader : TileWorker
-(id) initWithFileName:(NSString*) fileName;
@property (retain) MEPackage* mePackage;
@end
