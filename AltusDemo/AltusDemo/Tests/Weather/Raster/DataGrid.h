//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DataGrid : NSObject

@property (assign) CGRect bounds;
@property (assign) int width;
@property (assign) int height;
@property (assign) double *dataArray;

- (void) loadFromFile:(NSString*)filePath;
- (double) getValueForLocation:(CLLocationCoordinate2D)location;
- (double) getValueForLocationBilinear:(CLLocationCoordinate2D)location;
- (uint) getColorForValue:(double)value;
- (id) initWithFile:(NSString*)filePath andWidth:(int)width andHeight:(int)height andBounds:(CGRect)bounds;
@end
