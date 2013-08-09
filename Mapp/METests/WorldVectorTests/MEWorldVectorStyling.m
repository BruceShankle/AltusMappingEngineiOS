//
//  MEWorldVectorStylingTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 9/17/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MEWorldVectorStyling.h"
#import "../MarkerTests/MarkerTestData.h"
#import "../MarkerTests/Country.h"
#import "../METestManager.h"
#import "../../MapManager/MEMapObjectBase.h"

/////////////////////////////////////////////////////////////////////////
//MapBox style (and base class for other styles)
@implementation MEWorldVectorMapBoxStyle
@synthesize worldVectorMapName;

@synthesize fontCountryFillColor;
@synthesize fontNameCountry;

@synthesize fontCityFillColor;
@synthesize fontNameCity;

@synthesize fontStateFillColor;
@synthesize fontNameState;

@synthesize fontStrokeColor;
@synthesize fontStrokeWidth;

@synthesize landFillColor;
@synthesize landStrokeColor;
@synthesize landStrokeWidth;

@synthesize waterFillColor;
@synthesize waterStrokeColor;
@synthesize waterStrokeWidth;

@synthesize countryFillColor;
@synthesize countryStrokeColor;
@synthesize countryStrokeWidth;

@synthesize stateFillColor;
@synthesize stateStrokeColor;
@synthesize stateStrokeWidth;

@synthesize roadFillColor;
@synthesize roadStrokeColor;
@synthesize roadStrokeWidth;

@synthesize road2FillColor;
@synthesize road2StrokeColor;
@synthesize road2StrokeWidth;

@synthesize markerBundlePath;
@synthesize doubleSpaceCountryFont;
@synthesize useOutlinedFont;

- (id) init
{
    if(self = [super init])
    {
        self.name=@"MapBox Style";
        self.doubleSpaceCountryFont = YES;
		self.useOutlinedFont = YES;
        self.worldVectorMapName = [MEMapObjectBase mapPathForCategory:@"WorldVector"
															  mapName:@"World"];
		self.markerBundlePath = [MarkerTestData countriesCitiesStatesMarkerBundlePath];
        
		//Land
		self.landFillColor = [MEImageUtil makeColor:232 g:224 b:216 a:255];
		self.landStrokeColor = [MEImageUtil makeColor:232 g:224 b:216 a:255];
		self.landStrokeWidth = 0.01;
		
		//Ocean
		self.oceanFillColor = [MEImageUtil makeColor:115 g:182 b:229 a:255];
		self.oceanStrokeColor = [MEImageUtil makeColor:115 g:182 b:229 a:255];
		self.oceanStrokeWidth = 0.01;
		
		//Lakes and rivers
		self.waterFillColor = [MEImageUtil makeColor:115 g:182 b:229 a:255];
		self.waterStrokeColor = [MEImageUtil makeColor:115 g:182 b:229 a:100];
		self.waterStrokeWidth = 0.03;
		
		//Countries
		self.countryFillColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.countryStrokeColor = [MEImageUtil makeColor:112 g:123 b:130 a:255];
		self.countryStrokeWidth = 0.3;
		
		//States and provinces
		self.stateFillColor = [MEImageUtil makeColor:255 g:0 b:0 a:255];
		self.stateStrokeColor = [MEImageUtil makeColor:112 g:123 b:130 a:80];
		self.stateStrokeWidth = 0.5;
		
		//Roads
		self.roadFillColor = [MEImageUtil makeColor:255 g:0 b:0 a:255];
		self.roadStrokeColor = [MEImageUtil makeColor:255 g:255 b:255 a:150];
		self.roadStrokeWidth = 0.5;
		
		//Secondary Roads
		self.road2FillColor = [MEImageUtil makeColor:255 g:0 b:0 a:255];
		self.road2StrokeColor = [MEImageUtil makeColor:255 g:255 b:255 a:75];
		self.road2StrokeWidth = 0.5;

        
        //Labeling
        self.fontNameCountry=@"Arial-BoldMT";
		self.fontCountryFillColor = [UIColor blackColor];
		self.fontCountrySize = 17.0;
		
		self.fontNameCity = @"ArialMT";
		self.fontCityFillColor = [UIColor blackColor];
		self.fontCitySize = 13.0;
		
		self.fontNameState = @"ArialMT";
		self.fontStateFillColor = [MEImageUtil makeColor:130 g:130 b:130 a:255];
		self.fontStateSize = 14.0;
		
		
        self.fontStrokeColor = [MEImageUtil makeColor:255 g:255 b:255 a:255];
        self.fontStrokeWidth = 0;
    }
    return self;
}

- (void) dealloc
{
    self.worldVectorMapName=nil;
    self.fontNameCountry = nil;
    self.fontCountryFillColor = nil;
	
	self.fontNameCity = nil;
	self.fontCityFillColor = nil;
	
	self.fontNameState = nil;
	self.fontStateFillColor = nil;
	
    self.fontStrokeColor = nil;
	
	
	self.landFillColor = nil;
	self.landStrokeColor = nil;
	
	self.waterFillColor = nil;
	self.waterStrokeColor = nil;
	
	self.countryFillColor = nil;
	self.countryStrokeColor = nil;
	
	self.stateFillColor = nil;
	self.stateStrokeColor = nil;
	
	self.roadFillColor = nil;
	self.roadStrokeColor = nil;
	
	self.markerBundlePath = nil;
    [super dealloc];
}

- (BOOL) isEnabled
{
    return [self.meMapViewController containsMap:self.worldVectorMapName];
}

- (void) start
{
	if(!self.isEnabled)
		return;
	
	self.meTestCategory.lastTestStarted = self;

    //Stop all other styling tests and other tests they might interfere with labels
    [self.meTestManager stopEntireCategoryWithName:@"World Vector"];
	//[self.meTestManager stopEntireCategoryWithName:@"Markers"];
	//[self.meTestManager stopEntireCategoryWithName:@"Internet Maps"];
    
    //Apply the poly styles
    [self applyPolygonStyle];
	
	//Turn on the countries and states labels
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.mapType = kMapTypeFileMarker;
	mapInfo.name = self.name;
	mapInfo.meMarkerMapDelegate=self;
	mapInfo.zOrder = 200;
	mapInfo.sqliteFileName = self.markerBundlePath;
	mapInfo.fadeInTime=0.1;
	mapInfo.fadeOutTime = 0.1;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
		
    self.isRunning = YES;
}

- (void) applyInvisiblePolygonStyle
{
	MEPolygonStyle* invisibleStyle = [[[MEPolygonStyle alloc]
									   initWithStrokeColor:[UIColor clearColor]
									   strokeWidth:0
									   fillColor:[UIColor clearColor]]autorelease];
	
	for(int i=0; i<6; i++)
	{
		[self.meMapViewController addPolygonStyleToVectorMap:self.worldVectorMapName
												   featureId:i
													   style:invisibleStyle];
	}
	
}

- (void) applyStyle:(MEPolygonStyle*) style featureId:(int) featureId
{
	[self.meMapViewController addPolygonStyleToVectorMap:self.worldVectorMapName
											   featureId:featureId
												   style:style];
	
}

- (void) applyStateStyles
{
	MEPolygonStyle* style = [[[MEPolygonStyle alloc]initWithStrokeColor:self.landStrokeColor
															strokeWidth:self.landStrokeWidth
															  fillColor:self.landFillColor]autorelease];
	
	
	
	[self applyStyle:style featureId:3510];//,Massachusetts
	[self applyStyle:style featureId:3518];//,California
	[self applyStyle:style featureId:3528];//,Missouri
	[self applyStyle:style featureId:3522];//,Oregon
	[self applyStyle:style featureId:3526];//,Iowa
	[self applyStyle:style featureId:3545];//,Kentucky
	[self applyStyle:style featureId:3556];//,New York
	[self applyStyle:style featureId:3558];//,Maine
	[self applyStyle:style featureId:3511];//,Minnesota
	[self applyStyle:style featureId:3512];//,Montana
	[self applyStyle:style featureId:3553];//,District of Columbia
	[self applyStyle:style featureId:3554];//,Maryland
	[self applyStyle:style featureId:3519];//,Colorado
	[self applyStyle:style featureId:3523];//,Utah
	[self applyStyle:style featureId:3524];//,Wyoming
	[self applyStyle:style featureId:3513];//,North Dakota
	[self applyStyle:style featureId:3514];//,Hawaii
	[self applyStyle:style featureId:3515];//,Idaho
	[self applyStyle:style featureId:3516];//,Washington
	[self applyStyle:style featureId:3552];//,Delaware
	[self applyStyle:style featureId:3517];//,Arizona
	[self applyStyle:style featureId:3520];//,Nevada
	[self applyStyle:style featureId:3527];//,Kansas
	[self applyStyle:style featureId:3521];//,New Mexico
	[self applyStyle:style featureId:3525];//,Arkansas
	[self applyStyle:style featureId:3529];//,Nebraska
	[self applyStyle:style featureId:3530];//,Oklahoma
	[self applyStyle:style featureId:3531];//,South Dakota
	[self applyStyle:style featureId:3532];//,Louisiana
	[self applyStyle:style featureId:3533];//,Texas
	[self applyStyle:style featureId:3534];//,Connecticut
	[self applyStyle:style featureId:3536];//,Rhode Island
	[self applyStyle:style featureId:3535];//,New Hampshire
	[self applyStyle:style featureId:3542];//,South Carolina
	[self applyStyle:style featureId:3543];//,Illinois
	[self applyStyle:style featureId:3537];//,Vermont
	[self applyStyle:style featureId:3549];//,Virginia
	[self applyStyle:style featureId:3550];//,Wisconsin
	[self applyStyle:style featureId:3551];//,West Virginia
	[self applyStyle:style featureId:3538];//,Alabama
	[self applyStyle:style featureId:3539];//,Florida
	[self applyStyle:style featureId:3540];//,Georgia
	[self applyStyle:style featureId:3541];//,Mississippi
	[self applyStyle:style featureId:3544];//,Indiana
	[self applyStyle:style featureId:3546];//,North Carolina
	[self applyStyle:style featureId:3547];//,Ohio
	[self applyStyle:style featureId:3548];//,Tennessee
	[self applyStyle:style featureId:3555];//,New Jersey
	[self applyStyle:style featureId:3557];//,Pennsylvania
	[self applyStyle:style featureId:3559];//,Michigan
	[self applyStyle:style featureId:3560];//,Alaska
}

- (void) applyPolygonStyle
{
	[self applyStateStyles];
	//0 land
	//1 ocean
	//2 water
	//3 country
	//4 state
	//5 major roads
	//6 secondary roads
	
    MEPolygonStyle* landStyle = [[[MEPolygonStyle alloc]initWithStrokeColor:self.landStrokeColor
																strokeWidth:self.landStrokeWidth
																  fillColor:self.landFillColor]autorelease];
	[self.meMapViewController addPolygonStyleToVectorMap:self.worldVectorMapName
											   featureId:0
												   style:landStyle];
	
	MEPolygonStyle* oceanStyle = [[[MEPolygonStyle alloc]initWithStrokeColor:self.oceanStrokeColor
																 strokeWidth:self.oceanStrokeWidth
																   fillColor:self.oceanFillColor]autorelease];
	[self.meMapViewController addPolygonStyleToVectorMap:self.worldVectorMapName
											   featureId:1
												   style:oceanStyle];
	
	MEPolygonStyle* waterStyle = [[[MEPolygonStyle alloc]initWithStrokeColor:self.waterStrokeColor
																 strokeWidth:self.waterStrokeWidth
																   fillColor:self.waterFillColor]autorelease];
	[self.meMapViewController addPolygonStyleToVectorMap:self.worldVectorMapName
											   featureId:2
												   style:waterStyle];
	
	MEPolygonStyle* countryStyle = [[[MEPolygonStyle alloc]
									 initWithStrokeColor:self.countryStrokeColor
									 strokeWidth:self.countryStrokeWidth
									 fillColor:self.countryFillColor]autorelease];
	
	[self.meMapViewController addPolygonStyleToVectorMap:self.worldVectorMapName
											   featureId:3
												   style:countryStyle];
	
	MEPolygonStyle* stateStyle = [[[MEPolygonStyle alloc]initWithStrokeColor:self.stateStrokeColor
																 strokeWidth:self.stateStrokeWidth
																   fillColor:self.stateFillColor]autorelease];
	
	[self.meMapViewController addPolygonStyleToVectorMap:self.worldVectorMapName
											   featureId:4
												   style:stateStyle];
	
	MEPolygonStyle* roadStyle = [[[MEPolygonStyle alloc]initWithStrokeColor:self.roadStrokeColor
																strokeWidth:self.roadStrokeWidth
																  fillColor:self.roadFillColor]autorelease];
	
	[self.meMapViewController addPolygonStyleToVectorMap:self.worldVectorMapName
											   featureId:5
												   style:roadStyle];
	
	MEPolygonStyle* road2Style = [[[MEPolygonStyle alloc]initWithStrokeColor:self.road2StrokeColor
																strokeWidth:self.road2StrokeWidth
																  fillColor:self.road2FillColor]autorelease];
	
	[self.meMapViewController addPolygonStyleToVectorMap:self.worldVectorMapName
											   featureId:6
												   style:road2Style];
	
}

- (NSString*) doubleSpaceString:(NSString*) sourceString
{
	NSMutableString* result = [NSMutableString string];
	
	for(int i=0; i<sourceString.length; i++)
	{
		unichar c = [sourceString characterAtIndex:i];
		if ((c >= 0xD800) && (c <= 0xDBFF))
			[result appendFormat:@"%C", c];
		else
			[result appendFormat:@"%C ", c];
	}
	return result;
}

- (NSString*) labelText:(NSString*) markerMetaData
{
	NSString* markerType = [markerMetaData substringToIndex:1];
	NSString* labelText = [markerMetaData substringFromIndex:1];
	
	//Country
	if([markerType isEqualToString:@"C"])
	{
		if(self.doubleSpaceCountryFont)
		{
			labelText = [self doubleSpaceString:labelText];
		}
	}
	
	//State
	if([markerType isEqualToString:@"S"])
	{
	}
	
	//City
	if([markerType isEqualToString:@"c"])
	{
	}
	
	return labelText;
}

- (void) mapView:(MEMapView *)mapView
updateMarkerInfo:(MEMarkerInfo *)markerInfo
		 mapName:(NSString *)mapName
{
	NSString* labelText = [self labelText:markerInfo.metaData];
	NSString* markerType = [markerInfo.metaData substringToIndex:1];
	
	UIColor* fillColor = [UIColor greenColor];
	UIColor* strokeColor = self.fontStrokeColor;
	float fontSize = self.fontCountrySize;
	NSString* fontName = self.fontNameCountry;
	
	//Country
	if([markerType isEqualToString:@"C"])
	{
		fontName = self.fontNameCountry;
		fontSize = self.fontCountrySize;
		fillColor = self.fontCountryFillColor;
	}
	
	//State
	if([markerType isEqualToString:@"S"])
	{
		fontName = self.fontNameState;
		fontSize = self.fontStateSize;
		fillColor = self.fontStateFillColor;
	}
	
	//City
	if([markerType isEqualToString:@"c"])
	{
		fontName = self.fontNameCity;
		fontSize = self.fontCitySize;
		fillColor = self.fontCityFillColor;
	}
	
    //Have the mapping engine create a label for us
	UIImage* textImage;
	
	if(self.useOutlinedFont)
	{
		textImage=[MEFontUtil newImageWithFontOutlined:fontName
										   fontSize:fontSize
										  fillColor:fillColor
										strokeColor:strokeColor
										strokeWidth:self.fontStrokeWidth
											   text:labelText];
	}
	else
	{
		textImage=[MEFontUtil newImageWithFont:fontName
								   fontSize:fontSize
								  fillColor:fillColor
								strokeColor:strokeColor
								strokeWidth:self.fontStrokeWidth
									   text:labelText];
		
	}
    
    //Craete an anhor point based on the image size
    CGPoint anchorPoint = CGPointMake(textImage.size.width / 2.0,
                                      textImage.size.height / 2.0);
    //Return the image
	markerInfo.uiImage = textImage;
	markerInfo.anchorPoint = anchorPoint;
	
	[textImage release];
	
}

- (void) stop
{
    [self applyInvisiblePolygonStyle];
    [self.meMapViewController removeMap:self.name
                                   clearCache:NO];
    self.isRunning = NO;
}

@end

/////////////////////////////////////////////////////////////////////////
//Google style
@implementation MEWorldVectorGoogleStyle
- (id) init
{
    if(self = [super init])
    {
        self.name=@"Google Style";
		
		//Land
		self.landFillColor = [MEImageUtil makeColor:244 g:243 b:240 a:255];
		self.landStrokeColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.landStrokeWidth = 1.0;
		
		//Ocean
		self.oceanFillColor = [MEImageUtil makeColor:165 g:191 b:221 a:255];
		self.oceanStrokeColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.oceanStrokeWidth = 1.0;
		
		//Lakes and rivers
		self.waterFillColor = [MEImageUtil makeColor:165 g:191 b:221 a:255];
		self.waterStrokeColor = [MEImageUtil makeColor:161 g:191 b:221 a:255];
		self.waterStrokeWidth = 0.1;
		
		//Countries
		self.countryFillColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.countryStrokeColor = [MEImageUtil makeColor:112 g:123 b:130 a:255];
		self.countryStrokeWidth = 0.3;
		
		//States and provinces
		self.stateFillColor = [MEImageUtil makeColor:255 g:0 b:0 a:255];
		self.stateStrokeColor = [MEImageUtil makeColor:112 g:123 b:130 a:80];
		self.stateStrokeWidth = 0.5;
		
		//Roads
		self.roadFillColor = [MEImageUtil makeColor:255 g:0 b:0 a:255];
		self.roadStrokeColor = [MEImageUtil makeColor:251 g:195 b:68 a:150];
		self.roadStrokeWidth = 0.5;
		
		//Roads 2
		self.road2FillColor = [MEImageUtil makeColor:255 g:0 b:0 a:255];
		self.road2StrokeColor = [MEImageUtil makeColor:251 g:195 b:68 a:150];
		self.road2StrokeWidth = 1.4;
        
        //Labeling
		self.doubleSpaceCountryFont = NO;
        self.fontNameCountry=@"Arial-BoldMT";
		self.fontCountryFillColor = [UIColor blackColor];
		self.fontCountrySize = 20.0;
		
		self.fontNameState = @"Arial-BoldMT";
		self.fontStateFillColor = [MEImageUtil makeColor:101 g:89 b:69 a:255];
		self.fontStateSize = 15.0;
		
		self.fontNameCity = @"ArialMT";
		self.fontCityFillColor = [MEImageUtil makeColor:71 g:60 b:49 a:255];
		self.fontCitySize = 14.0;
		
		
        self.fontStrokeColor = self.landFillColor; //[MEImageUtil makeColor:255 g:255 b:255 a:255];
        self.fontStrokeWidth = 0;
    }
    return self;
}
@end

/////////////////////////////////////////////////////////////////////////
//A high contrast style
@implementation MEWorldVectorHighContrastStyle
- (id) init
{
    if(self = [super init])
    {
        self.name=@"High Contrast Style";
        
		//Land
		self.landFillColor = [MEImageUtil makeColor:15 g:15 b:15 a:255];
		self.landStrokeColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.landStrokeWidth = 1.0;
		
		//Ocean
		self.oceanFillColor = [MEImageUtil makeColor:50 g:50 b:50 a:255];
		self.oceanStrokeColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.oceanStrokeWidth = 1.0;
		
		//Lakes and rivers
		self.waterFillColor = [MEImageUtil makeColor:55 g:55 b:55 a:255];
		self.waterStrokeColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.waterStrokeWidth = 0.1;
		
		//Countries
		self.countryFillColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.countryStrokeColor = [MEImageUtil makeColor:112 g:123 b:130 a:255];
		self.countryStrokeWidth = 0.3;
		
		//States and provinces
		self.stateFillColor = [MEImageUtil makeColor:255 g:0 b:0 a:255];
		self.stateStrokeColor = [MEImageUtil makeColor:112 g:123 b:130 a:255];
		self.stateStrokeWidth = 0.2;
		
		//Roads
		self.roadFillColor = [MEImageUtil makeColor:255 g:255 b:255 a:200];
		self.roadStrokeColor = [MEImageUtil makeColor:155 g:155 b:155 a:255];
		self.roadStrokeWidth = 0.1;
		
		//Roads 2
		self.road2FillColor = [MEImageUtil makeColor:255 g:255 b:255 a:190];
		self.road2StrokeColor = [MEImageUtil makeColor:155 g:155 b:155 a:255];
		self.road2StrokeWidth = 0.1;
        
        //Labeling
        self.fontNameCountry=@"Verdana-Bold";
		self.fontCountryFillColor = [UIColor whiteColor];
		self.fontCountrySize = 18.0;
		
		self.fontNameCity = @"Verdana-BoldItalic";
		self.fontCityFillColor = [UIColor whiteColor];
		self.fontCitySize = 17.0;
		
		self.fontNameState = @"Verdana";
		self.fontStateFillColor = [UIColor whiteColor];
		self.fontStateSize = 15.0;
		
        self.fontStrokeColor = [UIColor darkGrayColor];
        self.fontStrokeWidth = 1;
    }
    return self;
}
@end

/////////////////////////////////////////////////////
//Clear color for land and water polygons
@implementation MEWorldVectorInvisibleStyle
- (id) init
{
    if(self = [super init])
    {
        self.name=@"Invisible Style";
        
		//Land
		self.landFillColor = [UIColor clearColor];
		self.landStrokeColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.landStrokeWidth = 1.0;
		
		//Ocean
		self.oceanFillColor = [UIColor clearColor];
		self.oceanStrokeColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.oceanStrokeWidth = 1.0;
		
		//Lakes and rivers
		self.waterFillColor = [UIColor clearColor];
		self.waterStrokeColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.waterStrokeWidth = 0.1;
		
		//Countries
		self.countryFillColor = [UIColor clearColor];
		self.countryStrokeColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.countryStrokeWidth = 0.3;
		
		//States and provinces
		self.stateFillColor = [UIColor clearColor];
		self.stateStrokeColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.stateStrokeWidth = 0.2;
		
		//Roads
		UIColor* roadColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.roadFillColor = roadColor;
		self.roadStrokeColor = roadColor;
		self.roadStrokeWidth = 0.8;
		
		//Roads 2
		self.road2FillColor = roadColor;
		self.road2StrokeColor = roadColor;
		self.road2StrokeWidth = 0.7;
        
        //Labeling
        self.fontNameCountry=@"Arial-BoldMT";
		self.fontCountryFillColor = [UIColor whiteColor];
		self.fontCountrySize = 18.0;
		
		self.fontNameCity = @"Arial-BoldMT";
		self.fontCityFillColor = [UIColor whiteColor];
		self.fontCitySize = 17.0;
		
		self.fontNameState = @"Arial-MT";
		self.fontStateFillColor = [UIColor whiteColor];
		self.fontStateSize = 15.0;
		
        self.fontStrokeColor = [MEImageUtil makeColor:0 g:0 b:0 a:200];
        self.fontStrokeWidth = 1;
    }
    return self;
}
@end

/////////////////////////////////////////////////////////////////////////
//Random purple style
@implementation MEWorldVectorPurpleStyle
- (id) init
{
    if(self = [super init])
    {
        self.name=@"Purple Style";
		
		//Land
		self.landFillColor = [MEImageUtil makeColor:116 g:116 b:173 a:255];
		self.landStrokeColor = [MEImageUtil makeColor:116 g:116 b:173 a:255];
		self.landStrokeWidth = 1.0;
		
		//Ocean
		self.oceanFillColor = [MEImageUtil makeColor:85 g:85 b:127 a:255];
		self.oceanStrokeColor = [MEImageUtil makeColor:85 g:85 b:127 a:255];
		self.oceanStrokeWidth = 1.0;
		
		//Lakes and rivers
		self.waterFillColor = [MEImageUtil makeColor:85 g:85 b:127 a:255];
		self.waterStrokeColor = [MEImageUtil makeColor:85 g:85 b:127 a:255];
		self.waterStrokeWidth = 0.1;
		
		//Countries
		self.countryFillColor = [MEImageUtil makeColor:112 g:123 b:130 a:255];
		self.countryStrokeColor = [MEImageUtil makeColor:112 g:123 b:130 a:255];
		self.countryStrokeWidth = 0.3;
		
		//States and provinces
		self.stateFillColor = [MEImageUtil makeColor:112 g:123 b:130 a:150];
		self.stateStrokeColor = [MEImageUtil makeColor:112 g:123 b:130 a:255];
		self.stateStrokeWidth = 0.01;
		
		//Roads
		self.roadFillColor = [MEImageUtil makeColor:255 g:0 b:0 a:255];
		self.roadStrokeColor = [MEImageUtil makeColor:155 g:155 b:155 a:255];
		self.roadStrokeWidth = 0.1;
		
		//Roads 2
		self.roadFillColor = [MEImageUtil makeColor:255 g:0 b:0 a:255];
		self.roadStrokeColor = [MEImageUtil makeColor:155 g:155 b:155 a:255];
		self.roadStrokeWidth = 0.1;
        
        //Labeling
        self.fontNameCountry=@"Arial-BoldItalicMT";
		self.fontCountryFillColor = [UIColor whiteColor];
		self.fontCountrySize = 17.0;
		
		self.fontNameCity = @"Arial-BoldItalicMT";
		self.fontCityFillColor = [UIColor whiteColor];
		self.fontCitySize = 15.0;
		
		self.fontNameState = @"Arial-BoldItalicMT";
		self.fontStateFillColor = [UIColor whiteColor];
		self.fontStateSize = 12.0;
		
        self.fontStrokeColor = [UIColor blackColor];
        self.fontStrokeWidth = 1;
    }
    return self;
}
@end

/////////////////////////////////////////////////////////////////////////
//Style used by www.geology.com
@implementation MEWorldVectorGeologyDotComStyle
- (id) init
{
    if(self = [super init])
    {
        self.name=@"Geology.com Style";
		self.useOutlinedFont = NO;
		
		//Land abbaaf
		self.landFillColor = [MEImageUtil makeColor:171 g:186 b:175 a:255];
		self.landStrokeColor = [MEImageUtil makeColor:171 g:186 b:175 a:255];
		self.landStrokeWidth = 1.0;
		
		//Ocean 3dc0e8
		self.oceanFillColor = [MEImageUtil makeColor:61 g:192 b:232 a:255];
		self.oceanStrokeColor = [MEImageUtil makeColor:61 g:192 b:232 a:255];
		self.oceanStrokeWidth = 1.0;
		
		//Lakes and rivers 3dc0e8
		self.waterFillColor = [MEImageUtil makeColor:61 g:192 b:232 a:255];
		self.waterStrokeColor = [MEImageUtil makeColor:61 g:192 b:232 a:255];
		self.waterStrokeWidth = 0.1;
		
		//Countries
		self.countryFillColor = [MEImageUtil makeColor:150 g:150 b:150 a:255];
		self.countryStrokeColor = [MEImageUtil makeColor:112 g:123 b:130 a:255];
		self.countryStrokeWidth = 0.3;
		
		//States and provinces
		self.stateFillColor = [MEImageUtil makeColor:255 g:0 b:0 a:255];
		self.stateStrokeColor = [MEImageUtil makeColor:0 g:0 b:0 a:112];
		self.stateStrokeWidth = 0.05;
		
		//Roads e31429
		self.roadFillColor = [MEImageUtil makeColor:255 g:0 b:0 a:255];
		self.roadStrokeColor = [MEImageUtil makeColor:227 g:20 b:41 a:200];
		self.roadStrokeWidth = 0.05;
		
		//Roads e31429
		self.road2FillColor = [MEImageUtil makeColor:255 g:0 b:0 a:255];
		self.road2StrokeColor = [MEImageUtil makeColor:227 g:20 b:41 a:200];
		self.road2StrokeWidth = 0.05;
        
        //Labeling
		self.doubleSpaceCountryFont = NO;
        self.fontNameCountry=@"ArialMT";
		//#666666 = 102, 102, 102
		self.fontCountryFillColor = [MEImageUtil makeColor:102 g:102 b:102 a:255];
		self.fontCountrySize = 22.0;
		
		self.fontNameState = @"ArialMT";
		self.fontStateFillColor = [MEImageUtil makeColor:102 g:102 b:102 a:255];
		self.fontStateSize = 13.0;
		
		self.fontNameCity = @"Arial-BoldMT";
		self.fontCityFillColor = [MEImageUtil makeColor:0 g:0 b:0 a:255];
		self.fontCitySize = 12.0;
		
		
        self.fontStrokeColor = self.landFillColor; //[MEImageUtil makeColor:255 g:255 b:255 a:255];
        self.fontStrokeWidth = 0;
    }
    return self;
}

//Upper case country and state names.
- (NSString*) labelText:(NSString*) markerMetaData
{
	NSString* markerType = [markerMetaData substringToIndex:1];
	NSString* labelText = [markerMetaData substringFromIndex:1];
	
	if ([labelText isEqualToString:@"United States"])
		return @"U . S . A .";
	
	//Country
	if([markerType isEqualToString:@"C"])
	{
		labelText=[labelText uppercaseString];
	}
	
	//State
	if([markerType isEqualToString:@"S"])
	{
		labelText=[labelText uppercaseString];
	}
	
	//City
	if([markerType isEqualToString:@"c"])
	{
	}
	
	
	return labelText;
}


- (void) applyStateStyles
{
	[super applyStateStyles];
	
	UIColor* pinkColor = [MEImageUtil makeColor:255 g:169 b:133 a:255];
	UIColor* greenColor = [MEImageUtil makeColor:180 g:198 b:133 a:255];
	UIColor* yellowColor = [MEImageUtil makeColor:255 g:234 b:141 a:255];
	UIColor* orangeColor = [MEImageUtil makeColor:255 g:189 b:120 a:255];
	
	MEPolygonStyle* p = [[[MEPolygonStyle alloc]initWithStrokeColor:pinkColor
															strokeWidth:self.landStrokeWidth
															  fillColor:pinkColor]autorelease];
	
	MEPolygonStyle* g = [[[MEPolygonStyle alloc]initWithStrokeColor:greenColor
														strokeWidth:self.landStrokeWidth
														  fillColor:greenColor]autorelease];
	
	MEPolygonStyle* y = [[[MEPolygonStyle alloc]initWithStrokeColor:yellowColor
														strokeWidth:self.landStrokeWidth
														  fillColor:yellowColor]autorelease];
	
	MEPolygonStyle* o = [[[MEPolygonStyle alloc]initWithStrokeColor:orangeColor
														strokeWidth:self.landStrokeWidth
														  fillColor:orangeColor]autorelease];
	
	[self applyStyle:g featureId:3510];//,Massachusetts
	[self applyStyle:g featureId:3518];//,California
	[self applyStyle:y featureId:3528];//,Missouri
	[self applyStyle:p featureId:3522];//,Oregon
	[self applyStyle:g featureId:3526];//,Iowa
	[self applyStyle:g featureId:3545];//,Kentucky
	[self applyStyle:p featureId:3556];//,New York
	[self applyStyle:y featureId:3558];//,Maine
	[self applyStyle:p featureId:3511];//,Minnesota
	[self applyStyle:g featureId:3512];//,Montana
	[self applyStyle:y featureId:3553];//,District of Columbia
	[self applyStyle:o featureId:3554];//,Maryland
	[self applyStyle:o featureId:3519];//,Colorado
	[self applyStyle:p featureId:3523];//,Utah
	[self applyStyle:y featureId:3524];//,Wyoming
	[self applyStyle:y featureId:3513];//,North Dakota
	[self applyStyle:g featureId:3514];//,Hawaii
	[self applyStyle:o featureId:3515];//,Idaho
	[self applyStyle:y featureId:3516];//,Washington
	[self applyStyle:p featureId:3552];//,Delaware
	[self applyStyle:o featureId:3517];//,Arizona
	[self applyStyle:y featureId:3520];//,Nevada
	[self applyStyle:g featureId:3527];//,Kansas
	[self applyStyle:g featureId:3521];//,New Mexico
	[self applyStyle:g featureId:3525];//,Arkansas
	[self applyStyle:p featureId:3529];//,Nebraska
	[self applyStyle:p featureId:3530];//,Oklahoma
	[self applyStyle:o featureId:3531];//,South Dakota
	[self applyStyle:y featureId:3532];//,Louisiana
	[self applyStyle:o featureId:3533];//,Texas
	[self applyStyle:o featureId:3534];//,Connecticut
	[self applyStyle:y featureId:3536];//,Rhode Island
	[self applyStyle:p featureId:3535];//,New Hampshire
	[self applyStyle:y featureId:3542];//,South Carolina
	[self applyStyle:o featureId:3543];//,Illinois
	[self applyStyle:y featureId:3537];//,Vermont
	[self applyStyle:y featureId:3549];//,Virginia
	[self applyStyle:y featureId:3550];//,Wisconsin
	[self applyStyle:p featureId:3551];//,West Virginia
	[self applyStyle:g featureId:3538];//,Alabama
	[self applyStyle:p featureId:3539];//,Florida
	[self applyStyle:o featureId:3540];//,Georgia
	[self applyStyle:o featureId:3541];//,Mississippi
	[self applyStyle:y featureId:3544];//,Indiana
	[self applyStyle:g featureId:3546];//,North Carolina
	[self applyStyle:o featureId:3547];//,Ohio
	[self applyStyle:p featureId:3548];//,Tennessee
	[self applyStyle:y featureId:3555];//,New Jersey
	[self applyStyle:g featureId:3557];//,Pennsylvania
	[self applyStyle:g featureId:3559];//,Michigan
	[self applyStyle:g featureId:3560];//,Alaska
}


@end

