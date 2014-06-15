//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "Asteroids.h"

////////////////////////////////////////////////////////////////////////
@implementation VectorObject
- (id) init {
	if(self=[super init]){
        [self createGeometry];
	}
	return self;
}

-(void) createGeometry{
    NSLog(@"Override this. Exiting.");
    exit(0);
}

-(UIColor*) randomColor{
    return [UIColor colorWithRed:[METest randomFloat:0.0 max:1.0]
                           green:[METest randomFloat:0.0 max:1.0]
                            blue:[METest randomFloat:0.0 max:1.0]
                           alpha:1.0];
}

-(void) update{
    
    //Update rotation
    self.rotation += self.rotationDelta;
    if(self.course + self.rotation > 360) self.rotation -= 360;
    else if(self.course + self.rotation < 0) self.rotation += 360;
    
    //Compute new location based on course and speed
    CGPoint currentLocation = CGPointMake(self.longitude, self.latitude);
    CGPoint newLocation = [MEMath pointOnRadial:currentLocation
                                         radial:self.course
                                       distance:self.speed];
    self.longitude = newLocation.x;
    self.latitude = newLocation.y;
    
    //Compute new course
    self.course = [MEMath courseFromPoint:newLocation toPoint:currentLocation] + 180;
    if(self.course>360){
        self.course-=360;
    }
}

//Converts and NSValue wrapped CGPoint from radial format
//to geographic coordinate format based on current location and rotation
-(NSValue*) radialPointToCoordinate:(NSValue*) radialPointValue{
    
    //Get CGPoint out of value
    CGPoint radialPoint = radialPointValue.CGPointValue;
    
    //Convert to geographic coordinates base on current position and rotation
    float angle = radialPoint.x + self.course + self.rotation;
    float distance = radialPoint.y;
    CGPoint coordinatePoint = [MEMath pointOnRadial:CGPointMake(self.longitude,
                                                                self.latitude)
                                             radial:angle
                                           distance:distance];
    
    //Return wrapped in NSValue object
    return [NSValue valueWithCGPoint:coordinatePoint];
}

//Returns a series of points in geographic space that represent the shape
-(NSMutableArray*) getPolygonPoints{
    NSMutableArray* coordinatePoints = [NSMutableArray array];
    for(NSValue* radialPointValue in self.radialPoints){
        [coordinatePoints addObject:[self radialPointToCoordinate:radialPointValue]];
    }
    //Close the shape
    NSValue* firstPointValue=[self.radialPoints objectAtIndex:0];
    [coordinatePoints addObject:[self radialPointToCoordinate:firstPointValue]];
    
    //And make them join up nice
    NSValue* secondPointValue=[self.radialPoints objectAtIndex:1];
    [coordinatePoints addObject:[self radialPointToCoordinate:secondPointValue]];
    
    return coordinatePoints;
}

-(NSArray*) getLinePoints{
    NSMutableArray* linePoints = [self getPolygonPoints];
    
    //Make lines join up nicely, we'll over lap the end,
    //over the top of the start
    NSValue* secondPointValue=[self.radialPoints objectAtIndex:1];
    [linePoints addObject:[self radialPointToCoordinate:secondPointValue]];
    return linePoints;
}

-(void) drawLines:(MEMapViewController*) meMapViewController
          mapName:(NSString*) mapName{
    
    [meMapViewController addDynamicLineToVectorMap:mapName
                                            lineId:@""
                                            points:[self getLinePoints]
                                             style:self.lineStyle];
}

-(void) drawPolygon:(MEMapViewController*) meMapViewController
            mapName:(NSString*) mapName
        withTexture:(NSString*) textureName{
    self.polygonStyle.textureName = textureName;
    [meMapViewController addDynamicPolygonToVectorMap:mapName
                                              shapeId:@"a"
                                               points:[self getPolygonPoints]
                                                style:self.polygonStyle];
    
}
@end

////////////////////////////////////////////////////////////////////////
@implementation Ship

- (id) init {
    self=[super init];
    return self;
}


-(void) createGeometry{
    
    self.radialPoints=[NSMutableArray array];
    [self.radialPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0, 50)]];
    [self.radialPoints addObject:[NSValue valueWithCGPoint:CGPointMake(90+45, 50)]];
    [self.radialPoints addObject:[NSValue valueWithCGPoint:CGPointMake(180, 25)]];
    [self.radialPoints addObject:[NSValue valueWithCGPoint:CGPointMake(180+45, 50)]];
    [self.radialPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0, 50)]];
    
    self.course = 0;
    self.rotation = 0;
    self.speed = 0;
    
    //Create line style
    self.lineStyle = [[MELineStyle alloc]init];
    self.lineStyle.strokeWidth = 3;
    self.lineStyle.strokeColor = [UIColor whiteColor];
    self.lineStyle.outlineColor = [UIColor blackColor];
    
    //Create polygon style
    self.polygonStyle = [[MEPolygonStyle alloc]init];
    self.polygonStyle.strokeWidth = self.lineStyle.strokeWidth;
    self.polygonStyle.strokeColor = self.lineStyle.outlineColor;
    self.polygonStyle.shadowColor = [UIColor blackColor];
    self.polygonStyle.shadowOffset = CGPointMake(-1,1);
    self.polygonStyle.fillColor = self.lineStyle.strokeColor;
}

-(void) updateShip:(NSArray*) asteroids{
    CGPoint shipPoint = CGPointMake(self.longitude, self.latitude);
    double nearest = 999999999999;
    
    CGPoint closestAsteroidPoint;
    for(Asteroid* a in asteroids){
        CGPoint asteroidPoint = CGPointMake(a.longitude, a.latitude);
        double nm = [MEMath nauticalMilesBetween:shipPoint
                                          point2:asteroidPoint];
        if(nm<nearest){
            nearest = nm;
            self.nearestThreat = a;
            closestAsteroidPoint = asteroidPoint;
        }
    }
    double bearingToTarget = [MEMath courseFromPoint:shipPoint
                                             toPoint:closestAsteroidPoint];
    //bearingToTarget+=180;
    //if(bearingToTarget>360) bearingToTarget-=360;
    //if(bearingToTarget<0) bearingToTarget+=360;
    if(nearest<100){
        self.speed = 50;
    }
    else if(nearest<500){
        self.speed = 25;
    }
    else if(nearest<1000){
        self.speed = 12;
    }
    else if(nearest<10000){
        self.speed = 0;
    }
    self.rotation = bearingToTarget;
    self.course = self.rotation+180;
    [self update];
    return;
}

@end


////////////////////////////////////////////////////////////////////////
@implementation Asteroid

- (id) init {
    self=[super init];
    return self;
}


-(void) createGeometry{
    
    //Randomize location
    self.longitude = [METest randomFloat:-180 max:180];
    self.latitude = [METest randomFloat:-90 max:90];
    
    //Make some random points (random distance on random radials around the center)
    self.radialPoints=[NSMutableArray array];
    float size = [METest randomFloat:0.25 max:1];
    float lastAngle=0;
    while(lastAngle<360){
        float newAngle = lastAngle +[METest randomFloat:20 max:35];
        lastAngle = newAngle;
        if(newAngle<360){
            float newRadius = size * [METest randomFloat:100 max:300];
            //Encode the angle and radus in a CGPoint for convenience
            CGPoint newPoint = CGPointMake(newAngle, newRadius);
            [self.radialPoints addObject:[NSValue valueWithCGPoint:newPoint]];
        }
    }
    
    //Now give it some random velocity and rotation
    while(abs(self.rotationDelta<2)){
        self.rotationDelta = [METest randomFloat:-10 max:10];
    }
    
    self.course = [METest randomFloat:0 max:360];
    self.rotation = 0;
    self.speed = [METest randomFloat:10 max:100];
    
    
    //Create line style
    self.lineStyle = [[MELineStyle alloc]init];
    self.lineStyle.strokeWidth = [METest randomFloat:1 max:3];
    self.lineStyle.strokeColor = [self randomColor];
    self.lineStyle.outlineWidth = 1;
    self.lineStyle.outlineColor = [UIColor whiteColor];
    
    //Create polygon style
    self.polygonStyle = [[MEPolygonStyle alloc]init];
    self.polygonStyle.strokeWidth = self.lineStyle.strokeWidth;
    self.polygonStyle.strokeColor = self.lineStyle.outlineColor;
    self.polygonStyle.shadowColor = [UIColor blackColor];
    self.polygonStyle.shadowOffset = CGPointMake(-1,1);
    self.polygonStyle.fillColor = self.lineStyle.strokeColor;
}

@end

/////////////////////////////////////////////////////////////////////////////
@implementation Asteroids

static int _renderingMode;
static int _cameraMode;
static int _lastCameraMode;
static int _asteroidCount = 100;
static int _lastAsteroidCount;

+ (void)initialize{
    static BOOL initialized = NO;
    if(!initialized){
        initialized = YES;
        _renderingMode=0;
        _cameraMode=0;
        _lastCameraMode = _cameraMode;
        _lastAsteroidCount = _asteroidCount;
    }
}

- (id) init {
	if(self=[super init]){
		self.name = @"Asteroids";
        self.interval = 0.01;
	}
	return self;
}

-(void) initAsteroids{
    self.asteroids = [NSMutableArray array];
    for(int i=0; i<_asteroidCount; i++){
        [self addAsteroid];
    }
}

-(void) initShip{
    self.ship = [[Ship alloc]init];
    self.ship.longitude = self.meMapViewController.meMapView.centerCoordinate.longitude;
    self.ship.latitude = self.meMapViewController.meMapView.centerCoordinate.latitude;
}

-(void) addAsteroid{
    Asteroid* asteroid = [[Asteroid alloc]init];
    [self.asteroids addObject:asteroid];
}

- (void) addDynamicVectorMap{
    MEVectorMapInfo* mapInfo = [[MEVectorMapInfo alloc]init];
    mapInfo.name = self.name;
    mapInfo.mapType = kMapTypeDynamicVector;
    mapInfo.zOrder = 101;
    [self.meMapViewController addMapUsingMapInfo:mapInfo];
}

- (void) updateAsteroids{
    for(Asteroid* asteroid in _asteroids){
        [asteroid update];
    }
}

- (void) drawEverything{
    [self.meMapViewController clearDynamicGeometryFromMap:self.name];
    
    //Draw asteroids
    for(Asteroid* asteroid in self.asteroids){
        switch(_renderingMode){
            case 0:
                [asteroid drawLines:self.meMapViewController
                            mapName:self.name];
                break;
            case 1:
                [asteroid drawPolygon:self.meMapViewController
                              mapName:self.name
                          withTexture:nil];
                break;
            case 2:
                [asteroid drawPolygon:self.meMapViewController
                              mapName:self.name
                          withTexture:@"Asteroid"];
                break;
        }
    }
    
    //Draw ship
    switch(_renderingMode){
        case 0:
            [self.ship drawLines:self.meMapViewController
                         mapName:self.name];
            break;
        case 1:
        case 2:
            [self.ship drawPolygon:self.meMapViewController
                           mapName:self.name
                       withTexture:nil];
            break;
    }
    
    if(self.ship.nearestThreat){
        [self.ship.nearestThreat drawPolygon:self.meMapViewController
                                     mapName:self.name
                                 withTexture:nil];
    }
    if(self.isRunning){
        [self startTimer];
    }
}

- (void) beginTest{
    //Cache polygon texture
    [self.meMapViewController addCachedImage:[UIImage imageNamed:@"Asteroid"]
                                    withName:@"Asteroid"
                             compressTexture:NO];
    
    //Stop all tests in this category
    [self.meTestCategory stopAllTests];
    
    //Turn off gray grid
    [self.meMapViewController setMapIsVisible:@"_baseMap_" isVisible:NO];
    
    //Add a virtual vector overlay grid
    self.vectorGrid = [[VectorGrid alloc]init];
    self.vectorGrid.meMapViewController = self.meMapViewController;
    [self.vectorGrid start];
    
    //Add a dynamic vector map
    [self addDynamicVectorMap];
	self.isRunning = YES;
    
    //Create some asteroids
    [self initAsteroids];
    
    //Create ship
    [self initShip];
    
    //Set camera mode
    [self setCameraMode];
    
    //Start drawing stuff
    [self startTimer];
}

-(void) setCameraMode{
    switch(_cameraMode){
        case 0:
            [self.meMapViewController.meMapView setCameraOrientation:0
                                                                roll:0
                                                               pitch:0
                                                   animationDuration:0];
            [self.meMapViewController unsetRenderMode:METrackUp];
            break;
        case 1:
            [self.meMapViewController setRenderMode:METrackUp];
            [self.meMapViewController setTrackUpForwardDistance:0 animationDuration:2];
            break;
        case 2:
            [self.meMapViewController setRenderMode:METrackUp];
            [self.meMapViewController setTrackUpForwardDistance:200 animationDuration:2];
            break;
        case 3:
            break;
            
    }
}

-(void) trackSomeAsteroid{
    //Track some asteroid
    Asteroid* asteroid = [_asteroids objectAtIndex:0];
    MELocation loc = self.meMapViewController.meMapView.location;
    loc.center.longitude = asteroid.longitude;
    loc.center.latitude = asteroid.latitude;
    self.meMapViewController.meMapView.location = loc;
    switch(_cameraMode){
        case 1:
        case 2:
            [self.meMapViewController.meMapView setCameraOrientation:asteroid.course
                                                                roll:0
                                                               pitch:0
                                                   animationDuration:0];
            break;
        case 3:
            [self.meMapViewController.meMapView setCameraOrientation:asteroid.course+asteroid.rotation
                                                                roll:0
                                                               pitch:0
                                                   animationDuration:0];
            break;
            
    }
}

-(void) trackShip{
    MELocation loc = self.meMapViewController.meMapView.location;
    loc.center.longitude = self.ship.longitude;
    loc.center.latitude = self.ship.latitude;
    self.meMapViewController.meMapView.location = loc;
    switch(_cameraMode){
        case 1:
        case 2:
            [self.meMapViewController.meMapView setCameraOrientation:self.ship.rotation
                                                                roll:0
                                                               pitch:0
                                                   animationDuration:0];
            break;
        case 3:
            [self.meMapViewController.meMapView setCameraOrientation:self.ship.course
                                                                roll:0
                                                               pitch:0
                                                   animationDuration:0];
            break;
            
    }
}

- (void) timerTick{
    [self stopTimer];
    if(!self.isRunning){
        return;
    }
    
    [self.ship updateShip:self.asteroids];
    [self updateAsteroids];
    [self drawEverything];
    
    //Update camera mode, but only if it changes
    if(_cameraMode!=_lastCameraMode){
        [self setCameraMode];
    }
    _lastCameraMode = _cameraMode;
    
    //Recreate asteroids if count changes
    if(_lastAsteroidCount!=_asteroidCount){
        [self initAsteroids];
    }
    _lastAsteroidCount = _asteroidCount;
    
    //Track an asteroid
    if(_cameraMode>0){
        [self trackSomeAsteroid];
    }
}

- (void) endTest{
    
    [self.meMapViewController.meMapView setCameraOrientation:0
                                                        roll:0
                                                       pitch:0
                                           animationDuration:0];
    [self.meMapViewController unsetRenderMode:METrackUp];
    
    [self.meMapViewController removeMap:self.name clearCache:YES];
    [self.vectorGrid stop];
    [self.meMapViewController setMapIsVisible:@"_baseMap_" isVisible:YES];
}

+(NSString*) renderingModeDesc{
    switch(_renderingMode){
        case 0:
            return @"Lines";
            break;
        case 1:
            return @"Polygons";
            break;
        case 2:
            return @"Textured Polygons";
            break;
        default:
            return @"Uknown";
            break;
    }
}

+(void) cycleRenderingMode{
    _renderingMode++;
    if(_renderingMode>2){
        _renderingMode=0;
    }
}

+(NSString*) cameraModeDesc{
    switch(_cameraMode){
        case 0:
            return @"Normal";
            break;
        case 1:
            return @"Track Up";
            break;
        case 2:
            return @"Track Up Forward";
            break;
        case 3:
            return @"Crazy";
            break;
            
        default:
            return @"Unknown";
            break;
    }
}

+(void) cycleCameraMode{
    _cameraMode++;
    if(_cameraMode>3){
        _cameraMode=0;
    }
}

+(int) getAsteroidCount{
    return _asteroidCount;
}

+(void) cycleAsteroidCount{
    _asteroidCount+=100;
    if(_asteroidCount>1000){
        _asteroidCount = 100;
    }
}

@end

/////////////////////////////////////////////////////////////////////////////
@implementation AsteroidCount
- (id) init {
	if(self=[super init]){
		self.name = @"Asteroid Count";
	}
	return self;
}

-(NSString*) label{
    return [NSString stringWithFormat:@"%d", [Asteroids getAsteroidCount]];
}

-(void) userTapped{
    [Asteroids cycleAsteroidCount];
}
@end

/////////////////////////////////////////////////////////////////////////////
@implementation AsteroidsRenderingMode
- (id) init {
	if(self=[super init]){
		self.name = @"Asteroids Rendering";
	}
	return self;
}

-(NSString*) label{
    return [Asteroids renderingModeDesc];
}

-(void) userTapped{
    [Asteroids cycleRenderingMode];
}
@end

/////////////////////////////////////////////////////////////////////////////
@implementation AsteroidsCameraMode
- (id) init {
	if(self=[super init]){
		self.name = @"Asteroids Camera";
	}
	return self;
}

-(NSString*) label{
    return [Asteroids cameraModeDesc];
}

-(void) userTapped{
    [Asteroids cycleCameraMode];
}
@end





