//
//  MEWorldVectorStylingTest.h
//  Mapp
//
//  Created by Bruce Shankle III on 9/17/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../METest.h"

@interface MEWorldVectorMapBoxStyle : METest <MEMarkerMapDelegate>

@property (retain) NSString* worldVectorMapName;
@property (assign) BOOL doubleSpaceCountryFont;
@property (retain) NSString* fontName;
@property (retain) UIColor* fontStrokeColor;

@property (retain) NSString* fontNameCountry;
@property (retain) UIColor* fontCountryFillColor;
@property (assign) CGFloat fontCountrySize;

@property (retain) NSString* fontNameState;
@property (retain) UIColor* fontStateFillColor;
@property (assign) CGFloat fontStateSize;

@property (retain) NSString* fontNameCity;
@property (retain) UIColor* fontCityFillColor;
@property (assign) CGFloat fontCitySize;

@property (assign) CGFloat fontStrokeWidth;

@property (retain) UIColor* landFillColor;
@property (retain) UIColor* landStrokeColor;
@property (assign) CGFloat landStrokeWidth;
@property (assign) NSString* landTexture;

@property (retain) UIColor* oceanFillColor;
@property (retain) UIColor* oceanStrokeColor;
@property (assign) CGFloat oceanStrokeWidth;
@property (assign) NSString* oceanTexture;

@property (retain) UIColor* waterFillColor;
@property (retain) UIColor* waterStrokeColor;
@property (assign) CGFloat waterStrokeWidth;
@property (assign) NSString* waterTexture;

@property (retain) UIColor* countryFillColor;
@property (retain) UIColor* countryStrokeColor;
@property (assign) CGFloat countryStrokeWidth;

@property (retain) UIColor* stateFillColor;
@property (retain) UIColor* stateStrokeColor;
@property (assign) CGFloat stateStrokeWidth;

@property (retain) UIColor* roadFillColor;
@property (retain) UIColor* roadStrokeColor;
@property (assign) CGFloat roadStrokeWidth;

@property (retain) UIColor* road2FillColor;
@property (retain) UIColor* road2StrokeColor;
@property (assign) CGFloat road2StrokeWidth;

@property (retain) NSString* markerBundlePath;

@property (assign) BOOL useOutlinedFont;

- (void) applyPolygonStyle;

- (NSString*) labelText:(NSString*) markerMetaData;

@end

@interface MEWorldVectorGoogleStyle : MEWorldVectorMapBoxStyle
@end

@interface MEWorldVectorPurpleStyle : MEWorldVectorMapBoxStyle
@end

@interface MEWorldVectorHighContrastStyle : MEWorldVectorMapBoxStyle
@end

@interface MEWorldVectorInvisibleStyle : MEWorldVectorMapBoxStyle
@end

@interface MEWorldVectorGeologyDotComStyle : MEWorldVectorMapBoxStyle
@end

@interface MEWorldVectorTextureStyle : MEWorldVectorMapBoxStyle

@end