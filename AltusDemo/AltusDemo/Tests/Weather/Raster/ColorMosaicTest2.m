//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "ColorMosaicTest2.h"

@implementation ColorMosaicTileWorker

-(id) init{
    if(self=[super init]){
        //Do custom init logic here
    }
    return self;
}

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

- (double) mercatorLatitude:(double) coord
{
    coord = coord * M_PI / 180.0;
    double result = log(tan(coord) + 1/cos(coord));
    return result;
}

- (double) inverseMercatorLatitude:(double)coord
{
    coord = atan(sinh(coord));
    return coord * 180.0 / M_PI;
}

-(void) doWork:(METileProviderRequest *) meTileRequest{
    
    // get the geographic bounds of the tile (block to use in block below)
    CGRect tileBounds = CGRectMake(meTileRequest.minX,
                                   meTileRequest.minY,
                                   meTileRequest.maxX - meTileRequest.minX,
                                   meTileRequest.maxY - meTileRequest.minY);
    
    // filter out tiles outside of bounds
    if (!CGRectIntersectsRect(tileBounds, self.grid.bounds)) {
        meTileRequest.tileProviderResponse = kTileResponseTransparentWithChildren;
        return;
    }
    
    // create image from data
    UIImage *image = [self.grid createImageForBounds:tileBounds];
    
    // fill in response object
    meTileRequest.uiImage = image;
    meTileRequest.isOpaque = NO;
    meTileRequest.tileProviderResponse = kTileResponseRenderUIImage;
}

@end

@implementation ColorMosaicTest2

- (id) init{
    if(self = [super init]){
        self.name=@"Color Mosaic Test 2";
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
    
    //Create a tile factory
    TileFactory* tileFactory = [[TileFactory alloc]init];
    tileFactory.meMapViewController = self.meMapViewController;
    
    //Create some workers and put them in the factory
    for(int i=0; i<2; i++){
        ColorMosaicTileWorker* worker = [[ColorMosaicTileWorker alloc]init];
        worker.grid = grid;
        [tileFactory addWorker:worker];
    }
    
    //Add a virtual map
    MEVirtualMapInfo *mapInfo = [[MEVirtualMapInfo alloc]init];
    mapInfo.name = self.name;
    mapInfo.mapType = kMapTypeVirtualRaster;
    mapInfo.zOrder = 20;
    mapInfo.maxLevel = 20;
    mapInfo.meTileProvider = tileFactory;
    mapInfo.isSphericalMercator = NO;
    
    [self.meMapViewController addMapUsingMapInfo:mapInfo];
}

- (void) endTest{
    //Remove the map
    [self.meMapViewController removeMap:self.name
                             clearCache:YES];
}

@end
