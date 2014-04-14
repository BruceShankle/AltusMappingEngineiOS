//
//  METawsEnableTest.m
//  Mapp
//
//  Created by Nik Donets on 8/23/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "METawsTest.h"
#import "../METestCategory.h"
#import "../METestManager.h"
#import "../../MapManager/MEMapObjectBase.h"

#define START_ALTITUDE 2000
#define MAX_ALTITUDE 3000
#define MIN_ALTITUDE 0
#define ALTITUDE_STEP 1

@implementation METawsTest
{
    NSMutableArray* _testNames;
    int _curTestIdx;
    double _plateAltitude;
    double _altitudeStep;
    METerrainColorBar* _meTerrainColorBar;
}

- (id) init
{
    if(self = [super init])
    {
        self.name = @"TAWS Overlay";
        
        _testNames = [[NSMutableArray alloc] init];
        [_testNames addObject:@"Enabled"];
        [_testNames addObject:@"Altitude"];
        
        _curTestIdx = -1;
        _plateAltitude = START_ALTITUDE;
        _altitudeStep = ALTITUDE_STEP;
        
        _meTerrainColorBar = [[METerrainColorBar alloc]init];
        
		
        [_meTerrainColorBar.heightColors addObject:
         [[MEHeightColor alloc]initWithHeight:-1000.00001 color:
          [UIColor clearColor]]];
        
        [_meTerrainColorBar.heightColors addObject:
         [[MEHeightColor alloc]initWithHeight:-1000 color:
          [UIColor yellowColor]]];
        
        [_meTerrainColorBar.heightColors addObject:
         [[MEHeightColor alloc]initWithHeight:-100.000001 color:
          [UIColor yellowColor]]];
        
        [_meTerrainColorBar.heightColors addObject:
         [[MEHeightColor alloc]initWithHeight:-100 color:
          [UIColor redColor]]];
        
		self.mapLoadingStrategy = kLowestDetailFirst;
    }
    
    return self;
}

- (void)dealloc
{
    [_testNames release];
    [_meTerrainColorBar release];
    [super dealloc];
}

- (NSString*) label
{
    if( _curTestIdx < 0 )
    {
        return @"";
    }
    
    return [_testNames objectAtIndex:_curTestIdx];
}

- (IBAction) sliderValueChanged:(UISlider *)sender
{
	float tawsAltitude = 40000 * 0.3048 * sender.value;
	[self.meMapViewController updateTawsAltitude:tawsAltitude];
	[self.lblAltitude setText:[NSString stringWithFormat:@"Altitude = %0.0f feet",
							   tawsAltitude * 3.28084]];
}

- (void) addSlider
{
	CGRect frame = self.meMapViewController.meMapView.bounds;
	frame.size.height = 60;
	self.slider = [[[UISlider alloc]initWithFrame:frame]autorelease];
	self.slider.minimumValue = 0;
	self.slider.maximumValue = 1;
	
	[self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.meMapViewController.meMapView addSubview:self.slider];
	
	CGRect lblFrame = CGRectMake(0,300,300,50);
	self.lblAltitude = [[[UILabel alloc]initWithFrame:lblFrame]autorelease];
	[self.meMapViewController.meMapView addSubview:self.lblAltitude];
	
}

- (void) removeSlider
{
	[self.slider removeFromSuperview];
	[self.lblAltitude removeFromSuperview];
	self.lblAltitude = nil;
	self.slider = nil;
}

- (void) start
{
	[self addSlider];
    self.interval = 0.5;
    [super start];
}

- (void) stop
{
	[self removeSlider];
    [super stop];
}

- (void) timerTick
{
    if( _curTestIdx == 1 )
    {
        _plateAltitude += _altitudeStep;
        
        if( _plateAltitude <= MIN_ALTITUDE )
        {
            _altitudeStep = -_altitudeStep;
        }
        else if( _plateAltitude >= MAX_ALTITUDE )
        {
            _altitudeStep = - _altitudeStep;
        }
        
        [self.meMapViewController updateTawsAltitude:_plateAltitude];
    }
}

- (void) addMaps
{
	NSString* earthMapPath = [MEMapObjectBase mapPathForCategory:@"BaseMaps" mapName:@"Earth"];
    NSString* earthSqliteFile = [NSString stringWithFormat:@"%@.sqlite", earthMapPath];
	NSString* earthDataFile = [NSString stringWithFormat:@"%@.map", earthMapPath];
	
	MEMapInfo* mapInfo = [[[MEMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.mapType = kMapTypeFileTerrainTAWS;
	mapInfo.sqliteFileName = earthSqliteFile;
	mapInfo.dataFileName = earthDataFile;
	mapInfo.zOrder = 5;
	mapInfo.mapLoadingStrategy = self.mapLoadingStrategy;
	mapInfo.compressTextures = YES;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
}

- (void) removeMaps
{
	[self.meMapViewController removeMap:self.name clearCache:NO];
}


- (void) userTapped
{
    
    _curTestIdx++;
    
    switch (_curTestIdx)
    {
        case 0:
            [self start];
            [self.meMapViewController updateTawsAltitude:_plateAltitude];
            [self.meMapViewController updateTawsColorBar:_meTerrainColorBar];
			[self addMaps];
            break;
            
        case 1:
            break;
            
        case 2:
            [self stop];
            [self removeMaps];
            break;
            
        default:
            break;
    }
    
    if( _curTestIdx >= _testNames.count )
    {
        _curTestIdx = -1;
    }
}

@end

////////////////////////////////////////////////////////////////////
@implementation METawsHighestDetailOnlyTest
-(id) init
{
	if(self = [super init])
	{
		self.name = @"TAWS Overlay Highest Detail Only";
		self.mapLoadingStrategy = kHighestDetailOnly;
	}
	return self;
}

@end;

////////////////////////////////////////////////////////////////////
@implementation METawsColorBarTest

- (id) init
{
    if(self = [super init])
    {
        self.name = @"Invert TAWS ColorBar";
    }
    return self;
}

- (BOOL) isEnabled
{
	METest* tawsOverLayTest = [self.meTestCategory testWithName:@"TAWS Overlay"];
	if(tawsOverLayTest==nil)
		return NO;
	if([tawsOverLayTest isRunning])
		return YES;
	return NO;
}

- (void) invertTawsColors
{
	//Get current color bar
	METerrainColorBar* tawsColorBar = [self.meMapViewController tawsColorBar];
	if(tawsColorBar.heightColors.count==0)
		return;
	
	//Reverse the colors
    NSUInteger i = 0;
    NSUInteger j = tawsColorBar.heightColors.count - 1;
    while (i < j) {
		
		MEHeightColor* c1 = [tawsColorBar.heightColors objectAtIndex:i];
		MEHeightColor* c2 = [tawsColorBar.heightColors objectAtIndex:j];
		UIColor* temp;
		temp=c1.color;
		c1.color=c2.color;
		c2.color=temp;
		
        //[tawsColorBar.heightColors exchangeObjectAtIndex:i
		//							   withObjectAtIndex:j];
		
        i++;
        j--;
    }
	
	//Update the color bar
	[self.meMapViewController updateTawsColorBar:tawsColorBar];
}

- (void) userTapped
{
	if(![self isEnabled])
		return;
	
	[self invertTawsColors];
}

- (void) start
{}

- (void) stop
{}
@end
