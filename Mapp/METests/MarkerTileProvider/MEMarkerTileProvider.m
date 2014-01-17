//  Copyright (c) 2013 BA3, LLC. All rights reserved.

#import "MEMarkerTileProvider.h"
#import "../METestConsts.h"

@implementation MEMarkerTileProvider

- (id) init{
	if(self = [super init]){
		self.isAsynchronous = YES;
	}
	return self;
}

- (MEDynamicMarker*) createMarkerWithName:(NSString*)name andLocation:(CLLocationCoordinate2D)location
{
	MEDynamicMarker* marker = [[[MEDynamicMarker alloc]init]autorelease];
	marker.name = name;
	marker.cachedImageName = @"amazing";
    
	marker.compressTexture = NO;
	marker.location = location;
	marker.anchorPoint = CGPointMake(0,0);
    
    return marker;
}

- (void) requestTileAsync:(METileProviderRequest *)meTileRequest{

    double x = 0.5 * (meTileRequest.minX + meTileRequest.maxX);
    double y = 0.5 * (meTileRequest.minY + meTileRequest.maxY);
    
    MEDynamicMarker* rdu = [self createMarkerWithName:@"center" andLocation:CLLocationCoordinate2DMake(y, x)];
    NSMutableArray *markers = [[[NSMutableArray alloc] init] autorelease];
    [markers addObject:rdu];
    
    [self.meMapViewController markerTileLoadComplete:meTileRequest
                                         markerArray:[NSArray arrayWithArray:markers]];
}

@end
