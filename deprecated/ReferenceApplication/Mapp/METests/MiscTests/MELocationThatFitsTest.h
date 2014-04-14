//
//  MELocationThatFitsTest.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/20/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../METest.h"
#import <ME/ME.h>

//Test locationThatFitsBounds API
@interface PlaceWithBounds : NSObject
@property (copy) NSString* name;
@property (assign) MELocationBounds meLocationBounds;
@property (assign) double minX;
@property (assign) double minY;
@property (assign) double maxX;
@property (assign) double maxY;
- (id) initWithName:(NSString*) placeName minLon:(double) minLon minLat:(double) minLat maxLon:(double) maxLon maxLat:(double) maxLat;
@end

@interface MELocationThatFitsBoundsTest : METest
@property (retain) NSMutableArray* places;
@property (assign) int placeIndex;
@end


//Test locationThatFitsPoints API
@interface PlaceWithPoints : NSObject
@property (copy) NSString* name;
@property (retain) NSArray* points;
- (id) initWithName:(NSString*) placeName placePoints:(NSArray*)placePoints;
@end

@interface MELocationThatFitsPointsTest : METest
@property (retain) NSMutableArray* places;
@property (assign) int placeIndex;
@end
