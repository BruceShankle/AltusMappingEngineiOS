//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "HoustonStreets.h"

@implementation HoustonStreetsStyle1

-(id) init{
    if(self=[super init]){
        self.name = @"Houston - Style 1 - Vector";
        self.styleName = @"Styles";
        self.texturesCached = NO;
        self.mapName = @"HoustonStreets";
    }
    return self;
}

- (void) enableLabels:(BOOL) enabled{
    METest* labels= [self.meTestManager testInCategory:@"Markers"
                                              withName:@"Places - Arial"];
    
    if(enabled)
        [labels start];
    else
        [labels stop];
}

- (void) beginTest{
    //Stop tests that obscure or affect this one
    [self.meTestManager stopBaseMapTests];
   
    
    //Cache textures
    [self cacheVectorMapTextures];
    
    //Load vector map
    NSString* sqliteFile = [[NSBundle mainBundle] pathForResource:@"HoustonStreets"
                                                           ofType:@"sqlite"];
    
    NSString* mapFile = [[NSBundle mainBundle] pathForResource:@"HoustonStreets"
                                                        ofType:@"map"];
    
    [self.meMapViewController addVectorMap:self.mapName
                         mapSqliteFileName:sqliteFile
                           mapDataFileName:mapFile];
    
    [self.meMapViewController setStyleSetOnVectorMap:self.mapName
                                       styleFileName:sqliteFile
                                        styleSetName:self.styleName];
    
    [self.meMapViewController setMapZOrder:self.mapName zOrder:3];
    
    
    [self enableLabels:YES];
}

- (void) endTest{
    [self enableLabels:NO];
	[self.meMapViewController removeMap:self.mapName
							 clearCache:NO];
}

- (void) cacheVectorMapTextures {
	
    if(self.texturesCached){
        return;
    }
    
	//Mapbox style
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"waterTexture"]
									withName:@"waterTexture@2x.png"
							 compressTexture:NO];
	
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"landTexture"]
									withName:@"landTexture@2x.png"
							 compressTexture:NO];
	
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"park"]
									withName:@"park@2x.png"
							 compressTexture:NO];
	
	//Apple style
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"apple_golf"]
									withName:@"apple_golf@2x.png"
							 compressTexture:NO];
    
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"apple_land"]
									withName:@"apple_land@2x.png"
							 compressTexture:NO];
    
    
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"apple_park"]
									withName:@"apple_park@2x.png"
							 compressTexture:NO];
    
    
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"apple_water"]
									withName:@"apple_water@2x.png"
							 compressTexture:NO];
    
    
    self.texturesCached = YES;
}

@end

@implementation HoustonStreetsStyle2
-(id) init{
    if(self=[super init]){
        self.name = @"Houston - Style 2 - Vector";
        self.styleName = @"M_Styles";
        self.texturesCached = NO;
    }
    return self;
}
@end

@implementation HoustonStreetsStyle3
-(id) init{
    if(self=[super init]){
        self.name = @"Houston - Style 3 - Vector";
        self.styleName = @"A_Styles";
        self.texturesCached = NO;
    }
    return self;
}
@end

