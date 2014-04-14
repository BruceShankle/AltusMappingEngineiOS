//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "MBTilesNative.h"

@implementation MBTilesNative

-(id) init{
    if(self=[super init]){
        self.name = @"MBTiles - Raster";
    }
    return self;
}

- (void) start{
    
    if(self.isRunning){
        return;
    }
    
    //Stop tests that obscure or affect this one
    [self.meTestManager stopCategory:@"Terrain"];
    [self.meTestManager stopCategory:@"Maps"];
    
	NSString* databaseFile = [[NSBundle mainBundle] pathForResource:@"Earthquakes"
															 ofType:@"mbtiles"];
	
	[self.meMapViewController addMBTilesMap:self.name
								   fileName:databaseFile
							defaultTileName:@"grayGrid"
							  imageDataType:kImageDataTypePNG
							compessTextures:NO
									 zOrder:2
                         mapLoadingStrategy:kHighestDetailOnly];
	
	self.isRunning = YES;
}

- (void) stop{
    
    if(!self.isRunning){
        return;
    }
    
	[self.meMapViewController removeMap:self.name
							 clearCache:NO];
	self.isRunning = NO;
}


@end
