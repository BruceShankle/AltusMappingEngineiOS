//
//  RadarTest.h
//  AltusDemo
//
//  Created by Jacob Beaudoin on 5/29/14.
//  Copyright (c) 2014 BA3, LLC. All rights reserved.
//

#import "METest.h"
#import "TileWorker.h"
#import "DataGrid.h"

@interface RadarTest : METest

@end


@interface RadarDataGrid : DataGrid {
    double* typeDataArray;
}

- (id) initWithData:(double*)reflectivityData
        andTypeData:(double*)preciptationTypeData
           andWidth:(int)width
          andHeight:(int)height
          andBounds:(CGRect)bounds;

- (void) dealloc;
- (uint) getColorForLocation:(CLLocationCoordinate2D)location;
+ (uint) getColorForReflectivity:(double)reflectivity andType:(double)type;

- (double) transformLatitude:(double)coord;
- (double) inverseTransformLatitude:(double)coord;
@end

/**A TileWorker that reads tiles from Altus Raster map packages.*/
@interface RadarPackageReader : TileWorker
-(id) initWithFileName:(NSString*) fileName;

@property (retain) MEPackage* mePackage;
@end


