//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DataGrid : NSObject {
@public
    double *dataArray;
}

@property (assign) CGRect bounds;
@property (assign) int width;
@property (assign) int height;

- (id) initWithFile:(NSString*)filePath andWidth:(int)width andHeight:(int)height andBounds:(CGRect)bounds;
- (id) initWithData:(double*)dataArray andWidth:(int)width andHeight:(int)height andBounds:(CGRect)bounds;
- (void) dealloc;

- (double) transformLatitude:(double)coord;
- (double) inverseTransformLatitude:(double)coord;

- (void) loadFromFile:(NSString*)filePath;
- (double) getValueForLocation:(CLLocationCoordinate2D)location;
- (double) getValueForLocationBilinear:(CLLocationCoordinate2D)location andDataSet:(double*)data;
- (uint) getColorForLocation:(CLLocationCoordinate2D)location;
- (uint) getColorForValue:(double)value;
- (UIImage*) createImageForBounds:(CGRect)bounds;
@end

