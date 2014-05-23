//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "VectorGrid.h"

@implementation VectorGrid

-(id) init{
    if(self=[super init]){
        self.name = @"Grid";
    }
    return self;
}

-(void) addVirtualVectorMap{
    //Create a vector data provider
    VectorGridDataProvider* dataProvider = [[VectorGridDataProvider alloc]init];
    dataProvider.meMapViewController = self.meMapViewController;
    
	//Create virtual map info
	MEVirtualMapInfo* mapInfo = [[MEVirtualMapInfo alloc]init];
	mapInfo.meTileProvider = dataProvider;
	mapInfo.mapType = kMapTypeVirtualVector;
	mapInfo.zOrder = 100;
	mapInfo.name = self.name;
	mapInfo.maxLevel = 20;
    
	//Add map
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

-(void) addVectorMapStyles{
    MEPolygonStyle* style = [[MEPolygonStyle alloc]init];
	style.strokeWidth = 1;
	style.strokeColor = [UIColor colorWithRed:255
                                        green:255
                                         blue:255
                                        alpha:0.5];
	[self.meMapViewController addPolygonStyleToVectorMap:self.name
                                               featureId:1
                                                   style:style];
}

-(void) start{
    if(self.isRunning)
		return;
	[self addVirtualVectorMap];
    [self addVectorMapStyles];
	self.isRunning = YES;
}

-(void) stop{
    if(!self.isRunning)
        return;
    [self.meMapViewController removeMap:self.name clearCache:NO];
    self.isRunning = NO;
}

@end

/////////////////////////////////////////////////////////////////////
//Provides vector data for a virtual vector map
@implementation VectorGridDataProvider

- (id) init{
	if(self = [super init]){
		self.isAsynchronous = YES;
	}
	return self;
}

- (void) requestTileAsync:(METileProviderRequest *)meTileRequest{
	
	//Create a geometry group
	MEGeometryGroup* geometry = [[MEGeometryGroup alloc]init];
    
    //Schedule creating geometry on background thread.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        double w = meTileRequest.maxX - meTileRequest.minX;
        double h = meTileRequest.maxY - meTileRequest.minY;
        
        //Create a box that aligns to the tile bounds
        MELine* line = [[MELine alloc]init];
        line.featureId = 1;
        
        [line addPoint:meTileRequest.minX
                     y:meTileRequest.minY];
        
        [line addPoint:meTileRequest.minX + 0.25 * w
                     y:meTileRequest.minY];
        
        [line addPoint:meTileRequest.minX + 0.5 * w
                     y:meTileRequest.minY];
        
        [line addPoint:meTileRequest.minX + 0.75 * w
                     y:meTileRequest.minY];
        
        [line addPoint:meTileRequest.maxX
                     y:meTileRequest.minY];
        
        [line addPoint:meTileRequest.maxX
                     y:meTileRequest.minY + 0.25 * h];
        
        [line addPoint:meTileRequest.maxX
                     y:meTileRequest.minY + 0.55 * h];
        
        [line addPoint:meTileRequest.maxX
                     y:meTileRequest.minY + 0.75 * h];
        
        [line addPoint:meTileRequest.maxX
                     y:meTileRequest.maxY];
        
        //Add the box to the geometry group
        [geometry.lines addObject:line];
		
		//Send geometry group to mapping engine.
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.meMapViewController vectorTileLoadComplete:meTileRequest
											 meGeometryGroup:geometry];
		});
        
    });
}

@end
