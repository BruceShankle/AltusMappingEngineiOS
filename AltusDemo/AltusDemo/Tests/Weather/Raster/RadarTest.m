//
//  RadarTest.m
//  AltusDemo
//
//  Created by Jacob Beaudoin on 5/29/14.
//  Copyright (c) 2014 BA3, LLC. All rights reserved.
//

#import "RadarTest.h"
#import "TileFactory.h"
#import "DataGrid.h"

@implementation RadarTest

- (id) init{
    if(self = [super init]){
        self.name=@"Radar Test";
    }
    return self;
}

- (void) beginTest{
    
    // Manually create workers and add then to a TileFactory
    NSString *packageFileName = [[NSBundle mainBundle] pathForResource:@"radar" ofType:@"sqlite"];
    TileFactory* newFactory = [[TileFactory alloc]init];
    newFactory.meMapViewController = self.meMapViewController;
    for(int i=0; i<3; i++){
        [newFactory addWorker:[[RadarPackageReader alloc]initWithFileName:packageFileName]];
    }
    
    // Create a virtual map with the tile factory as the tile provider
    MEVirtualMapInfo* virtualMapInfo = [[MEVirtualMapInfo alloc]init];
    virtualMapInfo.name = self.name;
    virtualMapInfo.maxLevel = 16;
    virtualMapInfo.isSphericalMercator = NO;
    virtualMapInfo.meTileProvider = newFactory;
    virtualMapInfo.zOrder = 100;
    virtualMapInfo.loadingStrategy = kHighestDetailOnly;
    virtualMapInfo.contentType = kZoomDependent;
    [self.meMapViewController addMapUsingMapInfo:virtualMapInfo];
}

- (void) endTest{
    //Remove the map
    [self.meMapViewController removeMap:self.name
                             clearCache:YES];
}

@end

@implementation RadarDataGrid


- (id) initWithData:(double*)reflectivityData
        andTypeData:(double*)preciptationTypeData
           andWidth:(int)width
          andHeight:(int)height
          andBounds:(CGRect)bounds {
    
    self = [super init];
    if (self) {
        self.width = width;
        self.height = height;
        self.bounds = bounds;
        
        dataArray = reflectivityData;
        typeDataArray = preciptationTypeData;
    }
    return self;
}

- (void) dealloc {
    if(dataArray){
        free(dataArray);
        dataArray=NULL;
    }
    if(typeDataArray){
        free(typeDataArray);
        typeDataArray=NULL;
    }
}

// overload this to take into account 2 channel data
- (uint) getColorForLocation:(CLLocationCoordinate2D)location {
    double reflectivity = [self getValueForLocationBilinear:location andDataSet:dataArray];
    double precipitation = [self getValueForLocationBilinear:location andDataSet:typeDataArray];

    return [RadarDataGrid getColorForReflectivity:reflectivity andType:precipitation];
}

+ (uint) getColorForReflectivity:(double)reflectivity andType:(double)type {
    
    // to round i'm using this equation: (int)(doubleValue + 0.5)
    int reflectivityIndex = reflectivity + 0.5;
    int typeIndex = type + 0.5;
    
    // colors for radar
    int colors[] = {
        0x00000000, 0x7bb06aff, 0x6b9f5bff, 0x5a8e4bff, 0x4a7d3cff, 0x3a6d2dff, 0x295c1dff, 0x194b0eff, 0xd7d700ff, 0xf5a60fff, 0xe19d5fff, 0xb24d00ff, 0xce2019ff, 0xb01812ff, 0x92101cff, 0xff20dfff,
        
        0x00000000, 0xffdcdcff, 0xffccccff, 0xffbcbcff, 0xffacacff, 0xff9c9cff, 0xfd8c8cff, 0xff7c7cff, 0xff6c6cff, 0xff6060ff, 0xff5050ff, 0xff4040ff, 0xff3030ff, 0xff2020ff, 0xff1010ff, 0xff0000ff,
        
        0x00000000, 0xffdcdcff, 0xffccccff, 0xffbcbcff, 0xffacacff, 0xff9c9cff, 0xfd8c8cff, 0xff7c7cff, 0xff6c6cff, 0xff6060ff, 0xff5050ff, 0xff4040ff, 0xff3030ff, 0xff2020ff, 0xff1010ff, 0xff0000ff,
        
        0x00000000, 0x00efffff, 0x00d4ffff, 0x00bfffff, 0x00adffff, 0x0094ffff, 0x007bffff, 0x0068ffff, 0x0055ffff, 0x0443f5ff, 0x0026ffff, 0x000effff, 0x0000ffff, 0x0000dfff, 0x0000cbff, 0x000089ff,
    };
    
    return colors[reflectivityIndex + typeIndex * 16];
}

// overload transform to be pass-through because data is already in mercator
- (double) transformLatitude:(double)coord {
    return coord;
}

- (double) inverseTransformLatitude:(double)coord {
    return coord;
}

@end

@implementation RadarPackageReader

-(id)initWithFileName:(NSString *)fileName{
    if(self=[super init]){
        _mePackage = [[MEPackage alloc]initWithFileName:fileName];
    }
    return self;
}


- (RadarDataGrid *) createGridFromData:(NSData*)data andBounds:(CGRect)bounds {
    UIImage* image = [UIImage imageWithData:data];
    if(image==nil){
        NSLog(@"Fail to decompress image");
        return nil;
    }
    
    unsigned int width=0;
    unsigned int height=0;
    unsigned char *bytes = (unsigned char *)[MEImageUtil bitmapFromImage:image
                                                                flippedY:NO
                                                                   scale:image.scale
                                                          resultantWidth:&width
                                                         resultantHeight:&height];
    
    // alloc output arrays
    double *reflectivityData = (double*)malloc(sizeof(double) * width * height);
    double *typeData = (double*)malloc(sizeof(double) * width * height);
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            
            int index = x + y * width;
            unsigned char *pixel = &bytes[index * 4];
            
            // take raw value and split it into reflectivity and precipitation type
            int radarValue = pixel[0] % 16;
            int precipitationTypeValue = pixel[0] / 16;
            
            // store data into separate arrays
            int outputIndex = x + (height - y - 1) * width;
            reflectivityData[outputIndex] = radarValue;
            typeData[outputIndex] = precipitationTypeValue;
        }
    }
    
    free(bytes);
    
    // create a data grid from the arrays
    RadarDataGrid *grid = [[RadarDataGrid alloc] initWithData:reflectivityData
                                                  andTypeData:typeData
                                                     andWidth:width
                                                    andHeight:height
                                                    andBounds:bounds];
    return grid;
}


- (void) doWork:(METileProviderRequest *)meTileRequest{
    
    if(meTileRequest.sphericalMercatorTiles.count>0){
        NSLog(@"Error: This worker does not support spherical mercator.");
        meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
        return;
    }
    
    // create rect for tile bounds
    CGRect tileBounds = CGRectMake(meTileRequest.minX,
                                   meTileRequest.minY,
                                   meTileRequest.maxX - meTileRequest.minX,
                                   meTileRequest.maxY - meTileRequest.minY);

    
    // get array of parent tiles all the way to the root
    // NOTE: first tile in the list is the tile argument passed in to getParents
    NSArray *parents = [_mePackage getParents:meTileRequest.uid];
    
    // try each tile in order
    for (id object in parents) {
        uint64_t parent = [object longLongValue];

        // try to get the data for this tile
        NSData* tileData = [_mePackage getTileUsingId:parent];
        if (tileData == nil)
            continue;
        
        // create a bilinear sampled image from this data
        CGRect dataBounds = [_mePackage getBoundsUsingId:parent];
        RadarDataGrid *grid = [self createGridFromData:tileData andBounds:dataBounds];
        UIImage *image = [grid createImageForBounds:tileBounds];
        
        // return with good image
        meTileRequest.uiImage = image;
        meTileRequest.isOpaque = NO;
        meTileRequest.tileProviderResponse = kTileResponseRenderUIImage;
        return;
    }

    // failed to find parent
    meTileRequest.tileProviderResponse = kTileResponseTransparentWithChildren;
}

@end
