//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "MBTilesNative.h"

@implementation MBTilesNative

-(id) init{
    if(self=[super init]){
        self.name = @"MBTiles - Raster";
    }
    return self;
}

- (void) beginTest{
    
    //Stop tests that obscure or affect this one
    [self.meTestManager stopBaseMapTests];
    
	NSString* databaseFile = [[NSBundle mainBundle] pathForResource:@"Earthquakes"
															 ofType:@"mbtiles"];
	
	[self.meMapViewController addMBTilesMap:self.name
								   fileName:databaseFile
							defaultTileName:@"grayGrid"
							  imageDataType:kImageDataTypePNG
							compessTextures:NO
									 zOrder:2
                         mapLoadingStrategy:kHighestDetailOnly];
}

- (void) endTest{
	[self.meMapViewController removeMap:self.name
							 clearCache:NO];
}


@end
