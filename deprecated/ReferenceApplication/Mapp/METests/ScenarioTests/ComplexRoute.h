//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import "../METest.h"

@interface ComplexRoute : METest <MEMarkerMapDelegate, MEVectorMapDelegate>

@property (retain) MELineStyle* styleRed;
@property (retain) MELineStyle* styleGreen;
@property (retain) MELineStyle* styleBlue;
@property (retain) MELineStyle* stylePurple;

@property (retain) NSString* transparentMarkerMapName;
@property (retain) NSString* solidMarkerMapName;
@property (retain) NSString* routeLineMapName;

@property (retain) UILongPressGestureRecognizer *longPress;
@end


@interface ParallelsAndMeridians : ComplexRoute
@end
