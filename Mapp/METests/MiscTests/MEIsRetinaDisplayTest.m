//
//  MEIsRetinaDisplayTest.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/20/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "MEIsRetinaDisplayTest.h"

@implementation MEIsRetinaDisplayTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Is Retina Display?";
    }
    return self;
}

- (NSString*) label
{
    if(self.meMapViewController.meMapView.isRetinaDisplay)
        return @"Yes";
    return @"No";
}

- (void) start
{
    
}

- (void) stop
{
}


@end
