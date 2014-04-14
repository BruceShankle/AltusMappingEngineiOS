//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "../../METest.h"

@interface WindGrid : NSObject {
    NSArray* valueArray;
    int numLongitudeValues, numLatitudeValues;
}

@property (assign) double deltaLongitude;
@property (assign) double deltaLatitude;
@property (assign) CLLocationCoordinate2D minCoord;
@property (assign) CLLocationCoordinate2D maxCoord;

-(void) readFromXYZ:(NSString*)filepath;
-(double) getValueAtCoordinate:(CLLocationCoordinate2D)coordinate;
-(BOOL) containsCoordinate:(CLLocationCoordinate2D)coordinate;
-(BOOL) intersectsRect:(CGRect)rect;

@end

@interface WorldSamples : METest

+ (NSString*) getWindBarbNameForWindSpeed:(double)windSpeed;

@end

@interface WorldMarkerTileProvider : METileProvider

@property (retain) WindGrid* windSpeedGrid;
@property (retain) WindGrid* windDirectionGrid;

@end