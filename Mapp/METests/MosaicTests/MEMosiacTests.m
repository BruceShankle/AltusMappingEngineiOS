//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MEMosiacTests.h"

@implementation MESphericalMercatorMosiacPNG

-(id) init{
    if(self==[super init]){
        self.name = @"Spherical Mercator PNG";
        self.fileName = @"SphericalMercatorMosaic3.png";
        self.minX = -129.999981230325;
        self.minY = 5.00002918648632;
        self.maxX = -49.9999927808942;
        self.maxY = 58.2000215053578;
        self.compressTextures = NO;
        self.mapLoadingStrategy = kHighestDetailOnly;
        self.maxLevel = 8;
        self.zOrder = 10;
        self.defaultTileName = @"grayGrid";
    }
    return self;
}

- (void) dealloc{
    self.fileName = nil;
    self.defaultTileName = nil;
    [super dealloc];
}

- (void) start{
	if(self.isRunning){
		return;
	}
    self.isRunning = YES;
    [self addMap];
    [self lookAtMap];
}

- (void) stop{
    if(!self.isRunning){
        return;
    }
    self.isRunning = NO;
    [self removeMap];
}

- (void) addMap{
    NSString* filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.fileName];
    [self.meMapViewController addSphericalMercatorMosaicRasterMap:self.name
                                                    imageFileName:filePath
                                                             minX:self.minX
                                                             minY:self.minY
                                                             maxX:self.maxX
                                                             maxY:self.maxY
                                                         maxLevel:self.maxLevel
                                                  defaultTileName:self.defaultTileName
                                                 compressTextures:self.compressTextures
                                                           zOrder:self.zOrder
                                               mapLoadingStrategy:self.mapLoadingStrategy];
    
}

- (void) lookAtMap{
    MELocationBounds mapBounds;
    mapBounds.min.longitude = self.minX;
    mapBounds.min.latitude = self.minY;
    mapBounds.max.longitude = self.maxX;
    mapBounds.max.latitude = self.maxY;
    MELocation mapLocation = [self.meMapViewController.meMapView locationThatFitsBounds:mapBounds
                                                                   withHorizontalBuffer:30
                                                                     withVerticalBuffer:30];
    
    [self.meMapViewController.meMapView setLocation:mapLocation animationDuration:2];
    
}
- (void) removeMap{
    [self.meMapViewController removeMap:self.name
                             clearCache:NO];
}

@end
