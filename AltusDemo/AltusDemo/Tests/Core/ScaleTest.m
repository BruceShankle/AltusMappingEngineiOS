//
//  ScaleTest.m
//  AltusDemo
//
//  Created by Bruce Shankle on 9/23/14.
//  Copyright (c) 2014 BA3, LLC. All rights reserved.
//
#import "ScaleTest.h"
#import "../METestCategory.h"
#import "../METestConsts.h"
#import "../METestManager.h"
#import "../Utilities/MapFactory.h"

@implementation ScaleTest

- (id) init {
	if(self=[super init]){
        self.name=@"Scale Test";
        self.rasterMapName=@"Scale Test Raster Map";
        self.dynamicMarkerMapName=@"Scale Test Dynamic Markers";
        self.clusteredMarkerMapName=@"Scale Test Clustered Markers";
        self.vectorCircleName=@"Scale Test Circle";
        self.vectorMapName=@"Scale Test Vector Map";
        self.interval = 0.5;
        self.mapUrlTemplate = @"http://{s}.tiles.mapbox.com/v3/dxjacob.map-s5qr595q/{z}/{x}/{y}.png";
	}
	return self;
}

/**Load an image explicitly base don its name.*/
-(UIImage*) loadFileExplicitly:(NSString*) fileName
                         scale:(float) scale{
    
    NSString* imageFileName = [[NSBundle mainBundle] pathForResource:fileName
                                                              ofType:@"png"];
    
    //return [UIImage imageWithData:[NSData dataWithContentsOfFile:imageFileName]];
    return [UIImage imageWithData:[NSData dataWithContentsOfFile:imageFileName] scale:scale];
    
    return nil;
}

-(NSString*) getImageSuffix:(int) index{
    switch(index){
        case 2: return @"@2x";
        case 3: return @"@3x";
        default:
            return @"";
    }
}

-(UIImage*) getImage:(NSString*) rootImageName{
    
    int scaleIndex=self.imageType.selectedSegmentIndex;
    if(scaleIndex==0){
        return [UIImage imageNamed:rootImageName];
    }
    
    CGFloat imageScale = scaleIndex;
    NSString* imageSuffix = [self getImageSuffix:scaleIndex];
    NSString* imageName = [NSString stringWithFormat:@"%@%@", rootImageName, imageSuffix];
    
    return [self loadFileExplicitly:imageName scale:imageScale];
}

/////////////////////////////////////////////////
//Dynamic vector map

-(NSMutableArray*) coordinateArrayToPolygon:(float[]) coordinateArray
                                 startIndex:(int) startIndex
                                   endIndex:(int) endIndex{
    NSMutableArray* polygonPoints=[[NSMutableArray alloc]init];
    for(int i=startIndex; i<=endIndex;){
        float lon = coordinateArray[i++];
        float lat = coordinateArray[i++];
        [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(lon,lat)]];
    }
    //Close the polygon
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(coordinateArray[startIndex],
                                                                   coordinateArray[startIndex+1])]];
    return polygonPoints;
}

- (MEPolygonStyle*) polygonStyleWithStrokeColor:(UIColor*) strokeColor
                                   andFillColor:(UIColor*) fillColor{
    
    
    MEPolygonStyle* style=[[MEPolygonStyle alloc]init];
    style.strokeColor = strokeColor;
    style.fillColor = fillColor;
    style.strokeWidth = 2;
    style.shadowColor = [UIColor colorWithRed:0
                                        green:0
                                         blue:0
                                        alpha:0.4];
    return  style;
}

- (MEPolygonStyle*) getRandomStyle{
    MEPolygonStyle* polygonStyle=[[MEPolygonStyle alloc]init];
    
    CGFloat r = [METest randomDouble:0 max:1];
    CGFloat g = [METest randomDouble:0 max:1];
    CGFloat b = [METest randomDouble:0 max:1];
    
    //Solid stroke
    polygonStyle.strokeColor = [UIColor colorWithRed:r
                                               green:g
                                                blue:b
                                               alpha:1.0];
    //Transparent fill
    polygonStyle.fillColor = [UIColor colorWithRed:r
                                             green:g
                                              blue:b
                                             alpha:0.5];
    
    polygonStyle.strokeWidth = 2;
    
    //A shadow
    polygonStyle.shadowColor = [UIColor colorWithRed:0
                                               green:0
                                                blue:0
                                               alpha:0.4];
    
    return polygonStyle;
}

- (void) addCircleWithName:(NSString*) circleName
                       lon:(float) lon
                       lat:(float) lat
                    radius:(float) radius{
    
    UIColor* strokeColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    UIColor* fillColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
    MEPolygonStyle* style = [self polygonStyleWithStrokeColor:strokeColor andFillColor:fillColor];
    
    NSMutableArray* points = [[NSMutableArray alloc]init];
    CGPoint center = CGPointMake(lon,lat);
    for(int i=360; i>=5; i-=5){
        [points addObject:[NSValue valueWithCGPoint:
                           [MEMath pointOnRadial:center
                                          radial:i
                                        distance:radius]]];
    }
    
    //Close polygon
    [points addObject:[NSValue valueWithCGPoint:
                       [MEMath pointOnRadial:center
                                      radial:0
                                    distance:radius]]];
    
    
    [self.meMapViewController addPolygonToVectorMap:self.vectorMapName
                                          polygonId:circleName
                                             points:points
                                              style:style];
}

- (void) addPolygon:(NSString*)name
        coordinates:(float[]) coordinateArray
          arraySize:(int) arraySize{
    
    //Create an array of points for a polygon
    NSMutableArray* points=[self coordinateArrayToPolygon:coordinateArray
                                               startIndex:0
                                                 endIndex:arraySize-1];
    //Add the polygon to the map
    [self.meMapViewController addPolygonToVectorMap:self.vectorMapName
                                          polygonId:name
                                             points:points
                                              style:[self getRandomStyle]];
    
}

- (void) polygonHitDetected:(MEMapView *)mapView hits:(NSArray *)polygonHits{
    NSString* alertMessage =@"Shapes Tapped:";
    
    for(MEVectorGeometryHit* polygonHit in polygonHits){
        
        //Append to alert message
        alertMessage = [NSString stringWithFormat:@"%@\n%@",
                        alertMessage,
                        [NSString stringWithFormat:@"%@ tapped at (%.3f,%.3f)",
                         polygonHit.shapeId,
                         polygonHit.location.longitude,
                         polygonHit.location.latitude]];
        
        //Send to log
        NSLog(@"Hit detected on map:%@ shapeId:%@ tap location: %f, %f",
              polygonHit.mapName,
              polygonHit.shapeId,
              polygonHit.location.latitude,
              polygonHit.location.longitude);
    }
    
    //Show a pop up with all polygons that were tapped
    [self showAlert:alertMessage timeout:2];
}

- (void) addVectorMap{
    MEVectorMapInfo* vectorMapInfo = [[MEVectorMapInfo alloc]init];
    vectorMapInfo.name = self.vectorMapName;
    vectorMapInfo.zOrder = 100;
    vectorMapInfo.maxLevel = 9;
    vectorMapInfo.polygonHitDetectionEnabled = true;
    vectorMapInfo.meVectorMapDelegate = self;
    [self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
    
    [self addCircleWithName:@"Raleigh-Durham (KRDU)"
                        lon:RDU_COORD.longitude
                        lat:RDU_COORD.latitude
                     radius:5];
    
    [self addCircleWithName:@"John F. Kennedy (KFJK)"
                        lon:JFK_COORD.longitude
                        lat:JFK_COORD.latitude
                     radius:5];
    
    [self addCircleWithName:@"San Francisco (KSFO)"
                        lon:SFO_COORD.longitude
                        lat:SFO_COORD.latitude
                     radius:5];
    
    [self addCircleWithName:@"Houston (KHOU)"
                        lon:HOU_COORD.longitude
                        lat:HOU_COORD.latitude
                     radius:5];
    
    [self addCircleWithName:@"Miami (KMIA)"
                        lon:MIA_COORD.longitude
                        lat:MIA_COORD.latitude
                     radius:5];
    
}

- (void) removeVectorMap{
    [self.meMapViewController removeMap:self.vectorMapName clearCache:YES];
}

- (void) updateVectorMap{
    [self removeVectorMap];
    [self addVectorMap];
}

/////////////////////////////////////////////////
//Animated circle
- (void) addBeacon{
	
	//Create an animated vector circle object and set up all of its properties
	MEAnimatedVectorCircle* beacon = [[MEAnimatedVectorCircle alloc]init];
	beacon.name=self.vectorCircleName;
    
    UIColor* lightWhite = [UIColor colorWithRed:1.0
                                          green:1.0
                                           blue:1.0
                                          alpha:0.8];
	beacon.lineStyle = [[MELineStyle alloc]initWithStrokeColor:lightWhite
                                                   strokeWidth:3];
	
	UIColor* lightBlue = [UIColor colorWithRed:30.0/255.0
										 green:144.0/255.0
										  blue:255.0/255.0
										 alpha:0.8];
    
	beacon.lineStyle.outlineColor = lightBlue;
	beacon.lineStyle.outlineWidth = 3;
	beacon.location = RDU_COORD;
	beacon.minRadius = 10;
	beacon.maxRadius = 128;
	beacon.animationDuration = 2;
    beacon.repeatDelay = 0;
	beacon.fade = YES;
	beacon.fadeDelay = 1.0;
	beacon.zOrder= 5;
	
	//Add the animated vector circle
	[self.meMapViewController addAnimatedVectorCircle:beacon];
}

-(void) updateBeacon{
    [self removeBeacon];
    [self addBeacon];
}

- (void) removeBeacon{
    [self.meMapViewController removeAnimatedVectorCircle:self.vectorCircleName];
}


/////////////////////////////////////////////////
//Dynamic marker
- (void) addDynamicMarkerMap{
    //Add marker map
	MEDynamicMarkerMapInfo* mapInfo = [[MEDynamicMarkerMapInfo alloc]init];
	mapInfo.name = self.dynamicMarkerMapName;
	mapInfo.zOrder = 200;
	mapInfo.hitTestingEnabled = YES;
	mapInfo.meDynamicMarkerMapDelegate = self;
	mapInfo.fadeInTime = 0;
	mapInfo.fadeOutTime = 0;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
    [self addMarker:self.markerId];
}

-(void) addMarker:(int) markerId{
    NSString* markerName = [NSString stringWithFormat:@"%d", markerId];
    MEMarker* marker = [[MEMarker alloc]init];
    marker.uiImage = [self getImage:@"ScaleTest"];
    NSLog(@"Loading image with point size %fx%f scale of %f",
          marker.uiImage.size.width,
          marker.uiImage.size.height,
          marker.uiImage.scale);
    marker.uniqueName=markerName;
    marker.location = RDU_COORD;
    marker.anchorPoint = CGPointMake(128.5,128.5);
    [self.meMapViewController addDynamicMarkerToMap:self.dynamicMarkerMapName dynamicMarker:marker];
}

-(void) removeMarker:(int) markerId{
    NSString* markerName = [NSString stringWithFormat:@"%d", markerId];
    [self.meMapViewController removeDynamicMarkerFromMap:self.dynamicMarkerMapName markerName:markerName];
}

-(void) updateMarker{
    [self removeMarker:self.markerId];
    self.markerId++;
    [self addMarker:self.markerId];
}

- (void) removeMarkerMap{
    [self.meMapViewController removeMap:self.dynamicMarkerMapName clearCache:YES];
}

/////////////////////////////////////////////////
//Clusterd markers
- (void) addClusteredMarkerMap{
    
    //Cache the marker image
    [self.meMapViewController addCachedMarkerImage:[self getImage:@"ScaleTestCircle"]
                                          withName:@"ScaleTestCircle"
                                   compressTexture:NO
                    nearestNeighborTextureSampling:YES];
    
    MEMarkerMapInfo* mapInfo = [[MEMarkerMapInfo alloc]init];
	mapInfo.name = self.clusteredMarkerMapName;
	mapInfo.mapType = kMapTypeFileMarker;
	mapInfo.sqliteFileName = [[NSBundle mainBundle] pathForResource:@"Places"
                                                             ofType:@"sqlite"];
	mapInfo.zOrder = 100;
	mapInfo.meMarkerMapDelegate = self;
    mapInfo.hitTestingEnabled = YES;
    mapInfo.markerImageLoadingStrategy=kMarkerImageLoadingSynchronous;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

-(void) mapView:(MEMapView *)mapView updateMarker:(MEMarker *)marker mapName:(NSString *)mapName{
    marker.cachedImageName=@"ScaleTestCircle";
    marker.anchorPoint = CGPointMake(15.5,15.5);
}

- (void) tapOnMarker:(NSString *)metaData onMapView:(MEMapView *)mapView atScreenPoint:(CGPoint)point{
    [self showAlert:metaData timeout:1.5];
}

- (void) removeClusteredMarkerMap{
    [self.meMapViewController removeMap:self.clusteredMarkerMapName clearCache:YES];
}

- (void) updateClusteredMarkerMap{
    [self removeClusteredMarkerMap];
    [self addClusteredMarkerMap];
}

/////////////////////////////////////////////////
//Raster map
-(NSString*) getRasterMapName{
    return @"MapBox Streets";
}

-(void) addRasterMap{
    [self.meTestManager startTestInCategory:@"Raster Maps"
                                   withName:[self getRasterMapName]];
}

-(void) removeRasterMap{
    [self.meTestManager stopCategory:@"Raster Maps"];
}

-(void) updateRasterMap{
    [self removeRasterMap];
    [self addRasterMap];
}

/////////////////////////////////////////////////
//Add/Remove map layers
- (void) addMaps{
    [self addDynamicMarkerMap];
    [self addBeacon];
    [self addClusteredMarkerMap];
    [self addRasterMap];
    [self addVectorMap];
    [self.meMapViewController setMapPriority:self.clusteredMarkerMapName priority:1];
    [self.meMapViewController setMapPriority:self.rasterMapName priority:10];
}

- (void) removeMaps{
    [self removeMarkerMap];
    [self removeBeacon];
    [self removeClusteredMarkerMap];
    [self removeRasterMap];
    [self removeVectorMap];
}


/////////////////////////////////////////////////
//Test UI
-(void) updateScaleLabel{
    self.lblScaleSlider.text=[NSString stringWithFormat:@"Content Scale (%0.2f)", self.scaleSlider.value];
}

-(void) sliderScaleChanged{
    self.meMapViewController.meMapView.contentScaleFactor=self.scaleSlider.value;
    [self updateScaleLabel];
}

-(void) imageTypeChanged{
    [self updateMarker];
    [self updateClusteredMarkerMap];
}

-(CGFloat) getPointSize:(int) index{
    switch(index){
        case 0: return 1140;
        case 1: return 760;
        case 2: return 512;
        case 3: return 380;
        case 4: return 256;
        case 5: return 128;
        default: return 380;
    }
}

-(void) tileSizeChanged{
    CGFloat newTileSize = (CGFloat)[self getPointSize:self.tileSize.selectedSegmentIndex];
    self.meMapViewController.meMapView.tilePointSize = newTileSize;
}

- (void)markerAutoScaleSwitchChange:(id)sender{
    self.meMapViewController.autoScaleMarkerImages = [sender isOn];
    [self updateMarker];
    [self updateClusteredMarkerMap];
}

-(float) getFontSize{
    //17 lines to fit on half the vertical size
    float min = self.meMapViewController.meMapView.bounds.size.height / 2.0 / 20.0;
    if(min<18){
        return 9.0f;
    }
    else{
        return 18.0f;
    }
}

-(float) getControlHeight{
    if([self getFontSize]==18.0f){
        return 50.0f;
    }
    else{
        return 25.0f;
    }
}

-(void) addStatsLabel{
    //Create label to show stats in
    float y = 10;
    float maxWidth = self.meMapViewController.meMapView.bounds.size.width-y;
    self.lblStats = [[UILabel alloc]initWithFrame:CGRectMake(10,y,maxWidth,100)];
    [self.lblStats setTextColor:[UIColor whiteColor]];
    [self.lblStats setBackgroundColor:[UIColor clearColor]];
    self.lblStats.shadowColor = [UIColor blackColor];
    self.lblStats.shadowOffset=CGSizeMake(2.0,2.0);
    self.lblStats.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.lblStats.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.lblStats.layer.shadowRadius = 1.0;
    self.lblStats.layer.shadowOpacity = 1.0;
    self.lblStats.adjustsFontSizeToFitWidth=NO;
    [self.lblStats setFont:[UIFont boldSystemFontOfSize:[self getFontSize]]];
    self.lblStats.numberOfLines = 0;
    self.lblStats.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:self.lblStats];
}

-(UILabel*) addLabel:(NSString*) text frame:(CGRect) frame{
    UILabel* lbl=[[UILabel alloc]initWithFrame:frame];
    lbl.text=text;
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setBackgroundColor:[UIColor clearColor]];
    lbl.shadowColor = [UIColor blackColor];
    lbl.shadowOffset=CGSizeMake(2.0,2.0);
    lbl.layer.shadowColor = [[UIColor blackColor] CGColor];
    lbl.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    lbl.layer.shadowRadius = 1.0;
    lbl.layer.shadowOpacity = 1.0;
    lbl.adjustsFontSizeToFitWidth=NO;
    [lbl setFont:[UIFont boldSystemFontOfSize:[self getFontSize]]];
    lbl.numberOfLines = 0;
    [self.view addSubview:lbl];
    return lbl;
}

-(void) createUserInterface{
    [self createView];
    [self addStatsLabel];
    
    float controlCount=4;
    float margin=10;
    float controlHeight=[self getControlHeight];
    float labelWidth=controlHeight*4;
    
    float spacing=5;
    float controlTop=self.meMapViewController.meMapView.bounds.size.height - (controlCount)*(controlHeight+spacing) - 50;
    float controlLeft=margin+labelWidth+spacing;
    float controlWidth=self.meMapViewController.meMapView.bounds.size.width-controlLeft-spacing-margin*2;
    
    //Create frames for all controls
    CGRect scaleLabelFrame=CGRectMake(margin, controlTop, labelWidth, controlHeight);
    CGRect scaleSliderFrame=CGRectMake(controlLeft, controlTop, controlWidth, controlHeight);
    controlTop+=controlHeight+spacing;
    
    CGRect imageTypeLabelFrame=CGRectMake(margin, controlTop, labelWidth, controlHeight);
    CGRect imageTypeFrame=CGRectMake(controlLeft, controlTop, controlWidth, controlHeight);
    controlTop+=controlHeight+spacing;
    
    CGRect markerAutoScaleLabelFrame=CGRectMake(margin, controlTop, labelWidth, controlHeight);
    CGRect markerAutoScaleSwitchFrame=CGRectMake(controlLeft, controlTop, controlWidth/4, controlHeight);
    controlTop+=controlHeight+spacing;
    
    CGRect tileSizeLabelFrame=CGRectMake(margin, controlTop, labelWidth, controlHeight);
    CGRect tileSizeFrame=CGRectMake(controlLeft, controlTop, controlWidth, controlHeight);
    
    //Scale slider
    self.lblScaleSlider=[self addLabel:@"Content Scale:" frame:scaleLabelFrame];
    self.scaleSlider = [[UISlider alloc] initWithFrame:scaleSliderFrame];
    [self.scaleSlider addTarget:self
                         action:@selector(sliderScaleChanged)
               forControlEvents:UIControlEventValueChanged];
    
    [self.scaleSlider setBackgroundColor:[UIColor clearColor]];
    self.scaleSlider.continuous=YES;
    self.scaleSlider.minimumValue = 0.5;
    self.scaleSlider.maximumValue = 3;
    self.scaleSlider.value = self.meMapViewController.meMapView.contentScaleFactor;
    [self.view addSubview:self.scaleSlider];
    
    //Create label for image loading scale
    [self addLabel:@"Marker Images:" frame:imageTypeLabelFrame];
    
    //Create segmented control for image loading scale
    self.imageType = [[UISegmentedControl alloc] initWithItems:@[@"OS Default",
                                                                 @"1x",
                                                                 @"2x",
                                                                 @"3x"]];
    self.imageType.frame=imageTypeFrame;
    self.imageType.layer.borderWidth=2.0f;
    self.imageType.layer.borderColor=[[UIColor whiteColor] CGColor];
    [self.imageType setSelectedSegmentIndex:0];
    [self.imageType addTarget:self
                       action:@selector(imageTypeChanged)
             forControlEvents:UIControlEventValueChanged];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14], NSFontAttributeName, nil];
    [self.imageType setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [self.view addSubview:self.imageType];
    
    //Marker auto-scale switch
    [self addLabel:@"Auto-Scale Marker Images:" frame:markerAutoScaleLabelFrame];
    self.markerAutoScaleSwitch = [[UISwitch alloc]init];
    self.markerAutoScaleSwitch.on=self.meMapViewController.autoScaleMarkerImages;
    self.markerAutoScaleSwitch.frame = markerAutoScaleSwitchFrame;
    [self.markerAutoScaleSwitch addTarget:self
                                   action:@selector(markerAutoScaleSwitchChange:)
                         forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.markerAutoScaleSwitch];
    
    //Create label for tile size
    [self addLabel:@"Tile Point Size:" frame:tileSizeLabelFrame];
   
    //Create segmented control for tile size
    NSMutableArray* itemArray = [[NSMutableArray alloc]init];
    for(int i=0; i<6; i++){
        NSString* sizeEntry = [NSString stringWithFormat:@"%0.1f",[self getPointSize:i]];
        [itemArray addObject:sizeEntry];
    }
    self.tileSize = [[UISegmentedControl alloc] initWithItems:itemArray];
    
    self.tileSize.layer.borderWidth=2.0f;
    self.tileSize.layer.borderColor=[[UIColor whiteColor] CGColor];
    self.tileSize.frame = tileSizeFrame;
    [self.tileSize setSelectedSegmentIndex:3];
    [self.tileSize addTarget:self
                      action:@selector(tileSizeChanged)
            forControlEvents:UIControlEventValueChanged];
    [self.tileSize setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [self.view addSubview:self.tileSize];
    
    [self updateScaleLabel];
}

-(NSString*) getOSViewInfo{
    return [NSString stringWithFormat:
            @"Main screen bounds: (%0.1f x %0.1f) pts\n"
            @"Main screen scale: %0.1f\n"
            @"GLKView bounds: (%0.1f x %0.1f) pts\n"
            @"GLKView contentScale: %f\n"
            @"GLKVIew draw size: (%ld x %ld) pix\n\n"
            "",
            
            //Main screen
            [UIScreen mainScreen].bounds.size.width,
            [UIScreen mainScreen].bounds.size.height,
            [UIScreen mainScreen].scale,
            
            //GLKView
            self.meMapViewController.meMapView.bounds.size.width,
            self.meMapViewController.meMapView.bounds.size.height,
            self.meMapViewController.meMapView.contentScaleFactor,
            (long)self.meMapViewController.meMapView.drawableWidth,
            (long)self.meMapViewController.meMapView.drawableHeight
            ];
}


-(NSString*) getMEInfo{
    MEInfo* meInfo = self.meMapViewController.meInfo;
    MELocation currentLocation = self.meMapViewController.meMapView.location;
    return [NSString stringWithFormat:
            @"Altus render target: (%d x %d) pix\n"
            "Altus device scale: %f\n"
            "Tile size: %0.1f pts : %d pix\n"
            "FPS: %f\n"
            "RAM:  %.1f MB\n"
            "Cache:  %.1f MB\n"
            "Center:  (%.3f, %.3f)\n"
            "Alt: %.3f M\n"
            "Visible Tiles: %d\n"
            "",
            meInfo.renderTargetWidth, meInfo.renderTargetHeight,
            meInfo.deviceScale,
            self.meMapViewController.meMapView.tilePointSize,
            self.meMapViewController.meMapView.tilePixelSize,
             meInfo.frameRate,
            (float)meInfo.appMemoryUsage / 1000000.0f,
            (float)meInfo.tileCacheMemorySize / 1000000.0f,
            currentLocation.center.longitude,
            currentLocation.center.latitude,
            currentLocation.altitude,
            meInfo.visibleTileCount
            ];
}

-(void) updateUI{
    self.lblStats.text=[NSString stringWithFormat:
                        @"%@%@",
                        [self getOSViewInfo],
                        [self getMEInfo]
                        ];
    
    [self.lblStats sizeToFit];
}

-(void) timerTick{
    [self updateUI];
}

/**MEMapView delegate method, called when physical device scale changes.*/
-(void) deviceScaleChanged:(MEMapView*) mapView{
    if(self.isRunning){
        [self updateMarker];
        [self updateUI];
        [self updateBeacon];
        [self updateClusteredMarkerMap];
        [self updateVectorMap];
    }
}

/**MEMapView delegate method, called when tile point size changes. This affects how maps appear.*/
-(void) tileSizeChanged:(MEMapView *)mapView{
    if(self.isRunning){
        [self updateClusteredMarkerMap];
        [self updateRasterMap];
    }
}

-(void) beginTest{
    
    //Stop other tests
    [self.meTestManager stopAllTests];
    
    //Set tile point size
    self.meMapViewController.meMapView.tilePointSize=380;
    
    self.meMapViewController.autoScaleMarkerImages = YES;
    
    //Create test UI
    [self createUserInterface];
    
    //Look at Raleigh, NC
    [self.meMapViewController.meMapView setLocation:MELocationMake(RDU_COORD.longitude, RDU_COORD.latitude, 100000)];
    
    //Listen for device scale changes
    self.meMapViewController.meMapView.meMapViewDelegate = self;
    
    //Add map layers for this tst
    [self addMaps];
    
    //Start updating labels
    [self startTimer];
}

-(void) endTest{
    [self removeMaps];
    [self.meTestManager startInitialTest];
}

@end
