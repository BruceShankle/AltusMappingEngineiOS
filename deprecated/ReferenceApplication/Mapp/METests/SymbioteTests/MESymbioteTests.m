//
//  MEManagedUIViewTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/22/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MESymbioteTests.h"

//UIView-based symbiote test
@implementation MEUIViewSymbioteTest
@synthesize symbiotes;

- (id) init
{
    if(self = [super init])
    {
        self.name=@"UIViews";
        self.symbiotes = [[NSMutableArray alloc]init];
        
        //Cary, NC
        [self addSymbiote:-78.782501 latitude:35.730445];
        [self addSymbiote:-80.782501 latitude:36.730445];
        [self addSymbiote:-82.782501 latitude:37.730445];
        [self addSymbiote:-84.782501 latitude:38.730445];
        [self addSymbiote:-86.782501 latitude:37.730445];
        [self addSymbiote:-88.782501 latitude:36.730445];
        [self addSymbiote:-90.782501 latitude:35.730445];
        [self addSymbiote:-92.782501 latitude:36.730445];
        [self addSymbiote:-94.782501 latitude:37.730445];
        
        
        //Houston, TX
        [self addSymbiote:-95.373213 latitude:29.760830];
        [self addSymbiote:-97.373213 latitude:30.760830];
        [self addSymbiote:-99.373213 latitude:31.760830];
        [self addSymbiote:-101.373213 latitude:32.760830];
        [self addSymbiote:-103.373213 latitude:33.760830];
        [self addSymbiote:-105.373213 latitude:32.760830];
        [self addSymbiote:-107.373213 latitude:31.760830];
        [self addSymbiote:-109.373213 latitude:30.760830];
        [self addSymbiote:-111.373213 latitude:29.760830];
        
    }
    return self;
}

- (void) addSymbiote:(double) longitude latitude:(double) latitude
{
    MELocationCoordinate2D coord;
    AirplaneViewController* avc;
    coord.longitude = longitude;
    coord.latitude = latitude;
    avc = [[AirplaneViewController alloc]initWithNibName:@"AirplaneViewController" bundle:nil];
    [avc setCenterCoordinate:coord];
    [self.symbiotes addObject:avc];
    [avc release];
}

- (void) dealloc
{
    self.symbiotes = nil;
    [super dealloc];
}

- (void) addAllSymbiotes
{
    for(int i=0; i<self.symbiotes.count; i++)
    {
        AirplaneViewController* avc = (AirplaneViewController*)[self.symbiotes objectAtIndex:i];
        [self.meMapViewController.meMapView addSubview:avc.view];
        [self.meMapViewController addSymbiote:avc];
    }
}

- (void) removeAllSymbiotes
{
    for(int i=0; i<self.symbiotes.count; i++)
    {
        AirplaneViewController* avc = (AirplaneViewController*)[self.symbiotes objectAtIndex:i];
        [avc.view removeFromSuperview];
        [self.meMapViewController removeSymbiote:avc];
    }
}

- (void) start
{
    [self addAllSymbiotes];
    self.isRunning = YES;
}

- (void) stop
{
    [self removeAllSymbiotes];
    self.isRunning = NO;
}

@end



//Custom drawing-based symbiote test
@implementation MERouteSymbioteTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Route";
    }
    return self;
}

- (void) dealloc
{
    self.routeView = nil;
    [super dealloc];
}

- (void) start
{
    self.isRunning = YES;
    self.routeView = [[RouteView alloc]initWithFrame:self.meMapViewController.meMapView.bounds];
    [self.meMapViewController.meMapView addSubview:self.routeView];
    [self.meMapViewController addSymbiote:self.routeView];
}

- (void) stop
{
    [self.meMapViewController removeSymbiote:self.routeView];
    [self.routeView removeFromSuperview];
    self.routeView=nil;
    self.isRunning = NO;
}

@end
