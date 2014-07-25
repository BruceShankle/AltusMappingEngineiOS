//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "Polygons.h"
#import "PolygonData.h"
#import "../../METestConsts.h"

@implementation Polygons

-(id) init{
    if(self=[super init]){
        self.name = @"Polygons";
    }
    return self;
}

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
    polygonStyle.strokeWidth = 1;
    
    //A shadow
    polygonStyle.shadowColor = [UIColor colorWithRed:0
                                               green:0
                                                blue:0
                                               alpha:0.4];
    
    return polygonStyle;
}

- (void) addPolygon:(NSString*)name
        coordinates:(float[]) coordinateArray
          arraySize:(int) arraySize{
    
    //Create an array of points for a polygon
    NSMutableArray* points=[self coordinateArrayToPolygon:coordinateArray
                                               startIndex:0
                                                 endIndex:arraySize-1];
    //Add the polygon to the map
    [self.meMapViewController addPolygonToVectorMap:self.name
                                          polygonId:name
                                             points:points
                                              style:[self getRandomStyle]];
    
}

- (void) addCircle:(float) lon
               lat:(float) lat
            radius:(float) radius{
    
    NSMutableArray* points = [[NSMutableArray alloc]init];
    CGPoint center = CGPointMake(lon,lat);
    for(int i=360; i>=20; i-=20){
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
    
    NSString* polygonId = [NSString stringWithFormat:@"Circle centered on (%.3f, %.3f)",
                           lon,lat];
    [self.meMapViewController addPolygonToVectorMap:self.name
                                          polygonId:polygonId
                                             points:points
                                              style:[self getRandomStyle]];
}

- (void) addPolygonCrossingAntimeridian {
    // add a box using SF and Shangai as corners
    NSMutableArray* points = [[NSMutableArray alloc]init];
    
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(-122.5,31.3)]];
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(121.5,31.3)]];
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(121.5,37.8)]];
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(-122.5,37.8)]];
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(-122.5,31.3)]];
    
    NSString* polygonId = [NSString stringWithFormat:@"crosses antimeridan"];
    [self.meMapViewController addPolygonToVectorMap:self.name
                                          polygonId:polygonId
                                             points:points
                                              style:[self getRandomStyle]];
}

- (void) addStatePolygons{
    
    int count=0;
    [self addPolygon:@"North Carolina"
         coordinates:NORTH_CAROLINA_COORDS
           arraySize:NORTH_CAROLINA_COORDS_SIZE];
    count++;
    
    [self addPolygon:@"Georgia"
         coordinates:GEORGIA_COORDS
           arraySize:GEORGIA_COORDS_SIZE];
    count++;
    
    [self addPolygon:@"Kansas"
         coordinates:KANSAS_COORDS
           arraySize:KANSAS_COORDS_SIZE];
    count++;
    
    [self addPolygon:@"Texas"
         coordinates:TEXAS_COORDS
           arraySize:TEXAS_COORDS_SIZE];
    count++;
    
    [self addPolygon:@"Idaho"
         coordinates:IDAHO_COORDS
           arraySize:IDAHO_COORDS_SIZE];
    count++;
    
    float centerX = -98; //about the center of the us
    for(float lon = US_WESTMOST; lon < centerX; lon+=5){
        for(float lat = US_SOUTHMOST; lat<US_NORTHMOST; lat+=5){
            [self addCircle:lon
                        lat:lat
                     radius:100];
            count++;
        }
    }
    for(float lon = centerX; lon < US_EASTMOST; lon+=5){
        for(float lat = US_SOUTHMOST; lat<US_NORTHMOST; lat+=5){
            [self addCircle:lon
                        lat:lat
                     radius:200];
            count++;
        }
    }
    
    [self addPolygonCrossingAntimeridian];
    
    /*Uncomment this to add a lot more polygons
    for(float lon = 20; lon < 150; lon+=7){
        for(float lat = -75; lat<75; lat+=7){
            [self addCircle:lon
                        lat:lat
                     radius:300];
            count++;
        }
    }*/
    
    

    
    NSLog(@"Added %d polygons.", count);
}

- (void) beginTest{
    
    MEVectorMapInfo* vectorMapInfo = [[MEVectorMapInfo alloc]init];
    vectorMapInfo.name = self.name;
    vectorMapInfo.zOrder = 100;
    vectorMapInfo.maxLevel = 5;
    vectorMapInfo.polygonHitDetectionEnabled = true;
    vectorMapInfo.meVectorMapDelegate = self;
    [self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
    [self addStatePolygons];
}

- (void) endTest{
    [self.meMapViewController removeMap:self.name clearCache:YES];
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



@end
