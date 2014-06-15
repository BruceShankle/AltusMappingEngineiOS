//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "DataGrid.h"

@implementation DataGrid

- (id) initWithFile: (NSString*)filePath andWidth:(int)width andHeight:(int)height andBounds:(CGRect)bounds
{
    self = [super init];
    if (self) {
        self.width = width;
        self.height = height;
        self.bounds = bounds;
        dataArray = NULL;
        [self loadFromFile:filePath];
    }
    return self;
}

- (id) initWithData:(double*)data andWidth:(int)width andHeight:(int)height andBounds:(CGRect)bounds
{
    self = [super init];
    if (self) {
        self.width = width;
        self.height = height;
        self.bounds = bounds;
        dataArray = data;
    }
    return self;
}

- (void) dealloc {
    if(dataArray){
        free(dataArray);
        dataArray=NULL;
    }
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
    dataArray = (double *)malloc(capacity * sizeof(double));
    
    // scan through data
    double value;
    int count = 0;
    while ([scanner scanDouble:&value] ) {
        dataArray[count++] = value;
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


- (double) getValueForIndexX:(int)x andY:(int)y andData:(double*)data{
    x = MIN(self.width - 1, MAX(0, x));
    y = MIN(self.height - 1, MAX(0, y));
    return data[x + y * self.width];
}

- (double) getValueForIndexX:(int)x andY:(int)y {
    x = MIN(self.width - 1, MAX(0, x));
    y = MIN(self.height - 1, MAX(0, y));
    return dataArray[x + y * self.width];
}

- (double) getValueForLocation:(CLLocationCoordinate2D)location {
    double s = (location.longitude - self.bounds.origin.x) / self.bounds.size.width;
    double t = (location.latitude - self.bounds.origin.y) / self.bounds.size.height;
    
    int x = s * self.width;
    int y = t * self.height;
    
    return [self getValueForIndexX:x andY:y];
}

- (double) getValueForLocationBilinear:(CLLocationCoordinate2D)location andDataSet:(double*)data {
    double s = (location.longitude - self.bounds.origin.x) / self.bounds.size.width;
    double t = (location.latitude - self.bounds.origin.y) / self.bounds.size.height;
    
    s *= self.width;
    t *= self.height;
    
    int sMin = s;
    int tMin = t;
    
    double fracX = s - sMin;
    double fracY = t - tMin;
    
    double x0 = [self getValueForIndexX:sMin        andY:tMin andData:data];
    double x1 = [self getValueForIndexX:sMin + 1    andY:tMin andData:data];
    
    double x = x0 + fracX * (x1 - x0);
    
    double y0 = [self getValueForIndexX:sMin        andY:tMin + 1 andData:data];
    double y1 = [self getValueForIndexX:sMin + 1    andY:tMin + 1 andData:data];
    
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

- (double) transformLatitude:(double) coord
{
    coord = coord * M_PI / 180.0;
    double result = log(tan(coord) + 1/cos(coord));
    return result;
}

- (double) inverseTransformLatitude:(double)coord
{
    coord = atan(sinh(coord));
    return coord * 180.0 / M_PI;
}

- (UIImage*) imageFromBytes:(unsigned char *)bytes {
    const int WIDTH = 256;
    const int HEIGHT = 256;
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext=CGBitmapContextCreate(bytes, WIDTH, HEIGHT, 8, 4*WIDTH, colorSpace,  kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    CFRelease(colorSpace);
    CGImageRef cgImage=CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    
    UIImage * newimage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return newimage;
}

- (uint) getColorForLocation:(CLLocationCoordinate2D)location {
    // get value from source data at location
    double value = [self getValueForLocationBilinear:location andDataSet:dataArray];

    // get uint color
    return [self getColorForValue:value];
}

- (UIImage *) createImageForBounds:(CGRect)bounds {
    // size of the tile image
    const int WIDTH = 256;
    const int HEIGHT = 256;
    
    // allocate data for the tile image and clear it
    unsigned char *imageData = (unsigned char*)malloc(WIDTH * HEIGHT * 4);
    memset(imageData, 0, WIDTH * HEIGHT * 4);
    
    // get mercator latitude bounds
    double normalizedMinY = [self transformLatitude:bounds.origin.y];
    double normalizedMaxY = [self transformLatitude:bounds.origin.y + bounds.size.height];
    
    for (int y = 0; y < HEIGHT; ++y) {
        
        // interpolate y coordinate in mercator space
        double t = (y + 0.5) / HEIGHT;
        double mercatorY = normalizedMinY + t * (normalizedMaxY - normalizedMinY);
        
        // convert mercator space y to latitude
        CLLocationCoordinate2D sampleLocation;
        sampleLocation.latitude = [self inverseTransformLatitude:mercatorY];
        
        for (int x = 0; x < WIDTH; ++x) {
            
            // interpolate x coordinate
            double s = (x + 0.5) / WIDTH;
            sampleLocation.longitude = bounds.origin.x + s * bounds.size.width;
            
            // filter out pixels outside bounds
            if (!CGRectContainsPoint(self.bounds, CGPointMake(sampleLocation.longitude, sampleLocation.latitude)))
                continue;
            
            int color = [self getColorForLocation:sampleLocation];
            
            // invert Y index because images start with y = 0 at the top
            int invY = HEIGHT - y - 1;
            
            // swap bytes in uint color in order to assign them to a byte array
            unsigned char *pixel = &imageData[(x + invY * WIDTH)*4];
            pixel[0] = (color & 0xff000000) >> 24;
            pixel[1] = (color & 0xff0000) >> 16;
            pixel[2] = (color & 0xff00) >> 8;
            pixel[3] = (color & 0xff);
        }
    }
    
    
    UIImage *result = [self imageFromBytes:imageData];
    free(imageData);
    
    
    return result;
}

@end
