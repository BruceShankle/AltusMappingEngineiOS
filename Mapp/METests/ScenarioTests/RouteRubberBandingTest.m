//
//  RouteRubberBandingTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/29/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "RouteRubberBandingTest.h"

@implementation RouteRubberBandingTest
@synthesize  routeMarkerViewController;
@synthesize markerMapName;
@synthesize longPress;
@synthesize fillStyle;
@synthesize JFK;
@synthesize SFO;
@synthesize HOU;
@synthesize MIA;
@synthesize RDU;

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Route Rubber-banding";
        self.markerMapName = [NSString stringWithFormat:@"%@ Markers",
                              self.name];
        //Create gesture recognizer
        self.longPress = [[[UILongPressGestureRecognizer alloc]
                          initWithTarget:self
                          action:@selector(handleLongPress:)]autorelease];
        self.longPress.minimumPressDuration = 2.0;
        
        //Line fill
        self.fillStyle = [[[MELineStyle alloc]init]autorelease];
        self.fillStyle.strokeColor = [UIColor yellowColor];
        self.fillStyle.outlineColor = [UIColor blackColor];
        self.fillStyle.strokeWidth = 4;
        self.fillStyle.outlineWidth = 1;
        
        //Create route marker view controller
        self.routeMarkerViewController = [[[RouteMarkerViewController alloc]
                                          initWithNibName:@"RouteMarkerViewController"
                                          bundle:nil]autorelease];
		
		self.JFK = CGPointMake(-73.78208504094064,40.64365972925757);
		self.SFO = CGPointMake(-122.3736948394537,37.61931125933241);
		self.HOU = CGPointMake(-95.27900971583961,29.6465098129107);
		self.MIA = CGPointMake(-80.27914615027547,25.79475488150219);
		self.RDU = CGPointMake(-78.790864, 35.882872);
        
    }
    return self;
}

- (void) dealloc
{
    self.longPress = nil;
    self.fillStyle = nil;
    self.routeMarkerViewController = nil;
    self.markerMapName = nil;
    [super dealloc];
}


- (void) start
{
    //Register view to handle long presse gesture
    //with the MEMapView
	[self.meMapViewController.meMapView addGestureRecognizer:self.longPress];
    
	//Create dynamic marker map for route endpoints
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = self.markerMapName;
	mapInfo.mapType = kMapTypeDynamicMarker;
	mapInfo.zOrder = 101;
	mapInfo.meMarkerMapDelegate = self;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];

    //Add markers to route endpoint
    [self addEndpointMarkers];
    
    [self lookAtUnitedStates];
	
	MEVectorMapInfo* vectorMapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
	vectorMapInfo.name = self.name;
	vectorMapInfo.zOrder = 100;
	[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
    [self.meMapViewController setTesselationThresholdForMap:vectorMapInfo.name withThreshold:40];
	
    //Add some mid-point between Raleigh and Houston
    CLLocationCoordinate2D coord;
    coord.longitude = -87.379481;
    coord.latitude = 33.184773;
    [self updateRoute:coord clearRoute:NO];
    
    self.isRunning = YES;
}

- (void) stop
{
    //Unregister the gesture recognizer
    [self.meMapViewController.meMapView removeGestureRecognizer:self.longPress];
    
    //Remove the vector layer
    [self.meMapViewController removeMap:self.name
                                           clearCache:YES];
    
    //Remove marker layer
    [self.meMapViewController removeMap:self.markerMapName
                                   clearCache:YES];
    
    self.isRunning = NO;
}

- (void) addEndpointMarkers
{
    //Add marker for Houston
	MEMarkerAnnotation* houstonMarker = [[[MEMarkerAnnotation alloc]init]autorelease];
    houstonMarker.coordinate = CLLocationCoordinate2DMake(HOU.y, HOU.x);
    houstonMarker.metaData=@"HOU";
    [self.meMapViewController addMarkerToMap:self.markerMapName
							markerAnnotation:houstonMarker];
    
    //Add marker for Raleigh
    MEMarkerAnnotation* raleighMarker = [[[MEMarkerAnnotation alloc]init]autorelease];
    raleighMarker.coordinate = CLLocationCoordinate2DMake(RDU.y, RDU.x);
    raleighMarker.metaData=@"RDU";
    [self.meMapViewController addMarkerToMap:self.markerMapName
							markerAnnotation:raleighMarker];
}

- (void) updateRoute:(CLLocationCoordinate2D) midPointCoord clearRoute:(BOOL) clearRoute
{
    
	CGPoint midPoint = CGPointMake(midPointCoord.longitude, midPointCoord.latitude);
	
	NSMutableArray* routePoints = [[[NSMutableArray alloc]init]autorelease];
    
    // stressing dynamic lines
    const int pointCount = 10;
    for (int i = 0; i < pointCount; ++i)
    {
        CGFloat x = self.HOU.x - (pointCount - i)/2;
        CGFloat y = self.HOU.y + 5 * i%2;
        [routePoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
    [routePoints addObject:[NSValue valueWithCGPoint:self.HOU]];
    [routePoints addObject:[NSValue valueWithCGPoint:midPoint]];
    [routePoints addObject:[NSValue valueWithCGPoint:self.RDU]];
	
	[self.meMapViewController clearDynamicGeometryFromMap:self.name];
	
    [self.meMapViewController addDynamicLineToVectorMap:self.name
												 lineId:@"route"
												 points:routePoints
												  style:self.fillStyle];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    CGPoint viewPoint=[gesture locationInView:self.meMapViewController.meMapView];
    
    CLLocationCoordinate2D coordinate=[self.meMapViewController.meMapView convertPoint:viewPoint];
    
    //Here you would add a new point to your path
    if(UIGestureRecognizerStateBegan == gesture.state)
    {
        //Add a new point where the user tapped.
        //NSLog(@"Long press: began: %f, %f", coordinate.longitude, coordinate.latitude);
        [self updateRoute:coordinate clearRoute:YES];
    }
    
    //Here the new point is moved around
    if(UIGestureRecognizerStateChanged == gesture.state)
    {
        //NSLog(@"Long press: changed: %f, %f", coordinate.longitude, coordinate.latitude);
        [self updateRoute:coordinate clearRoute:YES];
    }
	
    //Here you might integrate the point into your path
    if(UIGestureRecognizerStateEnded == gesture.state)
    {
        //NSLog(@"Long press: ended: %f, %f", coordinate.longitude, coordinate.latitude);
        [self updateRoute:coordinate clearRoute:NO];
    }
}

-(void) mapView:(MEMapView *)mapView updateMarkerInfo:(MEMarkerInfo *)markerInfo
		mapName:(NSString *)mapName

{
    //Choose an marker image based this being a retina display or not
    UIImage* markerImage;
    CGPoint anchorPoint;
    @synchronized(self.routeMarkerViewController)
    {
        //Update text on the view
        [self.routeMarkerViewController updateRouteLabelText:markerInfo.metaData];
        
        //Render the marker to image and return the data
        markerImage = [MEImageUtil createImageFromView:self.routeMarkerViewController.view];
        
        NSLog(@"%f", markerImage.size.height);
        
        anchorPoint = CGPointMake(markerImage.size.width/2,
                                  markerImage.size.height/2);
		
		markerInfo.uiImage = markerImage;
		markerInfo.anchorPoint = anchorPoint;
		
		[markerImage release];
    }
}


@end
