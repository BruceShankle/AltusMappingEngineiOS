//  Copyright (c) 2013 BA3, LLC. All rights reserved.

#import "TowersWithHeightColorBarTest.h"
#import "../METestConsts.h"

@implementation TowersWithHeightColorBarTest

- (id) init
{
	if(self=[super init])
	{
		self.name = @"Towers with Color Bar";
		self.interval = 0.1;
		self.towerCount = 0;
	}
	return self;
}

- (void) cacheMarkerImage:(NSString*) name
{
	[self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:name]
										  withName:name
								   compressTexture:NO
					nearestNeighborTextureSampling:NO];
}

- (void) addMarkers
{
	double lon = SFO_COORD.longitude;
	double lat = HOU_COORD.latitude;
	UIImage* towerImage = [UIImage imageNamed:@"ShortTower"];
	CGPoint anchorPoint = CGPointMake(towerImage.size.width/2.0, towerImage.size.height);
	int uid = 0;
	MEDynamicMarker* dynamicMarker = [[[MEDynamicMarker alloc]init]autorelease];
	dynamicMarker.anchorPoint = anchorPoint;
	dynamicMarker.cachedImageName = @"ShortTower";
	
	while(lon < RDU_COORD.longitude)
	{
		lon+=1.0;
		while(lat < JFK_COORD.latitude)
		{
			lat+=1.0;
			CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat,lon);
			dynamicMarker.location = location;
			dynamicMarker.name = [NSString stringWithFormat:@"%d", uid];
			dynamicMarker.weight = [self randomDouble:200 max:10000];
			uid++;
			[self.meMapViewController addDynamicMarkerToMap:self.name dynamicMarker:dynamicMarker];
			self.towerCount++;
		}
		lat = HOU_COORD.latitude;
	}
}

- (void) addColorBar
{
    //Create a color bar for ther marker map
	MEHeightColorBar* colorBar = [[[MEHeightColorBar alloc]init]autorelease];
	[colorBar addColor:[UIColor clearColor] atHeight:-1000.00001];
	[colorBar addColor:[UIColor yellowColor] atHeight:-1000];
	[colorBar addColor:[UIColor yellowColor] atHeight:-500.000001];
	[colorBar addColor:[UIColor orangeColor] atHeight:-500];
	[colorBar addColor:[UIColor orangeColor] atHeight:-100.1];
	[colorBar addColor:[UIColor redColor] atHeight:-100];

	//Add the color bar to the marker map
	[self.meMapViewController setDynamicMarkerMapColorBar:self.name
                                                 colorBar:colorBar];
	
}
- (void) addMap
{
	//Pre-cache marker images we'll use for this scenario
	[self cacheMarkerImage:@"ShortTower"];
	
	MEDynamicMarkerMapInfo* mapInfo = [[[MEDynamicMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.name;
	mapInfo.zOrder = 4;
	mapInfo.hitTestingEnabled = YES;
	mapInfo.meDynamicMarkerMapDelegate = self;
	mapInfo.meMapViewController = self.meMapViewController;
	mapInfo.fadeInTime = 1.0;
	mapInfo.fadeOutTime = 1.0;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
	
	
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
	if(self.isRunning)
		return;
	
	[self addMap];
	[self addMarkers];
	[self addColorBar];
	[self addSlider];
	[self startTimer];
	
	self.isRunning = YES;
}

- (void) toggleMarkers
{
	NSMutableArray* nameArray = [[[NSMutableArray alloc]init]autorelease];
	int nameIndex = self.currentIndex;
	for(int i=0; i<13; i++)
	{
		[nameArray addObject:[NSString stringWithFormat:@"%d", nameIndex]];
		 nameIndex++;
		if(nameIndex==self.towerCount)
			nameIndex=0;
	}
	for(NSString* markerName in nameArray)
	{
		[self.meMapViewController hideDynamicMarker:self.name
										 markerName:markerName];
	}
	[self.meMapViewController showDynamicMarker:self.name
									 markerName:[nameArray objectAtIndex:0]];
	
	self.currentIndex++;
	if(self.currentIndex==self.towerCount)
		self.currentIndex=0;
}

- (void) timerTick
{
	[self toggleMarkers];
}

- (void) stop
{
	if(!self.isRunning)
		return;
	[self stopTimer];
	[self.meMapViewController removeMap:self.name clearCache:NO];
	[self removeSlider];
	self.isRunning = NO;
}

- (void) tapOnDynamicMarker:(NSString *)markerName
				  onMapView:(MEMapView *)mapView
					mapName:(NSString *)mapName
			  atScreenPoint:(CGPoint)screenPoint
			  atMarkerPoint:(CGPoint)markerPoint
{
	
	NSLog(@"Dynamic marker tap detected on map name: %@, marker name: %@, screen point:(%f, %f), longitude:%f latitude:%f",
		  mapName,
		  markerName,
		  screenPoint.x,
		  screenPoint.y,
		  markerPoint.x,
		  markerPoint.y);
}

@end
