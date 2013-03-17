//
//  MEManagedUIViewTest.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/22/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../METest.h"
#import "AirplaneViewController.h"
#import "RouteView.h"
@interface MEUIViewSymbioteTest : METest
@property (retain) NSMutableArray* symbiotes;
@end

@interface MERouteSymbioteTest : METest
@property (retain) RouteView* routeView;
@end
