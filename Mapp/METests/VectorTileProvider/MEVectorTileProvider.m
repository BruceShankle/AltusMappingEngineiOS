//  Copyright (c) 2013 BA3, LLC. All rights reserved.

#import "MEVectorTileProvider.h"

@implementation MEVectorTileProvider

- (id) init{
	if(self = [super init]){
		self.isAsynchronous = YES;
	}
	return self;
}

- (void) requestTileAsync:(METileProviderRequest *)meTileRequest{
	
	//Create a geometry group
	__block MEGeometryGroup* meGeometryGroup = [[MEGeometryGroup alloc]init];
	
	double degreeIncrement = 1.0;
	
	int tileDimension = meTileRequest.maxX - meTileRequest.minX;
	
	if(tileDimension <= 1){
		degreeIncrement = 0.5;
	}
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		
		//Serve up geometry for lines of longitude.
		double startX = (double)((int)(meTileRequest.minX+0.5));
		double endX = (double)((int)(meTileRequest.maxX+0.5));
		
		//Special case for very last line since we use < in our while statement
		if(endX==180){
			endX=181;
		}
		
		double startY = meTileRequest.minY;
		double endY = meTileRequest.maxY;
		double deltaY = (endY - startY)/4.0;
		int modulus=1;
		if(tileDimension>5){
			modulus = 5;
		}
		if(tileDimension>10){
			modulus = 10;
		}
		
		while(startX<endX){
			BOOL draw = YES;
			if(modulus>1){
				if((int)startX % modulus != 0){
					draw = NO;
				}
			}
			if(draw){
				MELine* line = [[MELine alloc]init];
				
				//Set shape id, 1 is for degrees, 2 is for half-degrees
				line.shapeId = 1;
				if(ceil(startX)!=startX){
					line.shapeId = 2;
				}
				
				[line.points addObject:[MEGeometryPoint x:startX y:startY]];
				[line.points addObject:[MEGeometryPoint x:startX y:startY+deltaY]];
				[line.points addObject:[MEGeometryPoint x:startX y:startY+deltaY+deltaY]];
				[line.points addObject:[MEGeometryPoint x:startX y:startY+deltaY+deltaY+deltaY]];
				[line.points addObject:[MEGeometryPoint x:startX y:endY]];
				[meGeometryGroup.lines addObject:line];
				[line release];
			}
			startX+=degreeIncrement;
		}
		
		//Serve up geometry for lines of latitude
		startX = meTileRequest.minX;
		endX = meTileRequest.maxX;
		double deltaX = (endX-startX) / 4.0;
		
		startY = (double)((int)(meTileRequest.minY+0.5));
		endY = (double)((int)(meTileRequest.maxY+0.5));
		
		while(startY<endY){
			BOOL draw = YES;
			if(modulus>1){
				if((int)startY % modulus != 0){
					draw = NO;
				}
			}
			
			if(draw){
				MELine* line = [[MELine alloc]init];
				//Set shape id, 1 is for degrees, 2 is for half-degrees
				line.shapeId = 1;
				if(ceil(startY)!=startY){
					line.shapeId = 2;
				}
				[line.points addObject:[MEGeometryPoint x:startX y:startY]];
				[line.points addObject:[MEGeometryPoint x:startX+deltaX y:startY]];
				[line.points addObject:[MEGeometryPoint x:startX+deltaX+deltaX y:startY]];
				[line.points addObject:[MEGeometryPoint x:startX+deltaX+deltaX+deltaX y:startY]];
				[line.points addObject:[MEGeometryPoint x:endX y:startY]];
				[meGeometryGroup.lines addObject:line];
				[line release];
			}
			startY+=degreeIncrement;
		}
		
		//Give geometry to mapping engine.
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.meMapViewController vectorTileLoadComplete:meTileRequest
											 meGeometryGroup:meGeometryGroup];
			[meGeometryGroup release];
		});
        
    });
}

@end
