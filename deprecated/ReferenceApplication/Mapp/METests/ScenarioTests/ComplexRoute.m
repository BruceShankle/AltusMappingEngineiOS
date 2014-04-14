//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import "ComplexRoute.h"
#import "../METestCategory.h"
#import "../METestConsts.h"

@implementation ComplexRoute

- (id) init
{
	if(self = [super init])
	{
		//Create gesture recognizer
        self.longPress = [[UILongPressGestureRecognizer alloc]
                          initWithTarget:self
                          action:@selector(handleLongPress:)];
        self.longPress.minimumPressDuration = 2.0;
		
		self.name = @"Complex Route";
		
		//Set up map names
		self.routeLineMapName = [NSString stringWithFormat:@"%@_route_line",
								 self.name];

		self.transparentMarkerMapName = [NSString stringWithFormat:@"%@_markers_transparent",
										 self.name];
		
		self.solidMarkerMapName = [NSString stringWithFormat:@"%@_markers_solid",
								   self.name];
		
		

		float lineWidth = 5;
        float outlineWidth = 1;
		
		self.styleRed = [[[MELineStyle alloc]init]autorelease];
		self.styleRed.strokeColor = [UIColor redColor];
        self.styleRed.outlineColor = [UIColor blackColor];
        self.styleRed.strokeWidth = lineWidth;
        self.styleRed.outlineWidth = outlineWidth;
		
		self.styleGreen = [[[MELineStyle alloc]init]autorelease];
		self.styleGreen.strokeColor = [UIColor greenColor];
        self.styleGreen.outlineColor = [UIColor blackColor];
        self.styleGreen.strokeWidth = lineWidth;
        self.styleGreen.outlineWidth = outlineWidth;
		
		self.styleBlue = [[[MELineStyle alloc]init]autorelease];
		self.styleBlue.strokeColor = [UIColor blueColor];
        self.styleBlue.outlineColor = [UIColor blackColor];
        self.styleBlue.strokeWidth = lineWidth;
        self.styleBlue.outlineWidth = outlineWidth;
		
		self.stylePurple = [[[MELineStyle alloc]init]autorelease];
		self.stylePurple.strokeColor = [UIColor purpleColor];
        self.stylePurple.outlineColor = [UIColor blackColor];
        self.stylePurple.strokeWidth = lineWidth;
        self.stylePurple.outlineWidth = outlineWidth;
		
	}
	return self;
}

-(void) dealloc
{
	self.styleRed = nil;
	self.styleGreen = nil;
	self.styleBlue = nil;
	self.longPress = nil;
	
	self.solidMarkerMapName = nil;
	self.transparentMarkerMapName = nil;
	self.routeLineMapName = nil;

	[super dealloc];
}


- (void) addLineWithId:(NSString*) lineId
				points:(NSArray*) points
			 lineStyle:(MELineStyle*) style
{
	//Add line in target color
	[self.meMapViewController addDynamicLineToVectorMap:self.routeLineMapName
												 lineId:lineId
												 points:points
												  style:style];
}

- (void) addRouteSegmentWithId:(NSString*) lineId
						coord1:(CLLocationCoordinate2D) coord1
						coord2:(CLLocationCoordinate2D) coord2
						 style:(MELineStyle*)style
				  milesPerNode:(double) milesPerNode
{
    NSMutableArray* points = [[[NSMutableArray alloc] init] autorelease];
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(coord1.longitude, coord1.latitude)]];
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(coord2.longitude, coord2.latitude)]];
	
	[self addLineWithId:lineId
				 points:points
			  lineStyle:style];
	
}

-(MEMarkerAnnotation*) createMarkerAnnotation:(CLLocationCoordinate2D) coordinate
										 name:(NSString*) name
{
	MEMarkerAnnotation* markerAnnotation = [[[MEMarkerAnnotation alloc] init]autorelease];
	markerAnnotation.metaData = name;
	markerAnnotation.coordinate = coordinate;
	markerAnnotation.weight=0;
	return markerAnnotation;
}


- (void) addReticle:(NSString*) name
		 coordinate:(CLLocationCoordinate2D) coordinate
			  style:(MEAnimatedVectorReticleStyle) style
		 arrowColor:(UIColor*) arrowColor
		circleColor:(UIColor*) circleColor
  animationDuration:(CGFloat) animationDuration
	   repeateDelay:(CGFloat) repeatDelay
	 frequencyDecay:(CGFloat) frequencyDecay
	 magnitudeDecay:(CGFloat) magnitudeDecay

{
	//Add a reticle
	MEPolygonStyle* arrowStyle=
	[[[MEPolygonStyle alloc]initWithStrokeColor:[UIColor blackColor]
									strokeWidth:1.0
									  fillColor:arrowColor
	  ]autorelease];
	
	MEPolygonStyle* circleStyle=
	[[[MEPolygonStyle alloc]initWithStrokeColor:[UIColor blackColor]
									strokeWidth:1.0
									  fillColor:circleColor
	  ]autorelease];
	
	
	MEAnimatedVectorReticle* reticle = [[[MEAnimatedVectorReticle alloc]init]autorelease];
	reticle.arrowStyle = arrowStyle;
	reticle.circleStyle = circleStyle;
	reticle.zOrder = 999;
	reticle.name=name;
	reticle.circleRadius=10;
	reticle.bounceRadius=60;
	reticle.arrowSize = 20;
	reticle.location = coordinate;
	reticle.animationDuration = animationDuration;
    reticle.repeatDelay = repeatDelay;
	reticle.bounceFrequencyDecay = frequencyDecay;
    reticle.bounceMagnitudeDecay = magnitudeDecay;
	reticle.style = style;
	[self.meMapViewController addAnimatedVectorReticle:reticle];
}

- (void) addReticles
{
	//Add a reticles
	[self addReticle:@"RDUReticle"
		  coordinate:RDU_COORD
			   style:kAnimatedVectorReticleInwardPointingWithCircle
		  arrowColor:[MEImageUtil makeColor:64 g:80 b:219 a:255]
		 circleColor:[MEImageUtil makeColor:64 g:80 b:219 a:128]
   animationDuration:1.25
		repeateDelay:2.0
	  frequencyDecay:1.5
	  magnitudeDecay:1.0];
	
	[self addReticle:@"SFOReticle"
		  coordinate:SFO_COORD
			   style:kAnimatedVectorReticleInwardPointingWithoutCircle
		  arrowColor:[MEImageUtil makeColor:255 g:0 b:0 a:200]
		 circleColor:[MEImageUtil makeColor:255 g:255 b:255 a:255]
   animationDuration:0.75
		repeateDelay:1.0
	  frequencyDecay:1
	  magnitudeDecay:1];
	
	
	[self addReticle:@"HOUReticle"
		  coordinate:HOU_COORD
			   style:kAnimatedVectorReticleOutwardPointingWithCircle
		  arrowColor:[MEImageUtil makeColor:0 g:255 b:0 a:255]
		 circleColor:[MEImageUtil makeColor:0 g:255 b:0 a:128]
   animationDuration:2.25
		repeateDelay:0.0
	  frequencyDecay:1.5
	  magnitudeDecay:1.0];
	
	[self addReticle:@"MIAReticle"
		  coordinate:MIA_COORD
			   style:kAnimatedVectorReticleOutwardPointingWithoutCircle
		  arrowColor:[MEImageUtil makeColor:0 g:0 b:255 a:255]
		 circleColor:[MEImageUtil makeColor:255 g:255 b:255 a:255]
   animationDuration:3.25
		repeateDelay:0.0
	  frequencyDecay:1.5
	  magnitudeDecay:1.0];
	
}


- (void) addRoute
{
	//Add vector map line
	MEVectorMapInfo* vectorMapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
	vectorMapInfo.name = self.routeLineMapName;
	vectorMapInfo.meVectorMapDelegate = self;
	vectorMapInfo.zOrder = 100;
	[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
    [self.meMapViewController setTesselationThresholdForMap:vectorMapInfo.name
											  withThreshold:40];
    [self.meMapViewController setMapAlpha:self.routeLineMapName
									alpha:0.6];
    
	//Add lines to vector map
	double milesPerNode= 100.0;
	[self addRouteSegmentWithId:@"JFK to SFO"
						 coord1:JFK_COORD
						 coord2:SFO_COORD
						  style:self.styleRed
				   milesPerNode:milesPerNode];
	
	[self addRouteSegmentWithId:@"SFO to HOU"
						 coord1:SFO_COORD
						 coord2:HOU_COORD
						  style:self.stylePurple
				   milesPerNode:milesPerNode];
	
	[self addRouteSegmentWithId:@"HOU to MIA"
						 coord1:HOU_COORD
						 coord2:MIA_COORD
						  style:self.styleGreen
				   milesPerNode:milesPerNode];
	
	[self addRouteSegmentWithId:@"MIA to RDU"
						 coord1:MIA_COORD
						 coord2:RDU_COORD
						  style:self.styleBlue
				   milesPerNode:milesPerNode];
}


- (void) addMarkers
{
	//Create marker annotations
	NSMutableArray* markers = [[[NSMutableArray alloc]init]autorelease];
	[markers addObject:[self createMarkerAnnotation:JFK_COORD name:@"JFK"]];
	[markers addObject:[self createMarkerAnnotation:SFO_COORD name:@"SFO"]];
	[markers addObject:[self createMarkerAnnotation:HOU_COORD name:@"HOU"]];
	[markers addObject:[self createMarkerAnnotation:MIA_COORD name:@"MIA"]];
    [markers addObject:[self createMarkerAnnotation:RDU_COORD name:@"RDU"]];
	
	//Add markers with transparency
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.transparentMarkerMapName;
	mapInfo.mapType = kMapTypeMemoryMarker;
	mapInfo.markerImageLoadingStrategy = kMarkerImageLoadingSynchronous;
	mapInfo.zOrder = 101;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.markers = markers;
	mapInfo.clusterDistance = 0;
	mapInfo.maxLevel = 10;
	
    [self.meMapViewController addMapUsingMapInfo:mapInfo];
    [self.meMapViewController setMapIsVisible:self.transparentMarkerMapName isVisible:YES];
	
	//Add solid markers for masking
	mapInfo.name = self.solidMarkerMapName;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	[self.meMapViewController setMapIsVisible:self.solidMarkerMapName isVisible:NO];

	[self.meMapViewController addClipMapToMap:self.routeLineMapName
								  clipMapName:self.solidMarkerMapName];
}

- (void) start
{
	[self.meTestCategory stopAllTests];
	self.isRunning = YES;
	
	[self addReticles];
	
	[self addRoute];
	[self addMarkers];
	[self.meMapViewController.meMapView addGestureRecognizer:self.longPress];
}

- (void) mapView:(MEMapView *)mapView
updateMarkerInfo:(MEMarkerInfo *)markerInfo
		 mapName:(NSString *)mapName
{
	UIImage* uiImage = nil;
	
	if([mapName isEqualToString:self.transparentMarkerMapName])
	{
		if([markerInfo.metaData isEqualToString:@"JFK"])
			uiImage = [UIImage imageNamed:@"blueStar"];
		
		if([markerInfo.metaData isEqualToString:@"SFO"])
			uiImage = [UIImage imageNamed:@"blueTriangle"];
		
		if([markerInfo.metaData isEqualToString:@"HOU"])
			uiImage = [UIImage imageNamed:@"blueCircle"];
		
		if([markerInfo.metaData isEqualToString:@"MIA"])
			uiImage = [UIImage imageNamed:@"redHexagon"];
		
		if([markerInfo.metaData isEqualToString:@"RDU"])
			uiImage = [UIImage imageNamed:@"yellowDiamond"];
	}
	
	if([mapName isEqualToString:self.solidMarkerMapName])
	{
		if([markerInfo.metaData isEqualToString:@"JFK"])
			uiImage = [UIImage imageNamed:@"blueStarSolid"];
		
		if([markerInfo.metaData isEqualToString:@"SFO"])
			uiImage = [UIImage imageNamed:@"blueTriangleSolid"];
		
		if([markerInfo.metaData isEqualToString:@"HOU"])
			uiImage = [UIImage imageNamed:@"blueCircleSolid"];
		
		if([markerInfo.metaData isEqualToString:@"MIA"])
			uiImage = [UIImage imageNamed:@"redHexagonSolid"];
		
		if([markerInfo.metaData isEqualToString:@"RDU"])
			uiImage = [UIImage imageNamed:@"yellowDiamondSolid"];
	}
	
	
	if(uiImage!=nil)
	{
		markerInfo.uiImage = uiImage;
		CGPoint anchorPoint = CGPointMake(uiImage.size.width/2, uiImage.size.height/2);
		markerInfo.anchorPoint = anchorPoint;
	}
}

//When a long press occurs, trigger a hit detection operation which, if there are hits
//will trigger lineSegmentHitDetected, or vertexHitDetected
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    CGPoint viewPoint=[gesture locationInView:self.meMapViewController.meMapView];
    if(UIGestureRecognizerStateBegan == gesture.state)
    {
		MEVectorGeometryHit* hit=
        [self.meMapViewController detectHitOnMap:self.routeLineMapName
								   atScreenPoint:viewPoint
							 withVertexHitBuffer:20
							   withLineHitBuffer:15];
		if(hit!=nil)
		{
			if([hit isKindOfClass:[MEVertexHit class]])
				NSLog(@"You hit vertex %d on %@", ((MEVertexHit*)hit).vertexIndex, hit.shapeId);
			
		}
    }
}

//Implement MEVectorMapDelegate methods
- (void) lineSegmentHitDetected:(MEMapView*) mapView
						mapName:(NSString*) mapName
						shapeId:(NSString*) shapeId
					 coordinate:(CLLocationCoordinate2D) coordinate
			  segmentStartIndex:(int) segmentStartIndex
				segmentEndIndex:(int) segmentEndIndex
{
	NSLog(@"mapName:%@ shapeId:%@ Coordinate:%f, %f segmentStartIndex:%d segmentEndIndex:%d",
		  mapName,
		  shapeId,
		  coordinate.longitude,
		  coordinate.latitude,
		  segmentStartIndex,
		  segmentEndIndex);
}

- (void) vertexHitDetected:(MEMapView*) mapView
				   mapName:(NSString*) mapName
				   shapeId:(NSString*) shapeId
				coordinate:(CLLocationCoordinate2D) coordinate
			   vertexIndex:(int) vertexIndex
{
	NSLog(@"mapName:%@ shapeId:%@ Coordinate:%f, %f vertexIndex:%d",
		  mapName,
		  shapeId,
		  coordinate.longitude,
		  coordinate.latitude,
		  vertexIndex);
}

-(double) lineSegmentHitTestPixelBufferDistance
{
	return 15.0;
}

-(double) vertexHitTestPixelBufferDistance
{
	return 20.0;
}

- (void) stop
{
	//Remove gesture handler
	[self.meMapViewController.meMapView removeGestureRecognizer:self.longPress];
	
	//Remove maps
	[self.meMapViewController removeMap:self.routeLineMapName clearCache:NO];
	[self.meMapViewController removeMap:self.transparentMarkerMapName clearCache:NO];
	[self.meMapViewController removeMap:self.solidMarkerMapName clearCache:NO];
	
	//Remove reticles
	[self.meMapViewController removeAnimatedVectorReticle:@"RDUReticle"];
	[self.meMapViewController removeAnimatedVectorReticle:@"SFOReticle"];
	[self.meMapViewController removeAnimatedVectorReticle:@"HOUReticle"];
	[self.meMapViewController removeAnimatedVectorReticle:@"MIAReticle"];
	
	self.isRunning = NO;
}

@end

//////////////////////////////////////////////////////
@implementation ParallelsAndMeridians

- (id) init
{
	if(self = [super init])
	{
		self.name = @"Parallels & Meridians";
		self.solidMarkerMapName = [NSString stringWithFormat:@"%@_markers", self.name];
	}
	return self;
}

- (void) start
{
	[self.meTestCategory stopAllTests];
	
	self.isRunning = YES;
	
//	//Add vector map
//	MEVectorMapInfo* vectorMapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
//	vectorMapInfo.name = self.name;
//	vectorMapInfo.meVectorMapDelegate = self;
//	vectorMapInfo.zOrder = 100;
//	[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
	
	//Create style
	MELineStyle* style = [[[MELineStyle alloc]init]autorelease];
	style.strokeColor = [UIColor whiteColor];
	style.strokeWidth = 2.0;
	
	//Add lines to vector map
	for(int y=-80; y<=80; y+=10)
	{
		NSMutableArray* points=[[NSMutableArray alloc]init];
		for(int x=-180; x<=180; x+=10)
		{
			[points addObject:[NSValue valueWithCGPoint:CGPointMake(x,y)]];
		}
		[self.meMapViewController addLineToVectorMap:self.name
											  points:points
											   style:style];
		[points release];
	}
	
	for(int x=-180; x<=180; x+=10)
	{
		NSMutableArray* points=[[NSMutableArray alloc]init];
		for(int y=-90; y<=90; y+=10)
		{
			[points addObject:[NSValue valueWithCGPoint:CGPointMake(x,y)]];
		}
		[self.meMapViewController addLineToVectorMap:self.name
											  points:points
											   style:style];
		[points release];
	}
	
	//Add marker annotations
	NSMutableArray* markers = [[[NSMutableArray alloc]init]autorelease];
	for(int x=-180; x<=180; x+=10)
	{
		for(int y=-80; y<=80; y+=10)
		{
			NSString* metaData = [NSString stringWithFormat:@"x=%d y=%d",x,y];
			[markers addObject:[self createMarkerAnnotation:CLLocationCoordinate2DMake(x, y)
													   name:metaData]];
		}
	}
	
//	//Add marker map
//	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
//	mapInfo.name = self.solidMarkerMapName;
//	mapInfo.mapType = kMapTypeDynamicMarker;
//	mapInfo.zOrder = 101;
//	mapInfo.meMarkerMapDelegate = self;
//	mapInfo.markers = markers;
//	mapInfo.clusterDistance = 0;
//	mapInfo.maxLevel = 5;
//	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
}

- (void) mapView:(MEMapView *)mapView
updateMarkerInfo:(MEMarkerInfo *)markerInfo
		 mapName:(NSString *)mapName
{
	NSString* labelText= [NSString stringWithFormat:@"(%.0f,%.0f)",
						  markerInfo.location.longitude,
						  markerInfo.location.latitude];
		
	UIImage* uiImage;
	uiImage = [MEFontUtil newImageWithFontOutlined:@"Arial"
											 fontSize:12
											fillColor:[UIColor whiteColor]
										  strokeColor:[UIColor blackColor]
										  strokeWidth:0
												 text:labelText];
	
	if(uiImage!=nil)
	{
		markerInfo.uiImage = uiImage;
		CGPoint anchorPoint = CGPointMake(0, uiImage.size.height);
		markerInfo.anchorPoint = anchorPoint;
		[uiImage release];
	}
	else
	{
		markerInfo.uiImage = [UIImage imageNamed:@"pinRed"];
	}
	
}


@end