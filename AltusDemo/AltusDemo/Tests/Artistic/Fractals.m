//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "Fractals.h"
#import "../Utilities/TileFactory.h"


//Creates SierpinksiTriangle images.
@implementation SierpinskiTriangleWorker


+ (UIImage*) imageFromData:(UInt8*)buffer
                     width:(int)width
                    height:(int) height{
    
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext=CGBitmapContextCreate(buffer, width, height, 8, 4*width, colorSpace,  kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    CFRelease(colorSpace);
    CGImageRef cgImage=CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    
    UIImage * newimage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return newimage;
}

+(void)setPixel:(UInt8*)buffer
          width:(int)width
              x:(int)x
              y:(int)y
              r:(UInt8)r
              g:(UInt8)g
              b:(UInt8)b
              a:(UInt8)a{
    buffer[x*4 + y*(width*4)+0] = r;
    buffer[x*4 + y*(width*4)+1] = g;
    buffer[x*4 + y*(width*4)+2] = b;
    buffer[x*4 + y*(width*4)+3] = a;
}

+(CGPoint) midPoint:(CGPoint) pointA
             pointB:(CGPoint) pointB{
    
    return CGPointMake((pointA.x + pointB.x) / 2,
                       (pointA.y + pointB.y) / 2);
    
}

- (void) doWork:(METileProviderRequest *)meTileRequest{
    
    //Allocate memory for an image
    int width = 380;
    int height = 380;
    UInt8* imageData = calloc(width*height*4, sizeof(UInt8));
    if(imageData==NULL){
        meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
        return;
    }
    
    
    //Use the 'chaos game' to compute the fractal
    CGPoint left = CGPointMake(0,height-1);
    CGPoint right = CGPointMake(width-1,height-1);
    CGPoint top= CGPointMake(width/2+1, 0);
    CGPoint points[3] = {left,right,top};
    CGPoint pivot = left;
    for(int i=0; i<50000; i++){
        int pointIndex = (int)[METest randomDouble:0 max:2.9];
        CGPoint randomCorner = points[pointIndex];
        pivot = [SierpinskiTriangleWorker midPoint:pivot pointB:randomCorner];
        [SierpinskiTriangleWorker setPixel:imageData
                                     width:width
                                         x:(int)pivot.x
                                         y:(int)pivot.y
                                         r:255
                                         g:255
                                         b:255
                                         a:255];
    }
    
    
    //Convert to a UIImage
    meTileRequest.uiImage = [SierpinskiTriangleWorker imageFromData:imageData
                                                              width:width
                                                             height:height];
    
    //Free image memory
    free(imageData);
    
    //Sleep to make this even slower?
    if(self.sleepTimePerTile>0){
        [NSThread sleepForTimeInterval:self.sleepTimePerTile];
    }
    
    //This will have transparency
    meTileRequest.isOpaque = NO;
    meTileRequest.tileProviderResponse = kTileResponseRenderUIImage;
}

@end

///////////////////////////////////////////////////////////////////
@implementation SierpinskiTriangle

- (id) init {
	if(self=[super init]){
		self.name = @"Fractal: Workers 1, Sleep 0, Pri Def";
        self.sleepTimePerTile = 0;
        self.workerCount = 1;
        self.targetQueuePriority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
	}
	return self;
}

-(void) beginTest{
    TileFactory* newFactory = [[TileFactory alloc]init];
    newFactory.targetQueuePriority = self.targetQueuePriority;
    newFactory.meMapViewController = self.meMapViewController;
    
    for(int i=0; i<self.workerCount; i++){
        SierpinskiTriangleWorker* worker = [[SierpinskiTriangleWorker alloc]init];
        worker.sleepTimePerTile = self.sleepTimePerTile;
        [newFactory addWorker:worker];
    }
    
    // Create a virtual map with the tile factory as the tile provider
    MEVirtualMapInfo* virtualMapInfo = [[MEVirtualMapInfo alloc]init];
    virtualMapInfo.name = self.name;
    virtualMapInfo.maxLevel = 20;
    virtualMapInfo.isSphericalMercator = NO;
    virtualMapInfo.meTileProvider = newFactory;
    virtualMapInfo.zOrder = 100;
    virtualMapInfo.loadingStrategy = kHighestDetailOnly;
    virtualMapInfo.contentType = kZoomIndependent;
    [self.meMapViewController addMapUsingMapInfo:virtualMapInfo];
}

-(void) endTest{
    [self.meMapViewController removeMap:self.name clearCache:YES];
}
@end

///////////////////////////////////////////////////////////////////
@implementation SierpinskiTriangleWorkers4
- (id) init {
	if(self=[super init]){
		self.name = @"Fractal: Workers 4, Sleep 0, Pri Def";
        self.workerCount = 4;
	}
	return self;
}
@end

///////////////////////////////////////////////////////////////////
@implementation SierpinskiTriangleWorkers3Sleep3
- (id) init {
	if(self=[super init]){
		self.name = @"Fractal: Workers 3, Sleep 3, Pri Def";
        self.sleepTimePerTile = 3;
        self.workerCount = 3;
	}
	return self;
}
@end

///////////////////////////////////////////////////////////////////
@implementation SierpinskiTriangleLow
- (id) init {
	if(self=[super init]){
		self.name = @"Fractal: Workers 1, Sleep 0, Pri Low";
        self.sleepTimePerTile = 0;
        self.workerCount = 1;
        self.targetQueuePriority = DISPATCH_QUEUE_PRIORITY_LOW;
	}
	return self;
}
@end

///////////////////////////////////////////////////////////////////
@implementation SierpinskiTriangleLowSleep1
- (id) init {
	if(self=[super init]){
		self.name = @"Fractal: Workers 1, Sleep 0, Pri Low";
        self.sleepTimePerTile = 1;
        self.workerCount = 1;
        self.targetQueuePriority = DISPATCH_QUEUE_PRIORITY_LOW;
	}
	return self;
}
@end

///////////////////////////////////////////////////////////////////
@implementation SierpinskiTriangleBackground
- (id) init {
	if(self=[super init]){
		self.name = @"Fractal: Workers 1, Sleep 0, Pri Background";
        self.sleepTimePerTile = 0;
        self.workerCount = 1;
        self.targetQueuePriority = DISPATCH_QUEUE_PRIORITY_BACKGROUND;
	}
	return self;
}
@end

///////////////////////////////////////////////////////////////////
@implementation SierpinskiTriangleBackgroundSleep1
- (id) init {
	if(self=[super init]){
		self.name = @"Fractal: Workers 1, Sleep 1, Pri Background";
        self.sleepTimePerTile = 1;
        self.workerCount = 1;
        self.targetQueuePriority = DISPATCH_QUEUE_PRIORITY_BACKGROUND;
	}
	return self;
}
@end

