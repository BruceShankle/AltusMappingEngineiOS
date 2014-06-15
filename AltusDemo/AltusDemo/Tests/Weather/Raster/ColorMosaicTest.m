//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "ColorMosaicTest.h"

@implementation ColorMosaicTileProvider

- (CGRect) getSubsetInRect:(CGRect)parent withChildRect:(CGRect)child {
    return CGRectMake((child.origin.x - parent.origin.x) / parent.size.width,
                      (child.origin.y - parent.origin.y) / parent.size.height,
                      child.size.width / parent.size.width,
                      child.size.height / parent.size.height);
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


- (void) requestTileAsync:(METileProviderRequest *)meTileRequest{
    
    // get the geographic bounds of the tile (block to use in block below)
    __block CGRect tileBounds = CGRectMake(meTileRequest.minX,
                                           meTileRequest.minY,
                                           meTileRequest.maxX - meTileRequest.minX,
                                           meTileRequest.maxY - meTileRequest.minY);
    
    // filter out tiles outside of bounds
    if (!CGRectIntersectsRect(tileBounds, self.grid.bounds)) {
        meTileRequest.tileProviderResponse = kTileResponseTransparentWithChildren;
        [self.meMapViewController tileLoadComplete:meTileRequest];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *image = [self.grid createImageForBounds:tileBounds];
        meTileRequest.uiImage = image;
        meTileRequest.isOpaque = NO;
        meTileRequest.tileProviderResponse = kTileResponseRenderUIImage;
        
        //Load complete
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.meMapViewController tileLoadComplete:meTileRequest];
        });
    });
    
}

@end

@implementation ColorMosaicTest

- (id) init{
    if(self = [super init]){
        self.name=@"Color Mosaic Test";
    }
    return self;
}

- (void) beginTest{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ds.temp" ofType:@"xyz"];
    DataGrid *grid = [[DataGrid alloc] initWithFile:path
                                           andWidth:400
                                          andHeight:200
                                          andBounds:CGRectMake(-130, 20, 67, 30)];
    
    // convert data from kelvin to fahrenheit
    //int dataCount = width * height;
    for (int i = 0; i < grid.width * grid.height; ++i) {
        grid->dataArray[i] = (grid->dataArray[i] - 273.15) * 1.8000 + 32.00;
    }
    
    
    ColorMosaicTileProvider *tileProvider = [[ColorMosaicTileProvider alloc]init];
    tileProvider.meMapViewController = self.meMapViewController;
    tileProvider.isAsynchronous = YES;
    tileProvider.grid = grid;
    
    MEVirtualMapInfo *mapInfo = [[MEVirtualMapInfo alloc]init];
    mapInfo.name = self.name;
    mapInfo.mapType = kMapTypeVirtualRaster;
    mapInfo.zOrder = 20;
    mapInfo.maxLevel = 20;
    mapInfo.meTileProvider = tileProvider;
    mapInfo.isSphericalMercator = NO;
    
    [self.meMapViewController addMapUsingMapInfo:mapInfo];
}

- (void) endTest{
    //Remove the map
    [self.meMapViewController removeMap:self.name
                             clearCache:YES];
}

@end
