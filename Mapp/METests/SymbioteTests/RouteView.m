//
//  RouteView.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/24/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "RouteView.h"
#import <ME/ME.h>

@implementation RouteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void) drawRouteFrom:(CLLocationCoordinate2D)start to:(CLLocationCoordinate2D) end onContext:(CGContextRef) context
{
    //Parent view is an MEMapView which we will use to convert geographic
    //points to screen points
    MEMapView* meMapView = (MEMapView*) self.superview;
    
    //Set line width
    CGContextSetLineWidth(context, 2.0);
    
    //Set line color
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    
    CLLocationCoordinate2D currentCoordinate;
    
    currentCoordinate.longitude = start.longitude;
    currentCoordinate.latitude = start.latitude;
    
    //Move to starting point
    CGPoint currentPoint = [meMapView convertCoordinate:currentCoordinate];
    CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
    
    //Add lines to a path
    int lineCount=0;
    while(currentCoordinate.longitude < end.longitude)
    {
        currentCoordinate.longitude+=0.25;
        currentPoint = [meMapView convertCoordinate:currentCoordinate];
        CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
        lineCount++;
    }
    
    while(currentCoordinate.latitude < 40)
    {
        currentCoordinate.latitude+=0.25;
        currentPoint = [meMapView convertCoordinate:currentCoordinate];
        CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
        lineCount++;
    }
    
    //Draw the path
    CGContextStrokePath(context);
    
    //NSLog(@"Drew %d lines.", lineCount);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Draw route
    CLLocationCoordinate2D start = CLLocationCoordinate2DMake(37.619386, -122.373924);
    CLLocationCoordinate2D end = CLLocationCoordinate2DMake(37.619386, -78);
    [self drawRouteFrom:start to:end onContext:context];
}

#pragma mark MESymbiote impl.
- (void) mapViewCameraDidChange
{
    [self setNeedsDisplay];
}


@end
