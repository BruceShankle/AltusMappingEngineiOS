//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MERefreshMapTests.h"
#import "../METestConsts.h"
#import "BoundingBoxReader.h"

@implementation MERefreshMapTileProvider
- (void) requestTile:(METileProviderRequest *)meTileRequest
{
	meTileRequest.uiImage = [UIImage imageNamed:[NSString stringWithFormat:@"tile_%d",self.currentTile]];
	meTileRequest.tileProviderResponse = kTileResponseRenderUIImage;
}

-(void) nextTile
{
	self.currentTile++;
	if(self.currentTile>4)
		self.currentTile=0;
}

@end



@implementation MERefreshMapRegionTest

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Refresh Map Region";
	}
	return self;
}

- (void) refreshMap
{
	[self.tileProvider nextTile];
	[self.meMapViewController refreshMap:self.name];
}

- (void) refreshMapRegion
{
	[self.tileProvider nextTile];
	[self.meMapViewController refreshMapRegion:self.name lowerLeft:US_MIN upperRight:US_MAX];
    [self.meMapViewController refreshDirtyTiles:self.name];
}

- (void) addRegionBoundsMap:(NSString*) mapName
{
	if(![self.meMapViewController containsMap:mapName])
	{
		MEVectorMapInfo* vectorMapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
		vectorMapInfo.name = mapName;
		vectorMapInfo.zOrder = 100;
		[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
	}
}

- (void) addRegionBounds:(CLLocationCoordinate2D) lowerLeft
			  upperRight:(CLLocationCoordinate2D) upperRight
			 strokeColor:(UIColor*) strokeColor
			   fillColor:(UIColor*) fillColor
				 mapName:(NSString*) mapName
{
	[self addRegionBoundsMap: mapName];
	
	MEPolygonStyle* polygonStyle=[[[MEPolygonStyle alloc]init]autorelease];
	polygonStyle.strokeColor = strokeColor;
    polygonStyle.fillColor = fillColor;
	
    polygonStyle.strokeWidth = 1;
	
    //Create an array of points for the region
    NSMutableArray* polygonPoints=[[[NSMutableArray alloc]init]autorelease];
    
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(lowerLeft.longitude, lowerLeft.latitude)]];
	
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(lowerLeft.longitude, upperRight.latitude)]];
	
	[polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(upperRight.longitude, upperRight.latitude)]];
	
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(upperRight.longitude, lowerLeft.latitude)]];
	
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(lowerLeft.longitude, lowerLeft.latitude)]];
    
    //Add the polygon to the map
    [self.meMapViewController addPolygonToVectorMap:mapName
											 points:polygonPoints
											  style:polygonStyle];
	
}

- (void) addRegionBounds:(CLLocationCoordinate2D) lowerLeft
			  upperRight:(CLLocationCoordinate2D) upperRight
				 mapName:(NSString*) mapName

{
	
    [self addRegionBoundsMap: mapName];
	
    //Create a new polygon style
    
	double randomRed = arc4random_uniform(255) / 255.0;
	double randomGreen = arc4random_uniform(255) / 255.0;
	double randomBlue = arc4random_uniform(255) / 255.0;
	
	UIColor* strokeColor = [UIColor colorWithRed:randomRed
										   green:randomGreen
											blue:randomBlue
										   alpha:1.0];
	
	UIColor* fillColor = [UIColor colorWithRed:randomRed
										 green:randomGreen
										  blue:randomBlue
										 alpha:0.75];
	
    
	[self addRegionBounds:lowerLeft
			   upperRight:upperRight
			  strokeColor:strokeColor
				fillColor:fillColor
				  mapName:mapName];
}

-(void) showTestRegions
{
	[self addRegionBounds:US_MIN upperRight:US_MAX mapName:@"regionBounds"];
}

- (void) addMap
{
	//Create tile provider
	self.tileProvider = [[[MERefreshMapTileProvider alloc]init]autorelease];
	self.tileProvider.meMapViewController = self.meMapViewController;
	
	//Cache some images
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"noData"]
									withName:@"noData"
							 compressTexture:NO];
	
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"grayGrid"]
									withName:@"grayGrid"
							 compressTexture:NO];
	
	//Add a virtual map
	MEVirtualMapInfo* vmapInfo=[[[MEVirtualMapInfo alloc]init]autorelease];
	vmapInfo.name = self.name;
	vmapInfo.zOrder = 20;
	vmapInfo.meTileProvider = self.tileProvider;
	vmapInfo.maxLevel = 20;
	vmapInfo.defaultTileName = @"grayGrid";
	[self.meMapViewController addMapUsingMapInfo:vmapInfo];
	
}

- (void) start
{
	if(self.isRunning)
		return;
	
	[self showTestRegions];
	
	//Point camera at US
	[self lookAtUnitedStates];
	
	[self addMap];
	
	//Add a refresh map button.
	self.btnRefreshMap = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.btnRefreshMap addTarget:self
						   action:@selector(refreshMap)
				 forControlEvents:UIControlEventTouchDown];
	[self.btnRefreshMap setTitle:@"Refresh Map" forState:UIControlStateNormal];
	self.btnRefreshMap.frame = CGRectMake(10.0, 250.0, 160.0, 40.0);
	[self.meMapViewController.meMapView addSubview:self.btnRefreshMap];
	[self.meMapViewController.meMapView bringSubviewToFront:self.btnRefreshMap];
	
	
	//Add a refresh region button.
	self.btnRefreshRegion = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.btnRefreshRegion addTarget:self
							  action:@selector(refreshMapRegion)
					forControlEvents:UIControlEventTouchDown];
	[self.btnRefreshRegion setTitle:@"Refresh Region" forState:UIControlStateNormal];
	self.btnRefreshRegion.frame = CGRectMake(10.0, 300.0, 160.0, 40.0);
	[self.meMapViewController.meMapView addSubview:self.btnRefreshRegion];
	[self.meMapViewController.meMapView bringSubviewToFront:self.btnRefreshRegion];
	
	self.isRunning = YES;
}

- (void) stop
{
	if(!self.isRunning)
		return;
	
	[self.meMapViewController removeMap:self.name clearCache:YES];
	[self.meMapViewController removeMap:@"regionBounds" clearCache:YES];
	self.tileProvider = nil;
	[self.btnRefreshMap removeFromSuperview];
	[self.btnRefreshRegion removeFromSuperview];
	
	self.isRunning = NO;
}

@end

////////////////////////////////////////////////////////////
//This tile provider is designed for the Refresh map region
//stress test.
@implementation MERefreshMapStressTileProvider

- (id) init
{
	if(self=[super init])
	{
		self.currentTile = 5;
	}
	return self;
}

- (void) requestTile:(METileProviderRequest *)meTileRequest
{
	NSLog(@"not supported");
	exit(0);
}

- (void) requestTilesAsync:(NSArray *)meTileRequests
{
	@synchronized(self)
	{
		[self nextTile];
	}
	
	for(METileProviderRequest* meTileRequest in meTileRequests)
	{
		//Sleep here to simulate a tile provider
		//[NSThread sleepForTimeInterval:0.1];
		
		//Early exit if not needed, note we still call
		//tileLoadComplete here to the engine can clean up resources
		if(![self.meMapViewController animatedTileIsNeeded:meTileRequest])
		{
			meTileRequest.tileProviderResponse = kTileResponseWasCancelled;
			[self.meMapViewController tileLoadComplete:meTileRequest];
		}
		//Otherwise, service the request with an image
		else
		{
			meTileRequest.uiImage = [UIImage imageNamed:[NSString stringWithFormat:@"tile_%d",self.currentTile]];
			meTileRequest.tileProviderResponse = kTileResponseRenderUIImage;
			[self.meMapViewController tileLoadComplete:meTileRequest];
		}
	}
}

@end


///////////////////////////////////////////////////
@implementation MERefreshMapRegionStress

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Refresh Map Region Stress";
	}
	return self;
}


-(void) showTestRegions
{
	return;
}

- (void) addMap
{
	//Create tile provider
	self.tileProvider = [[[MERefreshMapStressTileProvider alloc]init]autorelease];
	self.tileProvider.isAsynchronous = YES;
	self.tileProvider.meMapViewController = self.meMapViewController;
	
	//Cache some images
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"noData"]
									withName:@"noData"
							 compressTexture:NO];
	
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"grayGrid"]
									withName:@"grayGrid"
							 compressTexture:NO];
	
	//Add a virtual map
	MEAnimatedVirtualMapInfo* vmapInfo=[[[MEAnimatedVirtualMapInfo alloc]init]autorelease];
	vmapInfo.name = self.name;
	vmapInfo.zOrder = 20;
	vmapInfo.meTileProvider = self.tileProvider;
	vmapInfo.maxLevel = 20;
	vmapInfo.defaultTileName = @"grayGrid";
	vmapInfo.frameCount = 1;
	vmapInfo.automaticTileRequestMode = NO;
	[self.meMapViewController addMapUsingMapInfo:vmapInfo];
	[self.meMapViewController refreshDirtyTiles:self.name];
}


- (void) start
{
	if(self.isRunning)
		return;
	
	[self addMap];
	
	if(self.boundingBoxes==nil)
	{
		NSString* fileName = [[NSBundle mainBundle]
							  pathForResource:@"refreshregionstress"
							  ofType:@"txt"];
		self.boundingBoxes = [BoundingBoxReader loadDataFromFile:fileName];
		NSLog(@"Loaded %d test bounding boxes.", self.boundingBoxes.count);
	}
	self.interval = 1.0;
	self.isRunning = YES;
	
	[self startTimer];
}

- (void) stop
{
	if(!self.isRunning)
		return;
	for(int i=0; i<self.timerTickCount+1; i++)
	{
		NSString* mapName = [NSString stringWithFormat:@"%d", i];
		[self.meMapViewController removeMap:mapName clearCache:YES];
	}
	[self.meMapViewController removeMap:self.name clearCache:YES];
	self.timerTickCount = 0;
	self.isRunning = NO;
	
}

- (void) timerTick
{
	[self stopTimer];
	
	//Add some polygons to show where we're updating.
	double randomRed = arc4random_uniform(255) / 255.0;
	double randomGreen = arc4random_uniform(255) / 255.0;
	double randomBlue = arc4random_uniform(255) / 255.0;
	UIColor* strokeColor = [UIColor colorWithRed:randomRed
										   green:randomGreen
											blue:randomBlue
										   alpha:1.0];
	UIColor* fillColor = [UIColor colorWithRed:randomRed
										 green:randomGreen
										  blue:randomBlue
										 alpha:0.75];
	NSString* mapName = [NSString stringWithFormat:@"%d", self.timerTickCount];
	self.timerTickCount++;
	int polyBoxIndex = self.boxIndex;
	for (int i=0; i<118; i++)
	{
		GeoBoundingBox* box = [self.boundingBoxes objectAtIndex:polyBoxIndex];
		polyBoxIndex++;
		[self addRegionBounds:box.lowerLeft
				   upperRight:box.upperRight
				  strokeColor:strokeColor
					fillColor:fillColor
					  mapName:mapName];
		
		
		if(polyBoxIndex == self.boundingBoxes.count)
			break;
	}
	
	//Now actually refresh the map.
	dispatch_queue_t taskQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
	for (int i=0; i<118; i++)
	{
		int currentBox = self.boxIndex;
		dispatch_async(taskQ, ^{
			
			//Get the next bounding box.
			GeoBoundingBox* box = [self.boundingBoxes objectAtIndex:currentBox];
			
			
			[self.meMapViewController refreshMapRegion:self.name
											 lowerLeft:box.lowerLeft
											upperRight:box.upperRight];
			
		});
		
		self.boxIndex++;
		//End of test?
		if(self.boxIndex==self.boundingBoxes.count)
		{
			self.boxIndex=0;
			break;
		}
	}
	
	//Tell mapping engine to request tiles.
	dispatch_async(taskQ, ^{
		[self.meMapViewController refreshDirtyTiles:self.name];
	});
	
	//Kick off timer for next set of boxes
	if(self.boxIndex!=0)
		[self startTimer];
}


@end

