//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "LicenseManagementTest.h"

@implementation LicenseManagementTest

- (id) init{
    if(self=[super init]){
        self.name = @"Set License Key";
    }
    return self;
}

- (void) start{
    if(self.isRunning)
        return;
    [self.meMapViewController setLicenseKey:@"Your license key here."];
    self.isRunning = YES;
}

- (void) stop{
    if(!self.isRunning)
        return;
    self.isRunning = NO;
    return;
}

@end
