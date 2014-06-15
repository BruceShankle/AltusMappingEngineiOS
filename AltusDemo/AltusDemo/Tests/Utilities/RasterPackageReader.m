//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "RasterPackageReader.h"

@implementation RasterPackageReader

-(id)initWithFileName:(NSString *)fileName{
    if(self=[super init]){
        _mePackage = [[MEPackage alloc]initWithFileName:fileName];
    }
    return self;
}

- (void) doWork:(METileProviderRequest *)meTileRequest{
    
    if(meTileRequest.sphericalMercatorTiles.count>0){
        NSLog(@"Error: This worker does not support spherical mercator.");
        meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
        return;
    }
    
    BOOL isEdgeTile = (meTileRequest.minX<_mePackage.minX ||
                       meTileRequest.minY<_mePackage.minY ||
                       meTileRequest.maxX>_mePackage.maxX ||
                       meTileRequest.maxY>_mePackage.maxY);
    
    //Get data and serve it up
    NSData* tileData = [_mePackage getTileUsingId:meTileRequest.uid];
    if(tileData!=nil){
        UIImage* image = [UIImage imageWithData:tileData];
        if(image==nil){
            NSLog(@"Fail to decompress image");
            meTileRequest.tileProviderResponse = kTileResponseTransparentWithChildren;
            return;
        }
        meTileRequest.uiImage = image;
        meTileRequest.isOpaque = !isEdgeTile;
        meTileRequest.tileProviderResponse = kTileResponseRenderUIImage;
    }
    else{
        //No tile found
        if(isEdgeTile){
            meTileRequest.tileProviderResponse = kTileResponseTransparentWithChildren;
        }
        else{
            meTileRequest.tileProviderResponse = kTileResponseNotAvailable;
        }
    }
}

@end
