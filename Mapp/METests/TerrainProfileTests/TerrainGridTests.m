//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "TerrainGridTests.h"
#import "../../MapManager/MEMap.h"
#import "../../MapManager/MEMapCategory.h"
#import "../../MapManager/MapManager.h"
#import "../METestManager.h"
#import "TerrainMapFinder.h"

@implementation VectorGridProvider
- (id) init{
	if(self = [super init]){
		self.isAsynchronous = YES;
		self.terrainMaps = [TerrainMapFinder getTerrainMaps];
		self.terrainMarkerDictionary = [[[NSMutableDictionary alloc]init]autorelease];
		self.showAllLevels = NO;
	}
	return self;
}

-(void) dealloc{
	self.terrainMarkerDictionary = nil;
	self.terrainMaps = nil;
	[super dealloc];
}

- (void) setMeMapViewController:(MEMapViewController *)meMapViewController{
	[super setMeMapViewController:meMapViewController];
	
	//Cache zero ft image.
	UIImage* zeroFtImage = [self createLabelImage:@"0 ft" fontSize:15 fontColor:[UIColor grayColor]];
	self.zeroFtImageAnchorPoint = CGPointMake(zeroFtImage.size.width/2,
											  zeroFtImage.size.height/2);
	[meMapViewController addCachedMarkerImage:zeroFtImage
									 withName:@"zeroFtImage"
							  compressTexture:NO
			   nearestNeighborTextureSampling:NO];
	[zeroFtImage release];
	
	//Cache question mark
	UIImage* qMarkImage = [self createLabelImage:@"?" fontSize:15 fontColor:[UIColor grayColor]];
	self.questionMarkerAnchorPoint = CGPointMake(qMarkImage.size.width/2,
											  qMarkImage.size.height/2);
	[meMapViewController addCachedMarkerImage:qMarkImage
									 withName:@"qMarkImage"
							  compressTexture:NO
			   nearestNeighborTextureSampling:NO];
	[qMarkImage release];

}

- (CGFloat) metersToFeet:(CGFloat) meters{
	return meters * 3.28084;
}

-(UIImage*) createLabelImage:(NSString*) labelText
					fontSize:(double) fontSize
				   fontColor:(UIColor*) fontColor{
	UIImage* textImage=[MEFontUtil newImageWithFontOutlined:@"Helvetica"
												   fontSize:fontSize
												  fillColor:fontColor
												strokeColor:[UIColor blackColor]
												strokeWidth:0
													   text:labelText];
	return textImage;
}

-(NSString*) markerName:(CLLocationCoordinate2D) location{
	return [NSString stringWithFormat:@"%f,%f",
			location.longitude,
			location.latitude];
}

-(CLLocationCoordinate2D) markerLocation:(double) longitude
								latitude:(double) latitude
								  offset:(double) offset{
	return CLLocationCoordinate2DMake(latitude+offset/2.0, longitude+offset/2.0);
	
}

-(MEDynamicMarker*) createTerrainMarker:(double) longitude
							   latitude:(double) latitude
								 offset:(double) offset
{
	
	//Get terrain height around marker location.
	CLLocationCoordinate2D swCorner = CLLocationCoordinate2DMake(latitude, longitude);
	CLLocationCoordinate2D neCorner = CLLocationCoordinate2DMake(latitude+offset, longitude+offset);
	CGPoint minMaxHeight = [self.meMapViewController getMinMaxTerrainHeightsInBoundingBox:self.terrainMaps
																		southWestLocation:swCorner
																		northEastLocation:neCorner];
	
	MEDynamicMarker* marker = [[[MEDynamicMarker alloc]init]autorelease];
	
	double fontSize = 15;
	UIColor* fontColor = [UIColor greenColor];
	if(offset==1){
		fontSize = 17;
		fontColor = [UIColor yellowColor];
	}
	if(offset == 5){
		fontSize = 20;
		fontColor = [UIColor blueColor];
	}
	if(offset==10){
		fontSize = 25;
		fontColor = [UIColor redColor];
	}
	
	//If zero feet, used a cached marker image
	if(minMaxHeight.y==0){
		marker.cachedImageName = @"zeroFtImage";
		marker.anchorPoint = self.zeroFtImageAnchorPoint;
	}
	//Otherwise, generate a marker image to show the max height
	else{
		NSString* labelText = [NSString stringWithFormat:@"%0.0f ft (%0.0f)",
							   [self metersToFeet:minMaxHeight.y],
							   [self metersToFeet:minMaxHeight.x]];
		
		UIImage* textImage=[self createLabelImage:labelText fontSize:fontSize fontColor:fontColor];
		marker.uiImage = textImage;
		marker.anchorPoint = CGPointMake(marker.uiImage.size.width/2.0, marker.uiImage.size.height/2);
		[textImage release];
	}
	
	marker.location = [self markerLocation:longitude
								  latitude:latitude
									offset:offset];
	marker.name = [self markerName:marker.location];
	
	return marker;
}


- (void) addQuestionMarker:(NSString*) name
				  location:(CLLocationCoordinate2D) location{
	MEDynamicMarker* marker = [[[MEDynamicMarker alloc]init]autorelease];
	marker.name = name;
	marker.cachedImageName = @"qMarkImage";
	marker.anchorPoint = self.questionMarkerAnchorPoint;
	marker.location = location;
	[self.meMapViewController addDynamicMarkerToMap:@"markers"
									  dynamicMarker:marker];
	
}

- (void) requestTileAsync:(METileProviderRequest *)meTileRequest{
	
	//Create a geometry group
	__block MEGeometryGroup* meGeometryGroup = [[MEGeometryGroup alloc]init];
	
	double degreeIncrement = 1.0;
	
	int tileDimension = meTileRequest.maxX - meTileRequest.minX;
	
	if(tileDimension <= 1){
		degreeIncrement = 0.5;
	}
	
	//Allocate an array where we will place markers.
	__block NSMutableArray* terrainHeighMarkers = [[NSMutableArray alloc]init];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		
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
		
		//Return the geometry for the vector tile request.
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.meMapViewController vectorTileLoadComplete:meTileRequest
											 meGeometryGroup:meGeometryGroup];
			[meGeometryGroup release];
		});
		
		//Create terrain height markers, commend out line below to limit
		//how many come back
		if(self.showAllLevels || (degreeIncrement==0.5 && modulus == 1)){
			startX = (double)((int)(meTileRequest.minX+0.5));
			endX = (double)((int)(meTileRequest.maxX+0.5));
			while (startX < endX){
				BOOL drawX = YES;
				if(modulus>1){
					if((int)startX % modulus != 0){
						drawX = NO;
					}
				}
				
				if(drawX){
					startY = (double)((int)(meTileRequest.minY+0.5));
					endY = (double)((int)(meTileRequest.maxY+0.5));
					while(startY<endY){
						BOOL drawY = YES;
						if(modulus>1){
							if((int)startY % modulus != 0){
								drawY = NO;
							}
						}
						if(drawY){
							double offset = degreeIncrement;
							if(modulus>1){
								offset = modulus;
							}
							
							//If we haven't created a terrain height marker, then create one
							CLLocationCoordinate2D markerLocation = [self markerLocation:startX
																				latitude:startY
																				  offset:offset];
							NSString* markerName = [self markerName:markerLocation];
							BOOL markerAlreadyCreated = YES;
							@synchronized(self.terrainMarkerDictionary){
								if([self.terrainMarkerDictionary objectForKey:markerName]==nil){
									markerAlreadyCreated = NO;
								}
							}
							
							if(!markerAlreadyCreated){
								
								//Add a placeholder marker.
								dispatch_async(dispatch_get_main_queue(), ^{
									[self addQuestionMarker:markerName
												   location:markerLocation];
								});
								
								[terrainHeighMarkers addObject:[self createTerrainMarker:startX
																				latitude:startY
																				  offset:offset]];
							}
						}
						startY+=degreeIncrement;
					}
				}
				startX+=degreeIncrement;
			}
		}
		
		//Give geometry and markers to mapping engine on main thread
		dispatch_async(dispatch_get_main_queue(), ^{
						
			//Add all the dynamic markers
			for(MEDynamicMarker* marker in terrainHeighMarkers){
				[self.meMapViewController addDynamicMarkerToMap:@"markers" dynamicMarker:marker];
				@synchronized(self.terrainMarkerDictionary){
					[self.terrainMarkerDictionary setObject:marker forKey:marker.name];
				}
			}
			[terrainHeighMarkers release];
		});
        
    });
}
@end

///////////////////////////////////////////////////////////////////
@implementation TerrainGridTest

- (id) init{
	if(self==[super init]){
		self.name = @"Terrain Grid : 1/4 Arc Hours";
	}
	return self;
}

- (void) start{
	if(self.isRunning){
		return;
	}
	
	//Stop other tests in this category
	[self.meTestManager stopEntireCategory:self.meTestCategory];
	[self addDynamicMarkerMap];
	[self addVirtualVectorMap];
	self.isRunning = YES;
}

- (void) stop{
	if(!self.isRunning){
		return;
	}
	[self removeDynamicMarkerMap];
	[self removeVirtualVectorMap];
	self.isRunning = NO;
}

- (void) addDynamicMarkerMap{
	MEDynamicMarkerMapInfo* mapInfo = [[[MEDynamicMarkerMapInfo alloc]init]autorelease];
	mapInfo.hitTestingEnabled = NO;
	mapInfo.name = @"markers";
	mapInfo.zOrder = 100;
	mapInfo.meDynamicMarkerMapDelegate = self;
	mapInfo.meMapViewController = self.meMapViewController;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

- (void) removeDynamicMarkerMap{
	[self.meMapViewController removeMap:@"markers" clearCache:YES];
}

-(VectorGridProvider*) createTileProvider{
	VectorGridProvider* tileProvider = [[[VectorGridProvider alloc]init]autorelease];
	tileProvider.meMapViewController = self.meMapViewController;
	return tileProvider;
}

- (void) addVirtualVectorMap{
	
	//Create virtual map info
	MEVirtualMapInfo* mapInfo = [[[MEVirtualMapInfo alloc]init]autorelease];
	mapInfo.meMapViewController = self.meMapViewController;
	mapInfo.meTileProvider = [self createTileProvider];
	mapInfo.mapType = kMapTypeVirtualVector;
	mapInfo.zOrder = 10;
	mapInfo.name = self.name;
	
	//Add map
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	//Add styles
	MEPolygonStyle* style=[[[MEPolygonStyle alloc]init]autorelease];
	style.strokeWidth = 1;
	style.strokeColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.5];
	[self.meMapViewController addPolygonStyleToVectorMap:self.name featureId:1 style:style];
	style.strokeColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.1];
	[self.meMapViewController addPolygonStyleToVectorMap:self.name featureId:2 style:style];
	
}

- (void) removeVirtualVectorMap{
	[self.meMapViewController removeMap:self.name clearCache:NO];
}

@end

////////////////////////////////////////////////////
@implementation TerrainGridTest2

- (id) init{
	if(self==[super init]){
		self.name = @"Terrain Grid : Crazy";
	}
	return self;
}

-(VectorGridProvider*) createTileProvider{
	VectorGridProvider* tileProvider = [[[VectorGridProvider alloc]init]autorelease];
	tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.showAllLevels = YES;
	return tileProvider;
}

@end

