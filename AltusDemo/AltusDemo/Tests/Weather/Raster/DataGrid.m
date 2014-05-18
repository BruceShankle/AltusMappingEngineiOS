//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "DataGrid.h"

@implementation DataGrid

- (id) initWithFile: (NSString*)filePath andWidth:(int)width andHeight:(int)height andBounds:(CGRect)bounds;
{
    self = [super init];
    if (self) {
        self.width = width;
        self.height = height;
        self.bounds = bounds;
        self.dataArray = NULL;
        [self loadFromFile:filePath];
    }
    return self;
}

- (void) loadFromFile:(NSString *)filePath {
    
    // read file into a string
    NSString *fileString = [NSString stringWithContentsOfFile:filePath
													 encoding:NSUTF8StringEncoding
														error:nil ];
    
    // set up scanner to scan through string
	NSScanner *scanner = [NSScanner scannerWithString:fileString];
	[scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString:@"\n, "]];
	
    // allocate the array of data
    uint capacity = self.width * self.height;
    self.dataArray = (double *)malloc(capacity * sizeof(double));
    
    // scan through data
    double value;
    int count = 0;
    while ([scanner scanDouble:&value] ) {
        self.dataArray[count++] = value;
    }
}

- (uint) getColorForValue:(double)value {
    
    uint color;
    if (value < -10) {
        color = 0xda75deff;
    } else if (value < 0) {
        color = 0x8632b8ff;
    } else if (value < 10) {
        color = 0x2d2d96ff;
    } else if (value < 20) {
        color = 0x05bce5ff;
    } else if (value < 30) {
        color = 0x01d165ff;
    } else if (value < 40) {
        color = 0x77d004ff;
    } else if (value < 50) {
        color = 0xfeff22ff;
    } else if (value < 60) {
        color = 0xf86300ff;
    } else if (value < 70) {
        color = 0xcc2002ff;
    } else {
        color = 0x9f0702ff;
    }
    
    return color;
}


- (double) getValueForIndexX:(int)x andY:(int)y {
    x = MIN(self.width - 1, MAX(0, x));
    y = MIN(self.height - 1, MAX(0, y));
    return self.dataArray[x + y * self.width];
}

- (double) getValueForLocation:(CLLocationCoordinate2D)location {
    double s = (location.longitude - self.bounds.origin.x) / self.bounds.size.width;
    double t = (location.latitude - self.bounds.origin.y) / self.bounds.size.height;
    
    int x = s * self.width;
    int y = t * self.height;
    
    return [self getValueForIndexX:x andY:y];
}

- (double) getValueForLocationBilinear:(CLLocationCoordinate2D)location {
    double s = (location.longitude - self.bounds.origin.x) / self.bounds.size.width;
    double t = (location.latitude - self.bounds.origin.y) / self.bounds.size.height;
    
    s *= self.width;
    t *= self.height;
    int sMin = s;
    int tMin = t;
    
    double fracX = s - sMin;
    double fracY = t - tMin;
    
    double x0 = [self getValueForIndexX:sMin        andY:tMin];
    double x1 = [self getValueForIndexX:sMin + 1    andY:tMin];
    
    double x = x0 + fracX * (x1 - x0);
    
    double y0 = [self getValueForIndexX:sMin        andY:tMin + 1];
    double y1 = [self getValueForIndexX:sMin + 1    andY:tMin + 1];
    
    double y = y0 + fracX * (y1 - y0);
    
    return x + fracY * (y - x);
}

- (CGRect) getBoundsForIndexX:(int)x andY:(int)y {
    
    float fx = x / (float)self.width;
    float fy = y / (float)self.height;
    
    return CGRectMake(self.bounds.origin.x + fx * self.bounds.size.width,
                      self.bounds.origin.y + fy * self.bounds.size.height,
                      (1.0/self.width) * self.bounds.size.width,
                      (1.0/self.height) * self.bounds.size.height);
}

@end
