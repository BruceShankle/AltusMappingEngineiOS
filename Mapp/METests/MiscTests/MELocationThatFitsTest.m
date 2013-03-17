//
//  MELocationThatFitsTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/20/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MELocationThatFitsTest.h"


//Test locationThatFitsBounds API

@implementation PlaceWithBounds
@synthesize name;
@synthesize meLocationBounds;
- (id) initWithName:(NSString*) placeName minLon:(double) minLon minLat:(double) minLat maxLon:(double) maxLon maxLat:(double) maxLat
{
    if(self=[super init])
    {
        self.name=placeName;
        MELocationBounds newBounds;
        newBounds.min.longitude = minLon;
        newBounds.min.latitude = minLat;
        newBounds.max.longitude = maxLon;
        newBounds.max.latitude = maxLat;
        self.meLocationBounds = newBounds;
    }
    return self;
}

- (void) dealloc
{
    self.name=nil;
    [super dealloc];
}

@end

@implementation MELocationThatFitsBoundsTest
@synthesize places;
@synthesize placeIndex;
- (id) init
{
    if(self = [super init])
    {
        self.name=@"L.Fits Bounds";
        [self createPlaces];
        self.placeIndex = -1;
    }
    return self;
}

- (void) createPlaces
{
    self.places = [[NSMutableArray alloc]init];
    
    [self.places addObject:[[[PlaceWithBounds alloc]initWithName:@"Australia"
                                                minLon:113
                                                minLat:-39
                                                maxLon:153
                                                maxLat:-10]autorelease]];
    
    [self.places addObject:[[[PlaceWithBounds alloc]initWithName:@"Raleigh, NC"
                                                minLon:-78.674676
                                                minLat:35.756825
                                                maxLon:-78.604642
                                                maxLat:35.792335]autorelease]];
    
    [self.places addObject:[[[PlaceWithBounds alloc]initWithName:@"Houston, TX"
                                                minLon:-95.685873
                                                minLat:29.541814
                                                maxLon:-95.109102
                                                maxLat:29.964350]autorelease]];
    
    [self.places addObject:[[[PlaceWithBounds alloc]initWithName:@"Faulkland Islands"
                                                minLon:-61.347680
                                                minLat:-52.396273
                                                maxLon:-57.687799
                                                maxLat:-50.997031]autorelease]];
    
    [self.places addObject:[[[PlaceWithBounds alloc]initWithName:@"Amatignak Basin"
                                                minLon:179.802852
                                                minLat:50.741181
                                                maxLon:-178.359969
                                                maxLat:51.700410]autorelease]];
    
    [self.places addObject:[[[PlaceWithBounds alloc]initWithName:@"Bruce's House"
                                                minLon:-78.782564
                                                minLat:35.730395
                                                maxLon:-78.782418
                                                maxLat:35.730526]autorelease]];
    
    
    
    
    
}

- (void) dealloc
{
    self.places = nil;
    [super dealloc];
}

- (NSString*) label
{
    if(self.placeIndex < 0) return @"";
    PlaceWithBounds* p = [self.places objectAtIndex:self.placeIndex];
    return p.name;
}


- (void) userTapped
{
    //Get ready for next place, or reset.
    self.placeIndex = self.placeIndex + 1;
    if(self.placeIndex==self.places.count)
        self.placeIndex = 0;
    
    //Go to the place
    PlaceWithBounds* p = [self.places objectAtIndex:self.placeIndex];
    MELocation meLocation = [self.meMapViewController.meMapView locationThatFitsBounds:p.meLocationBounds
                                                                  withHorizontalBuffer:0
                                                                    withVerticalBuffer:0];
    [self.meMapViewController.meMapView setLocation:meLocation animationDuration:1.0];
}

//Override default start and stop so timers don't get created...
- (void) start
{
}
- (void) stop
{
}
@end


// Test locationThatFitsPoints API
@implementation PlaceWithPoints
@synthesize name;
@synthesize points;
- (id) initWithName:(NSString*) placeName placePoints:(NSArray*) placePoints
{
    if(self=[super init])
    {
        self.name=placeName;
        self.points=placePoints;
    }
    return self;
}

- (void) dealloc
{
    self.name=nil;
    self.points=nil;
    [super dealloc];
}
@end


@implementation MELocationThatFitsPointsTest
@synthesize places;
@synthesize placeIndex;
- (id) init
{
    if(self = [super init])
    {
        self.name=@"L.Fits Points";
        self.placeIndex = -1;
    }
    return self;
}


- (void) addPointWithLon:(double) lon lat:(double) lat toPointArray:(NSMutableArray*) pointArray
{
     [pointArray addObject:[self.meMapViewController.meMapView encodeCoordinate:CLLocationCoordinate2DMake(lat, lon)]];
}

- (void) createPlaces
{
    if (self.places!=nil)
        return;
    
    self.places = [[NSMutableArray alloc]init];
    NSMutableArray* points;
    
    //Australia
    points = [[NSMutableArray alloc]init];
    [self addPointWithLon:113 lat:-39
             toPointArray:points];
    [self addPointWithLon:153 lat:-10
             toPointArray:points];
    [self.places addObject:[[PlaceWithPoints alloc]initWithName:@"Australia"
                                                    placePoints:points]];
    [points release];
    
    
    //North pole
    points = [[NSMutableArray alloc]init];
    [self addPointWithLon:-118.031232 lat:63.982610
             toPointArray:points];
    [self addPointWithLon:3.551551 lat:79.439771
             toPointArray:points];
    [self addPointWithLon:-48.068686 lat:62.134874
             toPointArray:points];
    [self addPointWithLon:79.731559 lat:72.580665
             toPointArray:points];
    [self.places addObject:[[PlaceWithPoints alloc]initWithName:@"North Pole"
                                                    placePoints:points]];
    [points release];
    
    
    //South pole
    points = [[NSMutableArray alloc]init];
    [self addPointWithLon:-78.441423 lat:-63.920790
             toPointArray:points];
    [self addPointWithLon:100.046519 lat:-44.051367
             toPointArray:points];
    [self.places addObject:[[PlaceWithPoints alloc]initWithName:@"South Pole"
                                                    placePoints:points]];
    [points release];

    
    //Bay area
    points = [[NSMutableArray alloc]init];
    [self addPointWithLon:-122.571341 lat:37.941734
             toPointArray:points];
    [self addPointWithLon:-122.348638 lat:37.562816
             toPointArray:points];
    [self.places addObject:[[PlaceWithPoints alloc]initWithName:@"Bay Area"
                                                    placePoints:points]];
    [points release];
    
   }

- (void) dealloc
{
    self.places = nil;
    [super dealloc];
}

- (NSString*) label
{
    if(self.placeIndex < 0) return @"";
    PlaceWithBounds* p = [self.places objectAtIndex:self.placeIndex];
    return p.name;
}


- (void) userTapped
{
    if(self.places==nil)
        [self createPlaces];
    
    //Get ready for next place, or reset.
    self.placeIndex = self.placeIndex + 1;
    if(self.placeIndex==self.places.count)
        self.placeIndex = 0;
    
    //Go to the place
    PlaceWithPoints* p = [self.places objectAtIndex:self.placeIndex];
    MELocation meLocation = [self.meMapViewController.meMapView locationThatFitsPoints:p.points
                                                                  withHorizontalBuffer:100
                                                                    withVerticalBuffer:100];
    [self.meMapViewController.meMapView setLocation:meLocation animationDuration:1.0];
}

//Override default start and stop so timers don't get created...
- (void) start
{
}

- (void) stop
{
}
@end




